
WITH seat_ticket_details AS (
    SELECT 

        -- Since ticket resales/transfers can break seat blocks in a ticket, we expand the rows with individual seat numbers.
        flattened_seat_numbers.value::INTEGER AS seat_num,
        
        -- A unique seat identifier (or ticket identifier) 'seat_id' for a given event, seat section, row number, and seat number.
        -- This improves code readability and maintainability by reducing verbosity and the potential for errors.
        -- In this case, we concat the unique identifying combination with '_'. However, any approach can be used.
        (event_id || '_' || seat_section_id || '_' || seat_row_num || '_' || seat_num) AS seat_id,
        
        order_num,
        event_id,
        account_id,
        seat_section_id,
        seat_row_num,
        activity_date,

        -- Columns with details of the previous ownership of the ticket.
        -- This information could be useful for both analysts and ticket holders.
        -- Ownership transition duration in minutes could be an interesting metric given that upwards of 50% of all tickets can change ownership on the day of a game.
        LAG(account_id) over (PARTITION BY seat_id order by activity_date) as previous_owner_account_id,
        DATEDIFF(minute, LAG(activity_date) over (PARTITION BY seat_id order by activity_date), activity_date) as ownership_transition_duration_minutes,

        -- order_num = NULL ; previous_owner = NOT NULL => ticket transfer
        -- order_num = NULL ; previous_owner = NULL => !Doesn't exist!
        -- order_num = NOT NULL ; previous_owner = NOT NULL => ticket resale
        -- order_number = NOT NULL ; previous_owner = NULL => original sale
        CASE
            WHEN order_num IS NULL THEN false 
            WHEN previous_owner_account_id IS NOT NULL THEN false
            ELSE true
        END AS is_original_ticket_holder,
        
        rep_email,
        total_ticket_price
    FROM
        {{ ref('tm_ticket_exchange') }},
        LATERAL FLATTEN(input => {{ generate_seat_numbers(first_seat_num, num_seats) }}) AS flattened_seat_numbers -- To flatten the list of seat numbers
        
), seat_ticket_details_incremental AS (

    SELECT * FROM seat_ticket_details
    
    {% if is_incremental() %}
        WHERE activity_date > (SELECT MAX(activity_date) FROM {{ this }} WHERE {{ this }}.seat_id = seat_id)
    {% endif %}
      
), ticket_ownership AS (
    SELECT
        stdi.seat_id AS ticket_id, -- seat_id can be renamed as ticket_id for our model as a ticket represents a single seat for a single event
        
        -- Latest activity date on a unique seat or ticket.
        MAX(stdi.activity_date) OVER (PARTITION BY stdi.seat_id) AS seat_ticket_latest_activity_date,
        
        stdi.event_id,
        e.season_id,
        e.event_date_start,
        e.event_name,
        stdi.account_id,
        stdi.is_original_ticket_holder,
        c.contact_id,
        c.is_season_ticket_holder,
        c.is_broker,
        c.first_name,
        c.last_name,
        c.email,
        c.mailing_address,
        c.mailing_city,
        c.mailing_state,
        c.mailing_zip,
        stdi.seat_section_id,
        stdi.seat_row_num,
        stdi.seat_num,
        stdi.rep_email,
        stdi.total_ticket_price,
        stdi.order_num,
        stdi.previous_owner_account_id,
        stdi.ownership_transition_duration_minutes
        
    FROM
        seat_ticket_details_incremental stdi
        JOIN {{ ref('tm_event') }} e ON stdi.event_id = e.event_id
        JOIN {{ ref('crm_contact') }} c ON stdi.account_id = c.tm_account_id

    WHERE
        -- This handles the case where for some reason, tm_ticket_exchange table receives multiple ownership instances of the same ticket at once.
        -- This can happen when there are any unexpected delays in downstream data pipelines from TicketMaster.
        -- The below WHERE clause makes sure that the model takes only the latest ownership record.
        stdi.activity_date = (SELECT MAX(activity_date) FROM seat_ticket_details_incremental WHERE seat_id=stdi.seat_id )
)

SELECT *
FROM ticket_ownership


-- Macro to generate the list of seat numbers from first seat number and number of seats
{% macro generate_seat_numbers(first_seat_num, num_seats) %}
{% set seat_numbers = [] %}
{% for i in range(first_seat_num, first_seat_num + num_seats) %}
  {% do seat_numbers.append(i) %}
{% endfor %}
{{ seat_numbers }}
{% endmacro %}

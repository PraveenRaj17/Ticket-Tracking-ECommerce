# Seating Notes

- A seat is uniquely identified by the combination of seat_section_id, seat_row_num, and a seat_num. For example: section ID 322, row 13, seat 4.

- A ticket represents a single seat for a single event.

- Tickets are (re)purchased and transferred in contiguous seat blocks. They do not span rows or sections.
  Ex. when first_seat_num = 6 and num_seats = 5, this block of seats covers 6-10 in their respective row/section.

- Transfers and resells could break ticket blocks apart over time (ex. The account owner of a 4-seat block could transfer or resell the last 2 seats).

# Table Definitions

- tm_ticket_exchange: This table captures ticket ownership changes over time (i.e. a ticket which is resold or transferred will have more than 1 row in this table). It contains data for all ticket block activity (original sales, re-sales, and transfers), including purchase ID, event ID, account ID, activity date, etc.

- tm_event: Contains data for all scheduled home games across the current and previous seasons.

- crm_contact: This table contains contact information about each customer. It also holds a Ticketmaster account ID which links the customer to their TM account.

# Data Definitions

## tm_ticket_exchange

- **ticket_exchange_id**: PK for tm_ticket_exchange. Represents a single activity event for a ticket.
- **event_id**: Unique identifier for each event.
- **account_id**: Unique identifier for each ticketholder account.
- **seat_section_id**: Unique identifier for a section location for the seat(s) in the block.
- **seat_row_num**: The row number for the section (seat_section_id) where the seat block is located.
- **first_seat_num**: The first seat number in this contiguous block of seats.
- **num_seats**: The number of seats in this block of seats.
- **activity_date**: Timestamp representing when the ticket activity occurred (purchase, resale, or transfer).
- **rep_email**: If the ticket was purchased directly from the ticketing group, this will be the email address for that sales rep.
- **total_ticket_price**: Price for all tickets in the block. May be the original purchase price, reseller price, or NULL if this activity was a transfer.
- **order_num**: The order number associated with the (re)sale the ticket block. NULL in the case of transfers.

## tm_event

- **event_id**: PK for tm_event.
- **season_id**: Unique identifier for the season (ex. 2023-24) of this event.
- **event_date_start**: Timestamp for the game’s scheduled tipoff.
- **event_name**: Name for this event. Typically, the opponent and event date.

## crm_contact

- **contact_id**: PK for crm_contact.
- **is_season_ticket_holder**: Boolean denoting if the contact is a current season ticket holder.
- **is_broker**: Boolean denoting if the contact has been identified as a ticket broker.
- **first_name**: First name of the contact.
- **last_name**: Last name of the contact.
- **email**: Contact e-mail address.
- **mailing_address**: Contact mailing address.
- **mailing_city**: Contact mailing city.
- **mailing_state**: Contact mailing state.
- **mailing_zip**: Contact mailing zip.
- **tm_account_id**: Unique identifier for a Ticketmaster account. This is also unique in crm_contact.

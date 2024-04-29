# Ticket Ownership Tracking System with dbt

This project implements a ticket ownership tracking system using dbt (data build tool). It enables the analysis of ticket ownership changes, integration of data from Ticketmaster and CRM sources, and enhancement of ticket utilization reporting and gameday communication capabilities.

## Project Overview

The system focuses on tracking changes in ticket ownership, including purchases, resales, and transfers, to provide insights into fan behavior and optimize engagement strategies. It leverages dbt for data modeling, SQL for querying, and Jinja templating for dynamic code generation. Please refer to 'data_definitions.md' for more intricate details.

## Key Features

- Incremental model for tracking ticket ownership changes
- Integration of data from Ticketmaster and CRM sources
- Calculation of ownership transition durations and identification of resales
- Automated reporting for ticket utilization and gameday communication

## Getting Started

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/your-username/ticket-ownership-tracking.git

2. Install dbt following the [official documentation](https://docs.getdbt.com/docs/installation)
3. Set up your dbt profile with connection details for your data warehouse (e.g., Snowflake)
4. Run the dbt project to generate the ticket ownership tracking model:
   
   ```bash
   dbt run

5. Explore the generated model and reports in your data warehouse or analytics platform.

## Data Quality Checks

The project includes data quality checks implemented using dbt's YAML configuration files. These checks ensure the accuracy and reliability of the ticket ownership tracking model and associated reports. The following data quality checks are performed:

- Column Presence: Verifies the presence of essential columns in the ticket ownership tracking model.
- Null Values: Identifies and reports any null values in critical columns, ensuring data completeness.
- Uniqueness: Validates the uniqueness of key identifiers in the model, preventing duplicate records.
- Data Types: Ensures that data types are consistent across columns, maintaining data integrity.

The data quality checks are defined in the 'current_ticket_ownership.yml' file and executed alongside the model building process using dbt's built-in functionality.

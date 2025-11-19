-- ============================================================================
-- Neptune Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents for Neptune.
-- All syntax VERIFIED against official documentation and Axon demo structure.
--
-- Syntax Verification Notes:
-- 1. Clause order is MANDATORY: TABLES -> RELATIONSHIPS -> DIMENSIONS -> METRICS -> COMMENT
-- 2. All column references VERIFIED against 02_create_tables.sql
-- 3. All synonyms are GLOBALLY UNIQUE across all semantic views
-- ============================================================================

USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NEPTUNE_WH;

-- ============================================================================
-- Semantic View 1: Neptune Meter Operations Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_METER_OPERATIONS_INTELLIGENCE
  TABLES (
    utilities AS RAW.UTILITIES
      PRIMARY KEY (utility_id)
      WITH SYNONYMS ('water utilities', 'utility providers', 'water districts')
      COMMENT = 'Water utilities operating the meter network',
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('water customers', 'service accounts', 'end users')
      COMMENT = 'End customers of the water utilities',
    meters AS RAW.METER_INVENTORY
      PRIMARY KEY (meter_serial_number)
      WITH SYNONYMS ('water meters', 'meter devices', 'endpoints')
      COMMENT = 'Individual water meter devices',
    meter_catalog AS RAW.METER_CATALOG
      PRIMARY KEY (meter_model_id)
      WITH SYNONYMS ('meter models', 'meter product catalog', 'device types')
      COMMENT = 'Catalog of Neptune meter models',
    readings AS RAW.METER_READINGS
      PRIMARY KEY (reading_id)
      WITH SYNONYMS ('water consumption readings', 'meter data', 'usage data')
      COMMENT = 'Time-series meter consumption readings'
  )
  RELATIONSHIPS (
    customers(utility_id) REFERENCES utilities(utility_id),
    meters(utility_id) REFERENCES utilities(utility_id),
    meters(customer_id) REFERENCES customers(customer_id),
    meters(meter_model_id) REFERENCES meter_catalog(meter_model_id),
    readings(meter_serial_number) REFERENCES meters(meter_serial_number),
    readings(customer_id) REFERENCES customers(customer_id),
    readings(utility_id) REFERENCES utilities(utility_id)
  )
  DIMENSIONS (
    utilities.utility_name AS utility_name
      WITH SYNONYMS ('water utility name', 'provider name')
      COMMENT = 'Name of the water utility',
    utilities.utility_type AS utility_type
      WITH SYNONYMS ('utility classification', 'provider type')
      COMMENT = 'Type of utility: MUNICIPAL, PRIVATE',
    utilities.state AS state
      WITH SYNONYMS ('utility state', 'provider location state')
      COMMENT = 'State where the utility operates',
    customers.customer_name AS customer_name
      WITH SYNONYMS ('end user name', 'account holder name')
      COMMENT = 'Name of the end customer',
    customers.customer_status AS customer_status
      WITH SYNONYMS ('account status', 'service status')
      COMMENT = 'Customer account status: ACTIVE, INACTIVE',
    meters.meter_status AS meter_status
      WITH SYNONYMS ('device deployment status', 'meter state')
      COMMENT = 'Status of the meter: DEPLOYED, IN_STOCK, MAINTENANCE',
    meters.firmware_version AS firmware_version
      WITH SYNONYMS ('meter firmware', 'device software version')
      COMMENT = 'Firmware version of the meter',
    meter_catalog.model_name AS model_name
      WITH SYNONYMS ('meter product name', 'device model name')
      COMMENT = 'Model name of the meter',
    meter_catalog.meter_family AS meter_family
      WITH SYNONYMS ('meter product line', 'device family')
      COMMENT = 'Meter product family: R900, E-CODER, MACH 10',
    meter_catalog.technology AS technology
      WITH SYNONYMS ('meter tech', 'communication technology')
      COMMENT = 'Meter technology: AMR, AMI, ULTRASONIC',
    readings.reading_type AS reading_type
      WITH SYNONYMS ('consumption data type', 'reading frequency')
      COMMENT = 'Type of meter reading: HOURLY, DAILY',
    readings.anomaly_detected AS anomaly_detected
      WITH SYNONYMS ('leak detected', 'unusual consumption flag')
      COMMENT = 'Flag for anomalous readings'
  )
  METRICS (
    utilities.total_utilities AS COUNT(DISTINCT utility_id)
      WITH SYNONYMS ('number of utilities', 'utility count')
      COMMENT = 'Total number of utilities',
    utilities.avg_service_population AS AVG(service_population)
      WITH SYNONYMS ('average service population', 'mean population served')
      COMMENT = 'Average population served by utilities',
    customers.total_customers AS COUNT(DISTINCT customer_id)
      WITH SYNONYMS ('number of customers', 'customer count')
      COMMENT = 'Total number of customers',
    meters.total_meters AS COUNT(DISTINCT meter_serial_number)
      WITH SYNONYMS ('number of meters', 'meter count', 'device count')
      COMMENT = 'Total number of deployed meters',
    meters.avg_meter_age_days AS AVG(DATEDIFF('day', installation_date, CURRENT_DATE()))
      WITH SYNONYMS ('average meter age', 'mean device age')
      COMMENT = 'Average age of meters in days',
    readings.total_readings AS COUNT(DISTINCT reading_id)
      WITH SYNONYMS ('number of readings', 'reading count')
      COMMENT = 'Total number of meter readings',
    readings.total_consumption_gallons AS SUM(consumption_gallons)
      WITH SYNONYMS ('total water consumption', 'total volume')
      COMMENT = 'Total water consumption in gallons',
    readings.avg_consumption_gallons AS AVG(consumption_gallons)
      WITH SYNONYMS ('average water consumption', 'mean volume')
      COMMENT = 'Average water consumption in gallons per reading'
  )
  COMMENT = 'Neptune Meter Operations Intelligence - a comprehensive view of utilities, customers, meters, and consumption data.';

-- ============================================================================
-- Semantic View 2: Neptune Utility Service Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_UTILITY_SERVICE_INTELLIGENCE
  TABLES (
    utilities AS RAW.UTILITIES
        PRIMARY KEY (utility_id)
        WITH SYNONYMS ('service utilities', 'work order utilities')
        COMMENT = 'Water utilities with service work orders',
    work_orders AS RAW.WORK_ORDERS
        PRIMARY KEY (work_order_id)
        WITH SYNONYMS ('service tickets', 'maintenance orders', 'technician jobs')
        COMMENT = 'Service work orders for customers and meters',
    technicians AS RAW.SERVICE_TECHNICIANS
        PRIMARY KEY (technician_id)
        WITH SYNONYMS ('service technicians', 'field engineers', 'repair staff')
        COMMENT = 'Service technicians handling work orders',
    customers AS RAW.CUSTOMERS
        PRIMARY KEY (customer_id)
        WITH SYNONYMS ('serviced customers', 'work order customers')
        COMMENT = 'Customers associated with work orders',
    meters AS RAW.METER_INVENTORY
        PRIMARY KEY (meter_serial_number)
        WITH SYNONYMS ('serviced meters', 'work order meters')
        COMMENT = 'Meters associated with work orders'
  )
  RELATIONSHIPS (
    work_orders(utility_id) REFERENCES utilities(utility_id),
    work_orders(customer_id) REFERENCES customers(customer_id),
    work_orders(meter_serial_number) REFERENCES meters(meter_serial_number),
    work_orders(assigned_technician_id) REFERENCES technicians(technician_id),
    customers(utility_id) REFERENCES utilities(utility_id),
    meters(customer_id) REFERENCES customers(customer_id)
  )
  DIMENSIONS (
    utilities.utility_name AS utility_name
      WITH SYNONYMS ('service utility name', 'work order provider name')
      COMMENT = 'Name of the water utility',
    work_orders.order_category AS order_category
      WITH SYNONYMS ('work order type', 'service category')
      COMMENT = 'Category of the work order: INSTALLATION, REPAIR, INVESTIGATION, MAINTENANCE',
    work_orders.priority AS priority
      WITH SYNONYMS ('work order priority', 'service urgency')
      COMMENT = 'Priority of the work order: LOW, MEDIUM, HIGH',
    work_orders.order_status AS order_status
      WITH SYNONYMS ('work order state', 'service job status')
      COMMENT = 'Status of the work order: OPEN, CLOSED',
    technicians.technician_name AS technician_name
      WITH SYNONYMS ('field engineer name', 'assigned technician name')
      COMMENT = 'Name of the assigned service technician',
    technicians.specialization AS specialization
      WITH SYNONYMS ('technician specialty', 'field engineer expertise')
      COMMENT = 'Specialization of the technician',
    customers.customer_name AS customer_name
      WITH SYNONYMS ('serviced customer name', 'work order account name')
      COMMENT = 'Name of the customer for the work order'
  )
  METRICS (
    work_orders.total_work_orders AS COUNT(DISTINCT work_order_id)
      WITH SYNONYMS ('number of work orders', 'work order count', 'service ticket count')
      COMMENT = 'Total number of work orders',
    work_orders.avg_resolution_hours AS AVG(DATEDIFF('hour', created_date, resolution_date))
      WITH SYNONYMS ('average resolution time', 'mean time to close')
      COMMENT = 'Average time to resolve a work order in hours',
    work_orders.avg_satisfaction_score AS AVG(customer_satisfaction_score)
      WITH SYNONYMS ('average csat', 'mean customer satisfaction')
      COMMENT = 'Average customer satisfaction score for completed work orders',
    technicians.total_technicians AS COUNT(DISTINCT technician_id)
      WITH SYNONYMS ('number of technicians', 'technician count', 'field staff count')
      COMMENT = 'Total number of service technicians',
    technicians.avg_completed_orders AS AVG(total_work_orders_completed)
      WITH SYNONYMS ('average completed jobs', 'mean work orders per tech')
      COMMENT = 'Average number of work orders completed per technician'
  )
  COMMENT = 'Neptune Utility Service Intelligence - a comprehensive view of work orders, technicians, and customer service performance.';

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All semantic views created successfully' AS status;

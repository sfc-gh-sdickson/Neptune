-- ============================================================================
-- Neptune Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for Neptune water utility operations.
-- Volume: ~10K utilities, 1M customers, 1.2M meters, 5M+ readings.
-- ============================================================================

USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE NEPTUNE_WH;

-- ============================================================================
-- Step 1: Generate Meter Catalog
-- ============================================================================
INSERT INTO METER_CATALOG VALUES
-- R900 Family (AMR)
('NTG001', 'R900i', 'NTG-R900i-V1', 'R900', 'RESIDENTIAL', 250.00, 'AMR', 20, 20, 'Integrated R900 endpoint for residential applications.', 'ACTIVE', '2015-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('NTG002', 'R900 Pit', 'NTG-R900-PIT', 'R900', 'RESIDENTIAL', 220.00, 'AMR', 20, 20, 'R900 endpoint for pit applications.', 'ACTIVE', '2016-03-15', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- E-Coder Family (AMI)
('NTG010', 'E-Coder R900i', 'NTG-ECODER-R900i', 'E-CODER', 'RESIDENTIAL', 350.00, 'AMI', 20, 20, 'Solid-state absolute encoder with integrated R900i.', 'ACTIVE', '2018-05-12', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('NTG011', 'E-Coder M5', 'NTG-ECODER-M5', 'E-CODER', 'COMMERCIAL', 550.00, 'AMI', 20, 15, 'High-resolution E-Coder for commercial and industrial use.', 'ACTIVE', '2019-08-18', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- MACH 10 Family
('NTG020', 'MACH 10', 'NTG-MACH10-R', 'MACH 10', 'RESIDENTIAL', 450.00, 'ULTRASONIC', 20, 20, 'Ultrasonic water meter for residential applications.', 'ACTIVE', '2020-02-22', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('NTG021', 'MACH 10 C&I', 'NTG-MACH10-CI', 'MACH 10', 'COMMERCIAL', 850.00, 'ULTRASONIC', 20, 15, 'Ultrasonic water meter for commercial and industrial use.', 'ACTIVE', '2021-11-08', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 2: Generate Service Technicians
-- ============================================================================
INSERT INTO SERVICE_TECHNICIANS
SELECT
    'TECH' || LPAD(SEQ4(), 5, '0') AS technician_id,
    ARRAY_CONSTRUCT('Mike Miller', 'Susan Clark', 'Robert Davis', 'Linda Wilson', 'James Taylor',
                    'Patricia Moore', 'John Anderson', 'Jennifer Jackson', 'William White', 'Mary Harris')[UNIFORM(0, 9, RANDOM())] 
        || ' ' || ARRAY_CONSTRUCT('Jr.', 'Sr.', '', '', '')[UNIFORM(0, 4, RANDOM())] AS technician_name,
    'tech' || SEQ4() || '@utilityservices.com' AS email,
    ARRAY_CONSTRUCT('Installation', 'Repair', 'Leak Detection', 'AMI Specialist', 'AMR Specialist')[UNIFORM(0, 4, RANDOM())] AS specialization,
    DATEADD('day', -1 * UNIFORM(30, 3650, RANDOM()), CURRENT_DATE()) AS hire_date,
    (UNIFORM(20, 80, RANDOM()) / 10.0)::NUMBER(5,1) AS avg_resolution_time_hours,
    UNIFORM(100, 5000, RANDOM()) AS total_work_orders_completed,
    'ACTIVE' AS technician_status,
    DATEADD('day', -1 * UNIFORM(30, 3650, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- ============================================================================
-- Step 3: Generate Utilities
-- ============================================================================
INSERT INTO UTILITIES
SELECT
    'UTIL' || LPAD(SEQ4(), 6, '0') AS utility_id,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN 
            ARRAY_CONSTRUCT('Aqua Valley', 'Clearwater', 'Springfield', 'Riverside', 'Greenfield', 'Lakewood',
                           'Hillside', 'Bayview', 'Maplewood', 'Oak Ridge', 'Pinehurst', 'Cedar Creek')[UNIFORM(0, 11, RANDOM())]
            || ' Water District'
        ELSE
            ARRAY_CONSTRUCT('Tri-County', 'Metro', 'Regional', 'Municipal')[UNIFORM(0, 3, RANDOM())] || ' Water Authority'
    END AS utility_name,
    'contact' || SEQ4() || '@' || ARRAY_CONSTRUCT('utility', 'water', 'publicworks', 'waterservices')[UNIFORM(0, 3, RANDOM())] || '.gov' AS primary_contact_email,
    CONCAT('+1-', UNIFORM(200, 999, RANDOM()), '-', UNIFORM(100, 999, RANDOM()), '-', UNIFORM(1000, 9999, RANDOM())) AS primary_contact_phone,
    'USA' AS country,
    ARRAY_CONSTRUCT('CA', 'TX', 'FL', 'NY', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI')[UNIFORM(0, 9, RANDOM())] AS state,
    ARRAY_CONSTRUCT('Main', 'North', 'South', 'East', 'West', 'Central')[UNIFORM(0, 5, RANDOM())] AS city,
    DATEADD('day', -1 * UNIFORM(365, 8000, RANDOM()), CURRENT_DATE()) AS onboarding_date,
    'ACTIVE' AS utility_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'MUNICIPAL' ELSE 'PRIVATE' END AS utility_type,
    UNIFORM(5000, 1000000, RANDOM()) AS service_population,
    DATEADD('day', -1 * UNIFORM(365, 8000, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- ============================================================================
-- Step 4: Generate Customers
-- ============================================================================
INSERT INTO CUSTOMERS
SELECT
    'CUST' || LPAD(SEQ4(), 10, '0') AS customer_id,
    u.utility_id,
    'Customer ' || SEQ4() AS customer_name,
    'customer' || SEQ4() || '@emailprovider.com' AS email,
    'ACCT' || LPAD(SEQ4(), 10, '0') AS account_number,
    UNIFORM(100, 9999, RANDOM()) || ' ' || ARRAY_CONSTRUCT('Main', 'Oak', 'Pine', 'Maple', 'Cedar', 'Elm')[UNIFORM(0, 5, RANDOM())] || ' St' AS address,
    'ACTIVE' AS customer_status,
    DATEADD('day', -1 * UNIFORM(30, 7300, RANDOM()), CURRENT_DATE()) AS service_start_date,
    DATEADD('day', -1 * UNIFORM(30, 7300, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM UTILITIES u
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 100));

-- ============================================================================
-- Step 5: Generate Meter Inventory
-- ============================================================================
INSERT INTO METER_INVENTORY
SELECT
    'SN' || LPAD(SEQ8(), 12, '0') AS meter_serial_number,
    mc.meter_model_id,
    c.utility_id,
    c.customer_id,
    DATEADD('day', -1 * UNIFORM(0, 3650, RANDOM()), CURRENT_DATE()) AS installation_date,
    'DEPLOYED' as meter_status,
    DATEADD('day', -1 * UNIFORM(0, 3, RANDOM()), CURRENT_DATE()) AS last_sync_date,
    'v' || UNIFORM(1, 3, RANDOM()) || '.' || UNIFORM(0, 9, RANDOM()) AS firmware_version,
    DATEADD('day', -1 * UNIFORM(0, 3650, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM CUSTOMERS c
CROSS JOIN METER_CATALOG mc
WHERE UNIFORM(0, 100, RANDOM()) < 1.2;

-- ============================================================================
-- Step 6: Generate Meter Readings (This is a large table and will take time)
-- ============================================================================
INSERT INTO METER_READINGS
SELECT
    'READ' || LPAD(SEQ8(), 15, '0') AS reading_id,
    mi.meter_serial_number,
    mi.utility_id,
    mi.customer_id,
    DATEADD('hour', -SEQ4(), CURRENT_TIMESTAMP()) AS reading_timestamp,
    ABS(NORMAL(150, 40, RANDOM())) AS consumption_gallons,
    'HOURLY' as reading_type,
    (UNIFORM(0, 100, RANDOM()) < 2) AS anomaly_detected,
    CURRENT_TIMESTAMP() AS created_at
FROM METER_INVENTORY mi, TABLE(GENERATOR(ROWCOUNT => 4380)); -- 6 months of hourly readings


-- ============================================================================
-- Step 7: Generate Work Orders
-- ============================================================================
INSERT INTO WORK_ORDERS
SELECT
    'WO' || LPAD(SEQ4(), 12, '0') AS work_order_id,
    c.utility_id,
    c.customer_id,
    mi.meter_serial_number,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'Leak Investigation'
         WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Meter Replacement'
         WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'New Meter Installation'
         ELSE 'High Bill Complaint'
    END AS subject,
    'Customer reported a potential issue. Technician to investigate.' AS description,
    ARRAY_CONSTRUCT('INVESTIGATION', 'REPAIR', 'INSTALLATION', 'MAINTENANCE')[UNIFORM(0, 3, RANDOM())] AS order_category,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH')[UNIFORM(0, 2, RANDOM())] AS priority,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'CLOSED' ELSE 'OPEN' END AS order_status,
    DATEADD('day', -1 * UNIFORM(0, 730, RANDOM()), CURRENT_TIMESTAMP()) AS created_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN DATEADD('day', UNIFORM(1, 10, RANDOM()), created_date) ELSE NULL END AS resolution_date,
    'TECH' || LPAD(UNIFORM(1, 500, RANDOM()), 5, '0') AS assigned_technician_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN UNIFORM(3, 5, RANDOM()) ELSE NULL END AS customer_satisfaction_score,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM CUSTOMERS c
LEFT JOIN METER_INVENTORY mi ON c.customer_id = mi.customer_id
WHERE UNIFORM(0, 100, RANDOM()) < 5;

-- ============================================================================
-- Step 8: Generate Unstructured Data (Guides, Notes, Reports)
-- ============================================================================

-- INSTALLATION_GUIDES
INSERT INTO INSTALLATION_GUIDES (document_id, meter_model_id, title, document_text, document_category, publish_date, version)
SELECT
    'GUIDE' || LPAD(SEQ4(), 5, '0'),
    meter_model_id,
    model_name || ' Installation Manual',
    'Step 1: Unbox the ' || model_name || '. Step 2: Ensure all parts are present. Step 3: Follow the detailed instructions in the full manual for proper installation and safety procedures.',
    'TECHNICAL_MANUAL',
    launch_date,
    'v1.0'
FROM METER_CATALOG;

-- TECHNICIAN_NOTES (linked to work orders)
INSERT INTO TECHNICIAN_NOTES (note_id, work_order_id, technician_id, utility_id, note_text, interaction_type, note_timestamp)
SELECT
    'NOTE' || LPAD(SEQ4(), 10, '0'),
    wo.work_order_id,
    wo.assigned_technician_id,
    wo.utility_id,
    'On-site visit. ' || CASE 
        WHEN wo.subject LIKE '%Leak%' THEN 'Conducted leak detection test. Found a minor leak at the main valve. Repaired and tested. Consumption is back to normal.'
        WHEN wo.subject LIKE '%Replacement%' THEN 'Replaced old meter model with a new one. New meter serial number is SN' || LPAD(SEQ8(), 12, '0') || '. System is online and syncing.'
        ELSE 'Spoke with customer about high bill. Performed meter accuracy test. Meter is functioning within normal parameters. Advised customer on water conservation.'
    END,
    'SITE_VISIT',
    wo.resolution_date
FROM WORK_ORDERS wo
WHERE wo.order_status = 'CLOSED' AND UNIFORM(0, 100, RANDOM()) < 90;

-- LEAK_INVESTIGATION_REPORTS
INSERT INTO LEAK_INVESTIGATION_REPORTS (report_id, utility_id, meter_serial_number, report_text, investigation_status, root_cause, reported_date)
SELECT
    'LIR' || LPAD(SEQ4(), 10, '0'),
    wo.utility_id,
    wo.meter_serial_number,
    'Initial alert of high consumption triggered an investigation. Technician dispatched to site. Found evidence of a continuous underground leak on the customer side of the meter. The leak was located near the irrigation system connection.',
    'CLOSED',
    'Underground pipe failure due to age and corrosion.',
    wo.created_date
FROM WORK_ORDERS wo
WHERE wo.subject = 'Leak Investigation' and wo.order_status = 'CLOSED';


-- ============================================================================
-- Display data generation completion summary
-- ============================================================================
SELECT 'Data generation completed successfully' AS status,
       (SELECT COUNT(*) FROM UTILITIES) AS utilities,
       (SELECT COUNT(*) FROM CUSTOMERS) AS customers,
       (SELECT COUNT(*) FROM METER_INVENTORY) AS meters,
       (SELECT COUNT(*) FROM METER_READINGS) AS readings,
       (SELECT COUNT(*) FROM WORK_ORDERS) AS work_orders;

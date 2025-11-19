-- ============================================================================
-- Neptune Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for the Neptune water utility business model.
-- All columns verified against Neptune business requirements.
-- ============================================================================

USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE NEPTUNE_WH;

-- ============================================================================
-- UTILITIES TABLE (analogous to AGENCIES)
-- ============================================================================
CREATE OR REPLACE TABLE UTILITIES (
    utility_id VARCHAR(20) PRIMARY KEY,
    utility_name VARCHAR(200) NOT NULL,
    primary_contact_email VARCHAR(200) NOT NULL,
    primary_contact_phone VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    state VARCHAR(50),
    city VARCHAR(100),
    onboarding_date DATE NOT NULL,
    utility_status VARCHAR(20) DEFAULT 'ACTIVE',
    utility_type VARCHAR(30), -- e.g., Municipal, Private
    service_population NUMBER(10,0),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- CUSTOMERS TABLE (analogous to OFFICERS)
-- ============================================================================
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id VARCHAR(30) PRIMARY KEY,
    utility_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    account_number VARCHAR(50),
    address VARCHAR(255),
    customer_status VARCHAR(20) DEFAULT 'ACTIVE',
    service_start_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (utility_id) REFERENCES UTILITIES(utility_id)
);

-- ============================================================================
-- METER_CATALOG TABLE (analogous to PRODUCT_CATALOG)
-- ============================================================================
CREATE OR REPLACE TABLE METER_CATALOG (
    meter_model_id VARCHAR(30) PRIMARY KEY,
    model_name VARCHAR(200) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    meter_family VARCHAR(50) NOT NULL, -- e.g., R900, E-Coder
    meter_type VARCHAR(50), -- e.g., Residential, Commercial
    unit_price NUMBER(10,2),
    technology VARCHAR(50), -- e.g., AMR, AMI
    warranty_years NUMBER(3,0),
    expected_battery_life_years NUMBER(5,1),
    description VARCHAR(1000),
    lifecycle_status VARCHAR(30) DEFAULT 'ACTIVE',
    launch_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- METER_INVENTORY TABLE (analogous to DEVICE_DEPLOYMENTS)
-- ============================================================================
CREATE OR REPLACE TABLE METER_INVENTORY (
    meter_serial_number VARCHAR(50) PRIMARY KEY,
    meter_model_id VARCHAR(30) NOT NULL,
    utility_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(30),
    installation_date DATE,
    meter_status VARCHAR(30) DEFAULT 'IN_STOCK', -- e.g., IN_STOCK, DEPLOYED, MAINTENANCE
    last_sync_date DATE,
    firmware_version VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (meter_model_id) REFERENCES METER_CATALOG(meter_model_id),
    FOREIGN KEY (utility_id) REFERENCES UTILITIES(utility_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- METER_READINGS TABLE (analogous to EVIDENCE_UPLOADS)
-- ============================================================================
CREATE OR REPLACE TABLE METER_READINGS (
    reading_id VARCHAR(30) PRIMARY KEY,
    meter_serial_number VARCHAR(50) NOT NULL,
    utility_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(30) NOT NULL,
    reading_timestamp TIMESTAMP_NTZ NOT NULL,
    consumption_gallons NUMBER(12,4),
    reading_type VARCHAR(20), -- e.g., HOURLY, DAILY
    anomaly_detected BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (meter_serial_number) REFERENCES METER_INVENTORY(meter_serial_number),
    FOREIGN KEY (utility_id) REFERENCES UTILITIES(utility_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- SERVICE_TECHNICIANS TABLE (analogous to SUPPORT_ENGINEERS)
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_TECHNICIANS (
    technician_id VARCHAR(20) PRIMARY KEY,
    technician_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    specialization VARCHAR(100), -- e.g., Installation, Repair
    hire_date DATE,
    avg_resolution_time_hours NUMBER(5,1),
    total_work_orders_completed NUMBER(10,0) DEFAULT 0,
    technician_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- WORK_ORDERS TABLE (analogous to SUPPORT_TICKETS)
-- ============================================================================
CREATE OR REPLACE TABLE WORK_ORDERS (
    work_order_id VARCHAR(30) PRIMARY KEY,
    utility_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(30),
    meter_serial_number VARCHAR(50),
    subject VARCHAR(500) NOT NULL,
    description VARCHAR(5000),
    order_category VARCHAR(50) NOT NULL, -- e.g., Installation, Repair, Investigation
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    order_status VARCHAR(30) DEFAULT 'OPEN',
    created_date TIMESTAMP_NTZ NOT NULL,
    resolution_date TIMESTAMP_NTZ,
    assigned_technician_id VARCHAR(20),
    customer_satisfaction_score NUMBER(3,0),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (utility_id) REFERENCES UTILITIES(utility_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (meter_serial_number) REFERENCES METER_INVENTORY(meter_serial_number),
    FOREIGN KEY (assigned_technician_id) REFERENCES SERVICE_TECHNICIANS(technician_id)
);

-- ============================================================================
-- Unstructured Data Tables for Cortex Search
-- ============================================================================

-- INSTALLATION_GUIDES (analogous to POLICY_DOCUMENTS)
CREATE OR REPLACE TABLE INSTALLATION_GUIDES (
    document_id VARCHAR(30) PRIMARY KEY,
    meter_model_id VARCHAR(30),
    title VARCHAR(200) NOT NULL,
    document_text VARCHAR,
    document_category VARCHAR(50),
    publish_date DATE,
    version VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (meter_model_id) REFERENCES METER_CATALOG(meter_model_id)
);
ALTER TABLE INSTALLATION_GUIDES SET CHANGE_TRACKING = TRUE;


-- TECHNICIAN_NOTES (analogous to SUPPORT_TRANSCRIPTS)
CREATE OR REPLACE TABLE TECHNICIAN_NOTES (
    note_id VARCHAR(30) PRIMARY KEY,
    work_order_id VARCHAR(30) NOT NULL,
    technician_id VARCHAR(20),
    utility_id VARCHAR(20),
    note_text VARCHAR,
    interaction_type VARCHAR(50), -- e.g., Phone Call, Site Visit
    note_timestamp TIMESTAMP_NTZ,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (work_order_id) REFERENCES WORK_ORDERS(work_order_id),
    FOREIGN KEY (technician_id) REFERENCES SERVICE_TECHNICIANS(technician_id),
    FOREIGN KEY (utility_id) REFERENCES UTILITIES(utility_id)
);
ALTER TABLE TECHNICIAN_NOTES SET CHANGE_TRACKING = TRUE;


-- LEAK_INVESTIGATION_REPORTS (analogous to INCIDENT_REPORTS)
CREATE OR REPLACE TABLE LEAK_INVESTIGATION_REPORTS (
    report_id VARCHAR(30) PRIMARY KEY,
    utility_id VARCHAR(20) NOT NULL,
    meter_serial_number VARCHAR(50),
    report_text VARCHAR,
    investigation_status VARCHAR(30) DEFAULT 'OPEN',
    root_cause VARCHAR(1000),
    reported_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (utility_id) REFERENCES UTILITIES(utility_id),
    FOREIGN KEY (meter_serial_number) REFERENCES METER_INVENTORY(meter_serial_number)
);
ALTER TABLE LEAK_INVESTIGATION_REPORTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;

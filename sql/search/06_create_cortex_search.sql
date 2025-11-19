-- ============================================================================
-- Neptune Intelligence Agent - Cortex Search Services
-- ============================================================================
-- Purpose: Create Cortex Search services for unstructured data.
-- All syntax VERIFIED against official documentation.
-- ============================================================================

USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE NEPTUNE_WH;

-- ============================================================================
-- 1. Technician Notes Search Service
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TECHNICIAN_NOTES_SEARCH
    ON note_text
    ATTRIBUTES work_order_id, technician_id, utility_id, interaction_type
    WAREHOUSE = NEPTUNE_WH
    TARGET_LAG = '5 minutes'
    AS
    SELECT note_id, work_order_id, technician_id, utility_id, note_text, interaction_type
    FROM TECHNICIAN_NOTES;

-- ============================================================================
-- 2. Installation Guides Search Service
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE INSTALLATION_GUIDES_SEARCH
    ON document_text
    ATTRIBUTES meter_model_id, document_category, title
    WAREHOUSE = NEPTUNE_WH
    TARGET_LAG = '5 minutes'
    AS
    SELECT document_id, meter_model_id, document_text, document_category, title
    FROM INSTALLATION_GUIDES;

-- ============================================================================
-- 3. Leak Investigation Reports Search Service
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE LEAK_INVESTIGATION_REPORTS_SEARCH
    ON report_text
    ATTRIBUTES utility_id, meter_serial_number, investigation_status
    WAREHOUSE = NEPTUNE_WH
    TARGET_LAG = '5 minutes'
    AS
    SELECT report_id, utility_id, meter_serial_number, report_text, investigation_status
    FROM LEAK_INVESTIGATION_REPORTS;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All Cortex Search services created successfully' AS status;

-- ============================================================================
-- Neptune Intelligence Agent - Data Patch for ML Model Training
-- ============================================================================
-- Purpose: This script applies a fast, targeted fix to the METER_INVENTORY
--          table to create data variance needed for the deployment success model.
--          This avoids having to re-run the entire data generation process.
-- ============================================================================

USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE NEPTUNE_WH;

-- Update a random 30% of meters to have an older last_sync_date.
-- This will create "unsuccessful" examples for the ML model.
UPDATE RAW.METER_INVENTORY
SET
    last_sync_date = DATEADD('day', -1 * UNIFORM(100, 365, RANDOM()), CURRENT_DATE())
WHERE UNIFORM(0, 100, RANDOM()) < 30;

-- Update a random 10% of meters to have a non-deployed status.
-- This will also create "unsuccessful" examples for the ML model.
UPDATE RAW.METER_INVENTORY
SET
    meter_status = CASE 
                        WHEN UNIFORM(0, 1, RANDOM()) > 0.5 THEN 'MAINTENANCE'
                        ELSE 'IN_STOCK'
                   END
WHERE UNIFORM(0, 100, RANDOM()) < 10;

SELECT 'Data patch applied successfully. You can now re-run the notebook.' AS status;

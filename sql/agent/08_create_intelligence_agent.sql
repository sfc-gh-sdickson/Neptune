-- ============================================================================
-- Neptune Intelligence Agent - Create Snowflake Intelligence Agent (Full Version)
-- ============================================================================
-- Purpose: Create and configure the Snowflake Intelligence Agent with all tools.
-- Execution: Run this after completing steps 01-07.
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NEPTUNE_WH;

-- ============================================================================
-- Step 1: Grant Required Permissions
-- ============================================================================
-- Replace <your_role> with the role you will use to chat with the agent
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE SYSADMIN;
GRANT USAGE ON DATABASE NEPTUNE_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA NEPTUNE_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA NEPTUNE_INTELLIGENCE.RAW TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE NEPTUNE_WH TO ROLE SYSADMIN;

-- Grant privileges on semantic views
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NEPTUNE_INTELLIGENCE.ANALYTICS.SV_METER_OPERATIONS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NEPTUNE_INTELLIGENCE.ANALYTICS.SV_UTILITY_SERVICE_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.TECHNICIAN_NOTES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.INSTALLATION_GUIDES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.LEAK_INVESTIGATION_REPORTS_SEARCH TO ROLE SYSADMIN;

-- Grant usage on ML model wrapper procedures
GRANT USAGE ON PROCEDURE NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_CONSUMPTION_VOLUME(INT) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_UTILITY_CHURN(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_DEPLOYMENT_SUCCESS(VARCHAR) TO ROLE SYSADMIN;

-- ============================================================================
-- Step 2: Create or Replace the Snowflake Intelligence Agent
-- ============================================================================
CREATE OR REPLACE AGENT NEPTUNE_INTELLIGENCE_AGENT
  COMMENT = 'Neptune Intelligence Agent for water utility business intelligence'
AS
$$
instructions:
  response: |
    You are a specialized analytics assistant for Neptune Technology Group, a leading water utility technology provider. 
    - For structured data queries (consumption, meter performance, work orders), use the Cortex Analyst semantic views. Provide direct, numerical answers with relevant units (e.g., gallons, days).
    - For unstructured technical content (technician notes, installation guides, leak reports), use Cortex Search services to find relevant procedures and investigation details. Summarize findings in brief, focused responses.
    - For predictive questions (forecasting, churn, success probability), use the appropriate ML model procedures.
    - Always identify which tool you are using (Cortex Analyst, Cortex Search, or an ML model). Keep responses concise.
  sample_questions:
    - "What is the total water consumption for municipal utilities in California for the last quarter?"
    - "Which meter models have the highest anomaly rates?"
    - "Search technician notes for issues related to the R900 meter family."
    - "Forecast water consumption for the next 6 months."
    - "Which utilities are at the highest risk of churn?"
tools:
  - tool_spec:
      type: cortex_analyst
      name: MeterOperationsAnalyst
      description: "Analyzes meter deployments, water consumption, anomalies, and meter performance across utilities and customers."
      semantic_view: "NEPTUNE_INTELLIGENCE.ANALYTICS.SV_METER_OPERATIONS_INTELLIGENCE"
  - tool_spec:
      type: cortex_analyst
      name: UtilityServiceAnalyst
      description: "Analyzes work orders, service technician performance, and customer satisfaction metrics."
      semantic_view: "NEPTUNE_INTELLIGENCE.ANALYTICS.SV_UTILITY_SERVICE_INTELLIGENCE"
  - tool_spec:
      type: cortex_search
      name: TechnicianNotesSearch
      description: "Searches technician notes from work orders for troubleshooting procedures, repair details, and common field issues."
      search_service: "NEPTUNE_INTELLIGENCE.RAW.TECHNICIAN_NOTES_SEARCH"
  - tool_spec:
      type: cortex_search
      name: InstallationGuidesSearch
      description: "Searches installation manuals for Neptune meter models to find setup procedures, required tools, and safety guidelines."
      search_service: "NEPTUNE_INTELLIGENCE.RAW.INSTALLATION_GUIDES_SEARCH"
  - tool_spec:
      type: cortex_search
      name: LeakInvestigationSearch
      description: "Searches detailed reports from leak investigations to find root causes and common points of failure."
      search_service: "NEPTUNE_INTELLIGENCE.RAW.LEAK_INVESTIGATION_REPORTS_SEARCH"
  - tool_spec:
      type: procedure
      name: PredictConsumption
      description: "Predicts future water consumption volume for capacity and resource planning."
      procedure: "NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_CONSUMPTION_VOLUME(MONTHS_AHEAD => :months_ahead)"
      input_schema:
        type: object
        properties:
          months_ahead:
            type: integer
            description: "Number of months to forecast (e.g., 6)"
  - tool_spec:
      type: procedure
      name: PredictChurn
      description: "Predicts which utilities are at risk of churning based on their operational patterns."
      procedure: "NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_UTILITY_CHURN(UTILITY_TYPE_FILTER => :utility_type_filter)"
      input_schema:
        type: object
        properties:
          utility_type_filter:
            type: string
            description: "Filter by utility type (e.g., 'MUNICIPAL', 'PRIVATE') or empty for all."
  - tool_spec:
      type: procedure
      name: PredictDeploymentSuccess
      description: "Predicts the success rate of meter deployments for a given product family."
      procedure: "NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_DEPLOYMENT_SUCCESS(METER_FAMILY_FILTER => :meter_family_filter)"
      input_schema:
        type: object
        properties:
          meter_family_filter:
            type: string
            description: "Filter by meter family (e.g., 'R900', 'E-CODER') or empty for all."
$$;

-- ============================================================================
-- Step 3: Verify Agent Creation and Grant Usage
-- ============================================================================
SHOW AGENTS LIKE 'NEPTUNE_INTELLIGENCE_AGENT';
DESCRIBE AGENT NEPTUNE_INTELLIGENCE_AGENT;
GRANT USAGE ON AGENT NEPTUNE_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

SELECT 'Neptune Intelligence Agent created successfully! Access it in Snowsight under AI & ML > Agents' AS status;

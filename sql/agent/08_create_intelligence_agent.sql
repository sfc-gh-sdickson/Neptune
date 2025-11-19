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
-- Replace SYSADMIN with the role you will use to chat with the agent
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE SYSADMIN;
GRANT USAGE ON DATABASE NEPTUNE_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA NEPTUNE_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA NEPTUNE_INTELLIGENCE.RAW TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE NEPTUNE_WH TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NEPTUNE_INTELLIGENCE.ANALYTICS.SV_METER_OPERATIONS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NEPTUNE_INTELLIGENCE.ANALYTICS.SV_UTILITY_SERVICE_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.TECHNICIAN_NOTES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.INSTALLATION_GUIDES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.LEAK_INVESTIGATION_REPORTS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_CONSUMPTION_VOLUME(INT) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_UTILITY_CHURN(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_DEPLOYMENT_SUCCESS(VARCHAR) TO ROLE SYSADMIN;

-- ============================================================================
-- Step 2: Create or Replace the Snowflake Intelligence Agent
-- ============================================================================
CREATE OR REPLACE AGENT NEPTUNE_INTELLIGENCE_AGENT
  COMMENT = 'Neptune Intelligence Agent for water utility business intelligence'
  FROM SPECIFICATION
$$
models:
  orchestration: auto
orchestration:
  budget:
    seconds: 60
    tokens: 32000
instructions:
  response: 'You are a specialized analytics assistant for Neptune Technology Group. For structured data queries use Cortex Analyst semantic views. For unstructured content use Cortex Search services. For predictions use ML model procedures. Keep responses concise and data-driven.'
  orchestration: 'For metrics and KPIs use Cortex Analyst tools. For technician notes, installation guides, and leak reports use Cortex Search tools. For forecasting use ML function tools.'
  system: 'You help analyze water utility data including meter deployments, water consumption, service work orders, and customer satisfaction using structured and unstructured data sources.'
  sample_questions:
    - question: "What is the total water consumption in gallons for 'MUNICIPAL' utilities in 'CA' over the last 6 months?"
      answer: "I will use the MeterOperationsAnalyst to find this information."
    - question: "Which 5 meter models have the highest rate of reported anomalies?"
      answer: "I will use the MeterOperationsAnalyst to find anomaly rates per meter model."
    - question: "What is the average work order resolution time in hours for 'HIGH' priority tickets?"
      answer: "I will use the UtilityServiceAnalyst to calculate resolution times."
    - question: "List the top 10 customers by total water consumption."
      answer: "I will use the MeterOperationsAnalyst to rank customers by consumption."
    - question: "How many meters are currently in 'MAINTENANCE' status, and what is their average age in days?"
      answer: "I will use the MeterOperationsAnalyst to count meters in maintenance."
    - question: "Search technician notes for common solutions to issues with the 'R900' meter family."
      answer: "I will use the TechnicianNotesSearch tool to find notes about the R900 family."
    - question: "What do the installation guides say about the required tools for a 'MACH 10' meter installation?"
      answer: "I will use the InstallationGuidesSearch tool to look up this information."
    - question: "Find leak investigation reports where the root cause was identified as 'pipe corrosion'."
      answer: "I will use the LeakInvestigationSearch tool to find reports about pipe corrosion."
    - question: "Search technician notes related to 'high bill complaints.' What are the common findings reported by technicians?"
      answer: "I will use the TechnicianNotesSearch tool to find common findings for high bill complaints."
    - question: "According to the installation guides, what are the safety procedures for replacing a meter battery?"
      answer: "I will use the InstallationGuidesSearch tool to find safety procedures."
    - question: "Forecast the total water consumption for the next 6 months."
      answer: "I will use the PredictConsumption ML model to predict future water usage."
    - question: "Which 'MUNICIPAL' utilities are predicted to churn?"
      answer: "I will use the PredictChurn ML model to identify at-risk utilities."
    - question: "What is the predicted deployment success rate for the 'E-CODER' meter family?"
      answer: "I will use the PredictDeploymentSuccess ML model to calculate the success rate."
    - question: "Project the water consumption for 3 months from now."
      answer: "I will use the PredictConsumption ML model to forecast for 3 months."
    - question: "What is the churn risk for 'PRIVATE' utilities?"
      answer: "I will use the PredictChurn ML model to assess the risk for private utilities."
tools:
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'MeterOperationsAnalyst'
      description: 'Analyzes meter deployments, water consumption, anomalies, and meter performance across utilities and customers'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'UtilityServiceAnalyst'
      description: 'Analyzes work orders, service technician performance, and customer satisfaction metrics'
  - tool_spec:
      type: 'cortex_search'
      name: 'TechnicianNotesSearch'
      description: 'Searches technician notes from work orders for troubleshooting procedures, repair details, and common field issues'
  - tool_spec:
      type: 'cortex_search'
      name: 'InstallationGuidesSearch'
      description: 'Searches installation manuals for Neptune meter models to find setup procedures and safety guidelines'
  - tool_spec:
      type: 'cortex_search'
      name: 'LeakInvestigationSearch'
      description: 'Searches detailed reports from leak investigations to find root causes and common points of failure'
  - tool_spec:
      type: 'generic'
      name: 'PredictConsumption'
      description: 'Predicts future water consumption volume for capacity and resource planning'
      input_schema:
        type: 'object'
        properties:
          months_ahead:
            type: 'integer'
            description: 'Number of months to forecast (e.g., 6)'
        required: ['months_ahead']
  - tool_spec:
      type: 'generic'
      name: 'PredictChurn'
      description: 'Predicts which utilities are at risk of churning based on their operational patterns'
      input_schema:
        type: 'object'
        properties:
          utility_type_filter:
            type: 'string'
            description: "Filter by utility type (e.g., 'MUNICIPAL', 'PRIVATE') or empty for all."
        required: ['utility_type_filter']
  - tool_spec:
      type: 'generic'
      name: 'PredictDeploymentSuccess'
      description: 'Predicts the success rate of meter deployments for a given product family'
      input_schema:
        type: 'object'
        properties:
          meter_family_filter:
            type: 'string'
            description: "Filter by meter family (e.g., 'R900', 'E-CODER') or empty for all."
        required: ['meter_family_filter']
tool_resources:
  MeterOperationsAnalyst:
    semantic_view: 'NEPTUNE_INTELLIGENCE.ANALYTICS.SV_METER_OPERATIONS_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NEPTUNE_WH'
  UtilityServiceAnalyst:
    semantic_view: 'NEPTUNE_INTELLIGENCE.ANALYTICS.SV_UTILITY_SERVICE_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NEPTUNE_WH'
  TechnicianNotesSearch:
    search_service: 'NEPTUNE_INTELLIGENCE.RAW.TECHNICIAN_NOTES_SEARCH'
    max_results: 10
  InstallationGuidesSearch:
    search_service: 'NEPTUNE_INTELLIGENCE.RAW.INSTALLATION_GUIDES_SEARCH'
    max_results: 5
  LeakInvestigationSearch:
    search_service: 'NEPTUNE_INTELLIGENCE.RAW.LEAK_INVESTIGATION_REPORTS_SEARCH'
    max_results: 10
  PredictConsumption:
    type: 'procedure'
    identifier: 'NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_CONSUMPTION_VOLUME'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NEPTUNE_WH'
  PredictChurn:
    type: 'procedure'
    identifier: 'NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_UTILITY_CHURN'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NEPTUNE_WH'
  PredictDeploymentSuccess:
    type: 'procedure'
    identifier: 'NEPTUNE_INTELLIGENCE.ANALYTICS.PREDICT_DEPLOYMENT_SUCCESS'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NEPTUNE_WH'
$$;

-- ============================================================================
-- Step 3: Verify Agent Creation and Grant Usage
-- ============================================================================
SHOW AGENTS LIKE 'NEPTUNE_INTELLIGENCE_AGENT';
DESCRIBE AGENT NEPTUNE_INTELLIGENCE_AGENT;
GRANT USAGE ON AGENT NEPTUNE_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

SELECT 'Neptune Intelligence Agent created successfully! Access it in Snowsight under AI & ML > Agents' AS status;

<img src="../Snowflake_Logo.svg" width="200">

# Neptune Intelligence Agent - Setup Guide

This guide walks through configuring a Snowflake Intelligence agent for Neptune's water utility business intelligence solution, covering meter deployments, consumption analytics, service operations, and customer satisfaction.

---

## Prerequisites

1.  **Snowflake Account** with:
    -   Snowflake Intelligence (Cortex) enabled
    -   Appropriate warehouse size (recommended: X-SMALL or larger)
    -   Permissions to create databases, schemas, tables, and semantic views

2.  **Roles and Permissions**:
    -   `ACCOUNTADMIN` role or equivalent for initial setup

---

## Step 1: Execute SQL Scripts in Order

Execute the SQL files in the following sequence using Snowsight worksheets.

### 1.1 Database Setup
```sql
-- Execute: sql/setup/01_database_and_schema.sql
-- Creates database, schemas (RAW, ANALYTICS), and warehouse
-- Execution time: < 1 second
```

### 1.2 Create Tables
```sql
-- Execute: sql/setup/02_create_tables.sql
-- Creates all table structures with proper relationships for the Neptune data model.
-- Execution time: < 5 seconds
```

### 1.3 Generate Sample Data
```sql
-- Execute: sql/data/03_generate_synthetic_data.sql
-- Generates realistic sample data for utilities, customers, meters, and readings.
-- Execution time: 10-20 minutes (depending on warehouse size)
```

### 1.4 Create Analytical Views
```sql
-- Execute: sql/views/04_create_views.sql
-- Creates curated analytical views (e.g., V_UTILITY_360, V_METER_PERFORMANCE).
-- Execution time: < 5 seconds
```

### 1.5 Create Semantic Views
```sql
-- Execute: sql/views/05_create_semantic_views.sql
-- Creates semantic views for AI agents (VERIFIED SYNTAX):
--   - SV_METER_OPERATIONS_INTELLIGENCE
--   - SV_UTILITY_SERVICE_INTELLIGENCE
-- Execution time: < 5 seconds
```

### 1.6 Create Cortex Search Services
```sql
-- Execute: sql/search/06_create_cortex_search.sql
-- Creates tables and Cortex Search services for unstructured data:
--   - TECHNICIAN_NOTES_SEARCH
--   - INSTALLATION_GUIDES_SEARCH
--   - LEAK_INVESTIGATION_REPORTS_SEARCH
-- Execution time: 5-10 minutes (data generation + index building)
```

---

## Step 2: Grant Cortex Analyst Permissions

Configure permissions for the role that will use the agent.

```sql
USE ROLE ACCOUNTADMIN;

-- Grant Cortex Analyst user role
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE <your_role>;

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE NEPTUNE_INTELLIGENCE TO ROLE <your_role>;
GRANT USAGE ON SCHEMA NEPTUNE_INTELLIGENCE.ANALYTICS TO ROLE <your_role>;
GRANT USAGE ON SCHEMA NEPTUNE_INTELLIGENCE.RAW TO ROLE <your_role>;

-- Grant privileges on semantic views
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NEPTUNE_INTELLIGENCE.ANALYTICS.SV_METER_OPERATIONS_INTELLIGENCE TO ROLE <your_role>;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NEPTUNE_INTELLIGENCE.ANALYTICS.SV_UTILITY_SERVICE_INTELLIGENCE TO ROLE <your_role>;

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE NEPTUNE_WH TO ROLE <your_role>;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.TECHNICIAN_NOTES_SEARCH TO ROLE <your_role>;
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.INSTALLATION_GUIDES_SEARCH TO ROLE <your_role>;
GRANT USAGE ON CORTEX SEARCH SERVICE NEPTUNE_INTELLIGENCE.RAW.LEAK_INVESTIGATION_REPORTS_SEARCH TO ROLE <your_role>;
```

---

## Step 3: Create Snowflake Intelligence Agent

### 3.1: Create the Agent

1.  In Snowsight, click on **AI & ML** > **Agents**
2.  Click on **Create Agent**
3.  Configure:
    -   **Agent Object Name**: `NEPTUNE_INTELLIGENCE_AGENT`
    -   **Display Name**: `Neptune Intelligence Agent`
4.  Click **Create**

### 3.2: Add Description and Instructions

1.  Click on your new agent to open it.
2.  Click **Edit** in the top right corner.
3.  In the **Description** section, add:
    ```
    This agent orchestrates between Neptune's water utility business data for analyzing structured metrics (Cortex Analyst) and unstructured technical content (Cortex Search).
    ```

### 3.3: Configure Response Instructions

1.  Click on **Instructions** in the left pane.
2.  Enter the following **Response Instructions**:
    ```
    You are a specialized analytics assistant for Neptune Technology Group, a leading water utility technology provider. Your primary objectives are:

    For structured data queries (consumption, meter performance, work orders):
    - Use the Cortex Analyst semantic views.
    - Provide direct, numerical answers with minimal explanation.
    - Format responses clearly with relevant units (e.g., gallons, days).

    For unstructured technical content (technician notes, installation guides, leak reports):
    - Use Cortex Search services to find relevant procedures and investigation details.
    - Summarize technical findings in brief, focused responses.

    Operating guidelines:
    - Always identify whether you're using Cortex Analyst or Cortex Search.
    - Keep responses concise.
    - Don't speculate beyond available data.
    ```
3.  **Add Sample Questions**:
    - "Which meter models have the highest anomaly rates?"
    - "What is the average work order resolution time for leak investigations?"
    - "Search technician notes for issues related to the R900 meter family."

---

### 3.4: Add Cortex Analyst Tools (Semantic Views)

1.  Click on **Tools** in the left pane.
2.  Find **Cortex Analyst** and click **+ Add**.

**Add Semantic View 1: Meter Operations Intelligence**

1.  **Select semantic view**: `NEPTUNE_INTELLIGENCE.ANALYTICS.SV_METER_OPERATIONS_INTELLIGENCE`
2.  **Add a description**:
    ```
    Contains data on utilities, customers, meters, and consumption readings. Use for queries about:
    - Meter deployment analysis and meter age
    - Water consumption patterns and anomalies (leaks)
    - Meter performance by model and technology (AMR/AMI)
    - Utility and customer water usage metrics
    ```
3.  **Save**

**Add Semantic View 2: Utility Service Intelligence**

1.  Click **+ Add** for another Cortex Analyst tool.
2.  **Select semantic view**: `NEPTUNE_INTELLIGENCE.ANALYTICS.SV_UTILITY_SERVICE_INTELLIGENCE`
3.  **Add a description**:
    ```
    Contains data on work orders, service technicians, and customer satisfaction. Use for queries about:
    - Work order volumes and resolution times
    - Customer satisfaction scores by utility and work order type
    - Technician performance and specialization
    - Common service issues (e.g., leaks, replacements)
    ```
4.  **Save**

---

### 3.5: Add Cortex Search Tools (Unstructured Data)

1.  While still in **Tools**, find **Cortex Search** and click **+ Add**.

**Add Cortex Search 1: Technician Notes**

1.  **Select Cortex Search Service**: `NEPTUNE_INTELLIGENCE.RAW.TECHNICIAN_NOTES_SEARCH`
2.  **Add a description**:
    ```
    Search technician notes from completed work orders for troubleshooting procedures and solutions. Use for queries about:
    - Leak detection and repair methods
    - Meter replacement procedures
    - Resolving high bill complaints
    - Common issues found during site visits
    ```
3.  **Save**

**Add Cortex Search 2: Installation Guides**

1.  Click **+ Add** for another Cortex Search tool.
2.  **Select Cortex Search Service**: `NEPTUNE_INTELLIGENCE.RAW.INSTALLATION_GUIDES_SEARCH`
3.  **Add a description**:
    ```
    Search installation manuals for Neptune meter models. Use for queries about:
    - Installation steps for R900, E-Coder, or MACH 10 meters
    - Safety procedures during installation
    - Required tools and parts
    ```
4.  **Save**

**Add Cortex Search 3: Leak Investigation Reports**

1.  Click **+ Add** for another Cortex Search tool.
2.  **Select Cortex Search Service**: `NEPTUNE_INTELLIGENCE.RAW.LEAK_INVESTIGATION_REPORTS_SEARCH`
3.  **Add a description**:
    ```
    Search detailed reports from leak investigations. Use for queries about:
    - Root causes of underground leaks
    - Common points of failure in pipes or connections
    - Methods used to confirm and locate leaks
    ```
4.  **Save**

---

## Step 4: Test the Agent

Use the questions from `docs/questions.md` or try the sample questions you added to test the agent's ability to query both structured and unstructured data.

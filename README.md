<img src="Snowflake_Logo.svg" width="300">

# Neptune Intelligence Agent Solution

## About Neptune Technology Group

Neptune Technology Group is a leader in the water utility industry, providing innovative solutions for water metering, data collection, and utility management. Their product portfolio includes advanced water meters (like the R900 and MACH 10), AMI/AMR network infrastructure, and software for data analytics and billing.

### Key Product Lines

- **Smart Meters**: R900 family, E-Coder encoders, MACH 10 ultrasonic meters
- **Data Collectors**: Mobile and network-based data collection hardware
- **Network Infrastructure**: AMI (Advanced Metering Infrastructure) and AMR (Automatic Meter Reading) solutions
- **Software Solutions**: Neptune 360 for data management and analytics

### Market Position

- Leading provider of water metering technology in North America
- Strong partnerships with municipal and private water utilities
- Comprehensive ecosystem for water data management from meter to billing

## Project Overview

This Snowflake Intelligence solution demonstrates how Neptune can leverage AI agents to analyze:

- **Meter Deployment Intelligence**: Meter age, firmware versions, deployment status
- **Water Consumption Analytics**: Usage patterns, anomaly detection for leaks, forecasting
- **Utility Health**: Customer satisfaction, work order efficiency, meter performance
- **Service Operations**: Work order resolution times, technician performance, issue patterns
- **Unstructured Data Search**: Semantic search over technician notes, installation guides, and leak investigation reports using Cortex Search

## Database Schema

The solution includes:

1.  **RAW Schema**: Core business tables
    -   UTILITIES: Water utilities (customers)
    -   CUSTOMERS: End-users of water services
    -   METER_CATALOG: Neptune meter models and specifications
    -   METER_INVENTORY: Deployed meters with serial numbers and status
    -   METER_READINGS: Time-series consumption data
    -   WORK_ORDERS: Service and maintenance tickets
    -   SERVICE_TECHNICIANS: Field technicians
    -   TECHNICIAN_NOTES: Unstructured notes from work orders (for Cortex Search)
    -   INSTALLATION_GUIDES: Unstructured product manuals (for Cortex Search)
    -   LEAK_INVESTIGATION_REPORTS: Unstructured reports from leak investigations (for Cortex Search)

2.  **ANALYTICS Schema**: Curated views and semantic models
    -   Utility 360 views
    -   Customer consumption analytics
    -   Meter performance metrics
    -   Work order efficiency analysis
    -   Semantic views for AI agents

3.  **Cortex Search Services**: Semantic search over unstructured data
    -   TECHNICIAN_NOTES_SEARCH: Search technician field notes
    -   INSTALLATION_GUIDES_SEARCH: Search product installation manuals
    -   LEAK_INVESTIGATION_REPORTS_SEARCH: Search leak investigation findings

## Files

### Core Files
- `README.md`: This comprehensive solution documentation
- `docs/AGENT_SETUP.md`: Complete agent configuration instructions
- `docs/questions.md`: Complex test questions for the agent

### SQL Files
- `sql/setup/01_database_and_schema.sql`: Database and schema creation
- `sql/setup/02_create_tables.sql`: Table definitions with proper constraints
- `sql/data/03_generate_synthetic_data.sql`: Realistic water utility sample data
- `sql/views/04_create_views.sql`: Analytical views
- `sql/views/05_create_semantic_views.sql`: Semantic views for AI agents (verified syntax)
- `sql/search/06_create_cortex_search.sql`: Unstructured data tables and Cortex Search services
- `sql/ml/07_create_model_wrapper_functions.sql`: ML model wrapper procedures (optional)
- `sql/agent/08_create_intelligence_agent.sql`: **Create Snowflake Intelligence Agent (full version with ML)**
- `sql/agent/08_create_intelligence_agent_no_ml.sql`: **Create Snowflake Intelligence Agent (simplified, no ML)**

### ML Models (Optional)
- `notebooks/neptune_ml_models.ipynb`: Snowflake Notebook for training ML models

## Setup Instructions

### Quick Start (Simplified Agent - No ML)
```sql
-- Execute in order:
-- 1. Run sql/setup/01_database_and_schema.sql
-- 2. Run sql/setup/02_create_tables.sql
-- 3. Run sql/data/03_generate_synthetic_data.sql (10-20 min)
-- 4. Run sql/views/04_create_views.sql
-- 5. Run sql/views/05_create_semantic_views.sql
-- 6. Run sql/search/06_create_cortex_search.sql (5-10 min)
-- 7. Run sql/agent/08_create_intelligence_agent_no_ml.sql
-- 8. Access agent in Snowsight: AI & ML > Agents > NEPTUNE_INTELLIGENCE_AGENT
```

### Complete Setup (Full Agent with ML)
```sql
-- Execute quick start steps 1-6, then:
-- 7. Upload and run notebooks/neptune_ml_models.ipynb in Snowflake
-- 8. Run sql/ml/07_create_model_wrapper_functions.sql
-- 9. Run sql/agent/08_create_intelligence_agent.sql
-- 10. Access agent in Snowsight: AI & ML > Agents > NEPTUNE_INTELLIGENCE_AGENT
```

### Detailed Instructions
- See **docs/AGENT_SETUP.md** for step-by-step configuration guide
- See **sql/agent/README.md** for agent creation options
- Test with questions from **docs/questions.md**

## Syntax Verification

All SQL syntax has been verified against official Snowflake documentation:

- **CREATE SEMANTIC VIEW**: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- **CREATE CORTEX SEARCH SERVICE**: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search

---

**NO GUESSING - ALL SYNTAX VERIFIED** ✅
**NO DUPLICATE SYNONYMS - ALL GLOBALLY UNIQUE** ✅

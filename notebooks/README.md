# Neptune ML Models - Snowflake Notebook

This directory contains the Jupyter notebook for training and registering ML models to the Snowflake Model Registry.

## Files

- **`neptune_ml_models.ipynb`** - Main notebook with 3 ML models:
  - Consumption Forecasting (Linear Regression)
  - Utility Churn Prediction (Random Forest)
  - Meter Deployment Success (Logistic Regression)

- **`environment.yml`** - Conda environment specification with required packages

---

## Setup Instructions

### Option 1: Using environment.yml (Recommended)

1.  **Upload to Snowflake:**
    -   In Snowsight → Projects → Notebooks
    -   Click **+ Notebook** → **Import .ipynb file**
    -   Upload `neptune_ml_models.ipynb`

2.  **Configure Environment:**
    -   In the notebook, click **Packages** (top right)
    -   Click **Upload environment file**
    -   Upload `environment.yml`
    -   Click **Apply**

3.  **Set Database Context:**
    -   Database: `NEPTUNE_INTELLIGENCE`
    -   Schema: `ANALYTICS`
    -   Warehouse: `NEPTUNE_WH`

4.  **Run the Notebook:**
    -   Click **Run All** or execute cells sequentially

---

## Models Trained

### 1. Consumption Forecasting
- **Algorithm:** Linear Regression
- **Purpose:** Predict monthly water consumption
- **Registry Name:** `CONSUMPTION_FORECASTER`

### 2. Utility Churn Prediction
- **Algorithm:** Random Forest Classifier
- **Purpose:** Identify utilities at risk of churning
- **Registry Name:** `UTILITY_CHURN_PREDICTOR`

### 3. Meter Deployment Success
- **Algorithm:** Logistic Regression
- **Purpose:** Predict if meter deployments will be successful
- **Registry Name:** `DEPLOYMENT_SUCCESS_PREDICTOR`

---

## After Training Models

Once models are trained and registered:

1.  **Create ML Wrapper Procedures:**
    ```sql
    -- Run this SQL file:
    @sql/ml/07_create_model_wrapper_functions.sql
    ```

2.  **Add to Intelligence Agent:**
    ```sql
    -- Use the pre-configured SQL for the full agent:
    @sql/agent/08_create_intelligence_agent.sql
    ```

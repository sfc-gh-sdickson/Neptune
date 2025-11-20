-- ============================================================================
-- Neptune Intelligence Agent - ML Model Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL procedures that wrap Model Registry models so they can be
--          added as tools to the Intelligence Agent.
-- ============================================================================

USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NEPTUNE_WH;

-- ============================================================================
-- Procedure 1: Water Consumption Forecast Wrapper
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_CONSUMPTION_VOLUME(
    MONTHS_AHEAD INT
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_consumption'
COMMENT = 'Calls CONSUMPTION_FORECASTER model from Model Registry to forecast water consumption'
AS
$$
def predict_consumption(session, months_ahead):
    from snowflake.ml.registry import Registry
    import json
    
    reg = Registry(session)
    model = reg.get_model("CONSUMPTION_FORECASTER").default
    
    # Create a feature DataFrame for the future month
    feature_query = f"""
    SELECT
        MONTH(DATEADD('month', {months_ahead}, CURRENT_DATE())) AS month_num,
        YEAR(DATEADD('month', {months_ahead}, CURRENT_DATE())) AS year_num,
        (SELECT AVG(active_meters) FROM (
            SELECT COUNT(DISTINCT meter_serial_number) AS active_meters
            FROM RAW.METER_READINGS
            WHERE reading_timestamp >= DATEADD('month', -6, CURRENT_DATE())
            GROUP BY DATE_TRUNC('month', reading_timestamp)
        ))::FLOAT AS active_meters,
        (SELECT COUNT(DISTINCT utility_id) FROM RAW.UTILITIES WHERE utility_status = 'ACTIVE')::FLOAT AS active_utilities
    """
    
    input_df = session.sql(feature_query)
    
    predictions = model.run(input_df, function_name="predict")
    result = predictions.select("PREDICTED_CONSUMPTION").to_pandas()
    
    predicted_volume = int(result['PREDICTED_CONSUMPTION'].iloc[0])
    
    # Add a floor to prevent negative predictions.
    predicted_volume = max(0, predicted_volume)
    
    return json.dumps({
        "months_ahead": months_ahead,
        "predicted_consumption_gallons": predicted_volume
    })
$$;

-- ============================================================================
-- Procedure 2: Utility Churn Prediction Wrapper
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_UTILITY_CHURN(
    UTILITY_TYPE_FILTER STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_churn'
COMMENT = 'Calls UTILITY_CHURN_PREDICTOR model from Model Registry to identify at-risk utilities'
AS
$$
def predict_churn(session, utility_type_filter):
    from snowflake.ml.registry import Registry
    import json
    
    reg = Registry(session)
    model = reg.get_model("UTILITY_CHURN_PREDICTOR").default
    
    type_filter = f"AND u.utility_type = '{utility_type_filter}'" if utility_type_filter else ""
    
    query = f"""
    SELECT
        u.utility_type,
        u.service_population::FLOAT AS service_population,
        COUNT(DISTINCT wo.work_order_id)::FLOAT AS total_work_orders,
        AVG(wo.customer_satisfaction_score)::FLOAT AS avg_satisfaction,
        COUNT(DISTINCT CASE WHEN mr.anomaly_detected THEN mr.reading_id END)::FLOAT AS anomaly_count,
        FALSE::BOOLEAN AS is_churned
    FROM RAW.UTILITIES u
    LEFT JOIN RAW.WORK_ORDERS wo ON u.utility_id = wo.utility_id
    LEFT JOIN RAW.METER_READINGS mr ON u.utility_id = mr.utility_id
    WHERE u.utility_status = 'ACTIVE' {type_filter}
    GROUP BY u.utility_id, u.utility_type, u.service_population
    LIMIT 100 -- Limit for performance in demo
    """
    
    input_df = session.sql(query)
    
    predictions = model.run(input_df, function_name="predict")
    
    result = predictions.select("CHURN_PREDICTION").to_pandas()
    churn_count = int(result['CHURN_PREDICTION'].sum())
    total_count = len(result)
    
    return json.dumps({
        "utility_type_filter": utility_type_filter or "ALL",
        "total_utilities_analyzed": total_count,
        "predicted_to_churn": churn_count,
        "churn_rate_pct": round(churn_count / total_count * 100, 2) if total_count > 0 else 0
    })
$$;

-- ============================================================================
-- Procedure 3: Meter Deployment Success Prediction Wrapper
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_DEPLOYMENT_SUCCESS(
    METER_FAMILY_FILTER STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_success'
COMMENT = 'Calls DEPLOYMENT_SUCCESS_PREDICTOR model to predict meter deployment success'
AS
$$
def predict_success(session, meter_family_filter):
    from snowflake.ml.registry import Registry
    import json
    
    reg = Registry(session)
    model = reg.get_model("DEPLOYMENT_SUCCESS_PREDICTOR").default
    
    family_filter = f"AND mc.meter_family = '{meter_family_filter}'" if meter_family_filter else ""
    
    query = f"""
    SELECT
        mc.meter_family,
        mc.technology,
        u.utility_type,
        DATEDIFF('year', u.onboarding_date, CURRENT_DATE())::FLOAT AS utility_age_years,
        TRUE::BOOLEAN as is_successful
    FROM RAW.METER_INVENTORY mi
    JOIN RAW.METER_CATALOG mc ON mi.meter_model_id = mc.meter_model_id
    JOIN RAW.UTILITIES u ON mi.utility_id = u.utility_id
    WHERE mi.meter_status = 'DEPLOYED' {family_filter}
    LIMIT 100 -- Limit for performance
    """
    
    input_df = session.sql(query)
    
    predictions = model.run(input_df, function_name="predict")
    
    result = predictions.select("SUCCESS_PREDICTION").to_pandas()
    successful_count = int(result['SUCCESS_PREDICTION'].sum())
    total_count = len(result)
    
    return json.dumps({
        "meter_family_filter": meter_family_filter or "ALL",
        "total_deployments_analyzed": total_count,
        "predicted_successful": successful_count,
        "success_rate_pct": round(successful_count / total_count * 100, 2) if total_count > 0 else 0
    })
$$;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'ML model wrapper functions created successfully' AS status;

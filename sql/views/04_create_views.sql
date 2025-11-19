-- ============================================================================
-- Neptune Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create curated analytical views for water utility business intelligence.
-- ============================================================================

USE DATABASE NEPTUNE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NEPTUNE_WH;

-- ============================================================================
-- Utility 360 View
-- ============================================================================
CREATE OR REPLACE VIEW V_UTILITY_360 AS
SELECT
    u.utility_id,
    u.utility_name,
    u.primary_contact_email,
    u.primary_contact_phone,
    u.country,
    u.state,
    u.city,
    u.onboarding_date,
    u.utility_status,
    u.utility_type,
    u.service_population,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT mi.meter_serial_number) AS total_meters,
    COUNT(DISTINCT CASE WHEN mi.meter_status = 'DEPLOYED' THEN mi.meter_serial_number END) AS deployed_meters,
    SUM(mr.consumption_gallons) AS total_consumption_gallons,
    AVG(mr.consumption_gallons) AS avg_consumption_gallons,
    COUNT(DISTINCT wo.work_order_id) AS total_work_orders,
    COUNT(DISTINCT CASE WHEN wo.priority = 'HIGH' THEN wo.work_order_id END) AS high_priority_work_orders,
    AVG(wo.customer_satisfaction_score) AS avg_satisfaction_score,
    u.created_at,
    u.updated_at
FROM RAW.UTILITIES u
LEFT JOIN RAW.CUSTOMERS c ON u.utility_id = c.utility_id
LEFT JOIN RAW.METER_INVENTORY mi ON u.utility_id = mi.utility_id
LEFT JOIN RAW.METER_READINGS mr ON u.utility_id = mr.utility_id
LEFT JOIN RAW.WORK_ORDERS wo ON u.utility_id = wo.utility_id
GROUP BY
    u.utility_id, u.utility_name, u.primary_contact_email, u.primary_contact_phone,
    u.country, u.state, u.city, u.onboarding_date, u.utility_status,
    u.utility_type, u.service_population, u.created_at, u.updated_at;

-- ============================================================================
-- Customer Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_CUSTOMER_ANALYTICS AS
SELECT
    c.customer_id,
    c.utility_id,
    u.utility_name,
    c.customer_name,
    c.email,
    c.account_number,
    c.address,
    c.customer_status,
    c.service_start_date,
    DATEDIFF('day', c.service_start_date, CURRENT_DATE()) AS days_as_customer,
    COUNT(DISTINCT mi.meter_serial_number) AS total_meters,
    SUM(mr.consumption_gallons) AS total_consumption_gallons,
    AVG(mr.consumption_gallons) AS avg_daily_consumption,
    COUNT(DISTINCT wo.work_order_id) AS total_work_orders,
    AVG(wo.customer_satisfaction_score) AS avg_satisfaction_score,
    c.created_at,
    c.updated_at
FROM RAW.CUSTOMERS c
JOIN RAW.UTILITIES u ON c.utility_id = u.utility_id
LEFT JOIN RAW.METER_INVENTORY mi ON c.customer_id = mi.customer_id
LEFT JOIN RAW.METER_READINGS mr ON c.customer_id = mr.customer_id
LEFT JOIN RAW.WORK_ORDERS wo ON c.customer_id = wo.customer_id
GROUP BY
    c.customer_id, c.utility_id, u.utility_name, c.customer_name, c.email,
    c.account_number, c.address, c.customer_status, c.service_start_date,
    c.created_at, c.updated_at;

-- ============================================================================
-- Meter Performance View
-- ============================================================================
CREATE OR REPLACE VIEW V_METER_PERFORMANCE AS
SELECT
    mi.meter_serial_number,
    mi.utility_id,
    u.utility_name,
    mi.customer_id,
    c.customer_name,
    mi.meter_model_id,
    mc.model_name,
    mc.meter_family,
    mc.meter_type,
    mc.technology,
    mi.installation_date,
    DATEDIFF('day', mi.installation_date, CURRENT_DATE()) AS meter_age_days,
    mi.meter_status,
    mi.last_sync_date,
    mi.firmware_version,
    SUM(mr.consumption_gallons) AS total_consumption_gallons,
    COUNT(DISTINCT mr.reading_id) AS total_readings,
    COUNT(DISTINCT CASE WHEN mr.anomaly_detected = TRUE THEN mr.reading_id END) AS total_anomalies,
    (COUNT(DISTINCT CASE WHEN mr.anomaly_detected = TRUE THEN mr.reading_id END)::FLOAT / NULLIF(COUNT(DISTINCT mr.reading_id), 0) * 100)::NUMBER(5,2) AS anomaly_rate_pct,
    COUNT(DISTINCT wo.work_order_id) AS total_work_orders,
    mi.created_at,
    mi.updated_at
FROM RAW.METER_INVENTORY mi
JOIN RAW.UTILITIES u ON mi.utility_id = u.utility_id
LEFT JOIN RAW.CUSTOMERS c ON mi.customer_id = c.customer_id
JOIN RAW.METER_CATALOG mc ON mi.meter_model_id = mc.meter_model_id
LEFT JOIN RAW.METER_READINGS mr ON mi.meter_serial_number = mr.meter_serial_number
LEFT JOIN RAW.WORK_ORDERS wo ON mi.meter_serial_number = wo.meter_serial_number
GROUP BY
    mi.meter_serial_number, mi.utility_id, u.utility_name, mi.customer_id, c.customer_name,
    mi.meter_model_id, mc.model_name, mc.meter_family, mc.meter_type, mc.technology,
    mi.installation_date, mi.meter_status, mi.last_sync_date, mi.firmware_version,
    mi.created_at, mi.updated_at;

-- ============================================================================
-- Work Order Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_WORK_ORDER_ANALYTICS AS
SELECT
    wo.work_order_id,
    wo.utility_id,
    u.utility_name,
    wo.customer_id,
    c.customer_name,
    wo.meter_serial_number,
    mc.model_name AS meter_model,
    wo.subject,
    wo.order_category,
    wo.priority,
    wo.order_status,
    wo.created_date,
    wo.resolution_date,
    DATEDIFF('hour', wo.created_date, wo.resolution_date) AS hours_to_resolution,
    wo.assigned_technician_id,
    st.technician_name AS assigned_technician_name,
    st.specialization AS technician_specialization,
    wo.customer_satisfaction_score,
    wo.created_at,
    wo.updated_at
FROM RAW.WORK_ORDERS wo
JOIN RAW.UTILITIES u ON wo.utility_id = u.utility_id
LEFT JOIN RAW.CUSTOMERS c ON wo.customer_id = c.customer_id
LEFT JOIN RAW.METER_INVENTORY mi ON wo.meter_serial_number = mi.meter_serial_number
LEFT JOIN RAW.METER_CATALOG mc ON mi.meter_model_id = mc.meter_model_id
LEFT JOIN RAW.SERVICE_TECHNICIANS st ON wo.assigned_technician_id = st.technician_id;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All analytical views created successfully' AS status;

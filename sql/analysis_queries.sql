-- =========================================================
-- Ops Labor Analysis - SQL Script
-- Author: Jason Summers
-- Purpose: End-to-end SQL used for ops labor overcharge analysis
-- =========================================================

-- Optional: ensure we’re on the right schema
SET search_path TO public;

-- =========================================================
-- 1. TABLE DEFINITION (raw imported data)
--    Note: In practice you imported via pgAdmin's CSV wizard.
--    This DDL is here so others can recreate the structure.
-- =========================================================

CREATE TABLE IF NOT EXISTS ro_issues (
    id                   SERIAL PRIMARY KEY,
    week                 INTEGER,
    ro_number            INTEGER,
    tech_initials        TEXT,
    category             TEXT,
    action_taken         TEXT,
    operation_group      TEXT,
    build_type           TEXT,
    date_reviewed        DATE,
    labor_hours_billed   NUMERIC(6,2),
    labor_hours_correct  NUMERIC(6,2),
    parts_cost           NUMERIC(10,2),
    total_estimated_cost NUMERIC(10,2),
    high_cost_flag       TEXT,
    notes                TEXT,
    labor_rate           NUMERIC(6,2),
    labor_cost_billed    NUMERIC(10,2),
    labor_cost_correct   NUMERIC(10,2),
    cost_overcharge      NUMERIC(10,2),
    issue_severity       TEXT
);

-- =========================================================
-- 2. (OPTIONAL) EXAMPLE: LOAD DATA FROM CSV
--    You used pgAdmin’s Import tool. This is here for reference.
--    Update the path as needed if someone wants to rerun it.
-- =========================================================
-- COPY ro_issues (
--     id, week, ro_number, tech_initials, category, action_taken,
--     operation_group, build_type, date_reviewed,
--     labor_hours_billed, labor_hours_correct,
--     parts_cost, total_estimated_cost,
--     high_cost_flag, notes,
--     labor_rate, labor_cost_billed, labor_cost_correct,
--     cost_overcharge, issue_severity
-- )
-- FROM '/absolute/path/to/ro_issues_clean.csv'
-- DELIMITER ',' CSV HEADER;

-- =========================================================
-- 3. BASIC DATA QUALITY & EXPLORATION
-- =========================================================

-- 3.1 Row count
SELECT COUNT(*) AS row_count
FROM ro_issues;

-- 3.2 Sample rows
SELECT *
FROM ro_issues
ORDER BY id
LIMIT 10;

-- 3.3 Distinct values in key categorical fields
SELECT DISTINCT category
FROM ro_issues
ORDER BY category;

SELECT DISTINCT action_taken
FROM ro_issues
ORDER BY action_taken;

SELECT DISTINCT tech_initials
FROM ro_issues
ORDER BY tech_initials;

SELECT DISTINCT operation_group
FROM ro_issues
ORDER BY operation_group;

SELECT DISTINCT issue_severity
FROM ro_issues
ORDER BY issue_severity;

-- 3.4 Basic numeric summaries
SELECT
    MIN(cost_overcharge)  AS min_cost_overcharge,
    MAX(cost_overcharge)  AS max_cost_overcharge,
    AVG(cost_overcharge)  AS avg_cost_overcharge,
    SUM(cost_overcharge)  AS total_cost_overcharge
FROM ro_issues;

-- =========================================================
-- 4. ANALYSIS VIEW: ro_issues_clean
--    Adds derived fields used later in Python & BI
-- =========================================================

CREATE OR REPLACE VIEW ro_issues_clean AS
SELECT
    id,
    week,
    ro_number,
    tech_initials,
    category,
    action_taken,
    operation_group,
    build_type,
    date_reviewed,
    labor_hours_billed,
    labor_hours_correct,
    parts_cost,
    total_estimated_cost,
    high_cost_flag,
    notes,
    labor_rate,
    labor_cost_billed,
    labor_cost_correct,
    cost_overcharge,
    issue_severity,

    -- Normalize action quality buckets
    CASE
        WHEN action_taken ILIKE 'Adjusted%' THEN 'Corrected'
        WHEN action_taken ILIKE 'Decline%'  THEN 'Declined'
        WHEN action_taken ILIKE 'No Action%' 
          OR action_taken ILIKE 'None%'    THEN 'Uncorrected'
        ELSE 'Other'
    END AS action_quality,

    -- Numeric severity score for later modeling
    CASE
        WHEN issue_severity = 'High'   THEN 3
        WHEN issue_severity = 'Medium' THEN 2
        WHEN issue_severity = 'Low'    THEN 1
        ELSE 0
    END AS severity_score,

    -- Operational risk bucket (simple rule-based)
    CASE
        WHEN issue_severity = 'High'
             AND (high_cost_flag = 'Yes' OR cost_overcharge >= 100) 
            THEN 'High-Risk'
        WHEN issue_severity IN ('High', 'Medium')
             OR cost_overcharge BETWEEN 50 AND 99
            THEN 'Medium-Risk'
        ELSE 'Low-Risk'
    END AS op_risk_bucket

FROM ro_issues;

-- Quick check of the view
SELECT *
FROM ro_issues_clean
ORDER BY id
LIMIT 10;

-- =========================================================
-- 5. CORE METRICS & ROLLUPS
-- =========================================================

-- 5.1 Total cost overcharge for the period
SELECT
    SUM(cost_overcharge) AS total_cost_overcharge
FROM ro_issues_clean;

-- 5.2 Overcharge by severity level
SELECT
    issue_severity,
    COUNT(*)              AS incident_count,
    SUM(cost_overcharge)  AS total_cost_overcharge,
    AVG(cost_overcharge)  AS avg_cost_overcharge
FROM ro_issues_clean
GROUP BY issue_severity
ORDER BY total_cost_overcharge DESC;

-- 5.3 Overcharge by category (Incorrect Labor, Overlapping, etc.)
SELECT
    category,
    COUNT(*)             AS incident_count,
    SUM(cost_overcharge) AS total_cost_overcharge,
    AVG(cost_overcharge) AS avg_cost_overcharge
FROM ro_issues_clean
GROUP BY category
ORDER BY total_cost_overcharge DESC;

-- 5.4 Overcharge by operation_group (Brakes, Electrical, etc.)
SELECT
    operation_group,
    COUNT(*)             AS incident_count,
    SUM(cost_overcharge) AS total_cost_overcharge,
    AVG(cost_overcharge) AS avg_cost_overcharge
FROM ro_issues_clean
GROUP BY operation_group
ORDER BY total_cost_overcharge DESC;

-- 5.5 Weekly trend: incidents & total overcharge by week
SELECT
    week,
    COUNT(*)             AS incident_count,
    SUM(cost_overcharge) AS total_cost_overcharge,
    AVG(cost_overcharge) AS avg_cost_overcharge
FROM ro_issues_clean
GROUP BY week
ORDER BY week;

-- =========================================================
-- 6. TECHNICIAN-LEVEL ANALYSIS
-- =========================================================

-- 6.1 Overall technician overcharge ranking
SELECT
    tech_initials,
    COUNT(*)             AS incident_count,
    SUM(cost_overcharge) AS total_cost_overcharge,
    AVG(cost_overcharge) AS avg_cost_overcharge
FROM ro_issues_clean
GROUP BY tech_initials
ORDER BY total_cost_overcharge DESC;

-- 6.2 Top 10 highest-cost technicians
SELECT
    tech_initials,
    COUNT(*)             AS incident_count,
    SUM(cost_overcharge) AS total_cost_overcharge,
    AVG(cost_overcharge) AS avg_cost_overcharge
FROM ro_issues_clean
GROUP BY tech_initials
ORDER BY total_cost_overcharge DESC
LIMIT 10;

-- 6.3 Technician ranking with severity and a simple risk index
WITH tech_stats AS (
    SELECT
        tech_initials,
        COUNT(*)                AS incident_count,
        SUM(cost_overcharge)    AS total_cost_overcharge,
        SUM(severity_score)     AS total_severity_score,
        SUM(severity_score * cost_overcharge) AS severity_cost_product
    FROM ro_issues_clean
    GROUP BY tech_initials
)
SELECT
    tech_initials,
    incident_count,
    total_cost_overcharge,
    total_severity_score,
    -- Tech Performance Index (TPI): severity-weighted cost per incident
    ROUND(
        severity_cost_product::NUMERIC 
        / NULLIF(incident_count, 0)::NUMERIC,
        2
    ) AS tpi
FROM tech_stats
ORDER BY tpi DESC;

-- 6.4 Tech ranking with window function (by cost_overcharge)
WITH tech_scores AS (
    SELECT
        tech_initials,
        COUNT(*)             AS incident_count,
        SUM(cost_overcharge) AS total_cost_overcharge
    FROM ro_issues_clean
    GROUP BY tech_initials
),
ranked AS (
    SELECT
        tech_initials,
        incident_count,
        total_cost_overcharge,
        DENSE_RANK() OVER (ORDER BY total_cost_overcharge DESC) AS cost_rank
    FROM tech_scores
)
SELECT *
FROM ranked
ORDER BY cost_rank, tech_initials;

-- =========================================================
-- 7. CATEGORY x TECH ANALYSIS (FOR COACHING FOCUS)
-- =========================================================

-- 7.1 Cost overcharge by category and technician
SELECT
    category,
    tech_initials,
    COUNT(*)             AS incident_count,
    SUM(cost_overcharge) AS total_cost_overcharge
FROM ro_issues_clean
GROUP BY category, tech_initials
ORDER BY category, total_cost_overcharge DESC;

-- 7.2 Category totals vs shop average for a specific tech (example: RL)
--     You used a Python helper for this, but here’s a pure SQL variant.

WITH tech_cat AS (
    SELECT
        category,
        SUM(cost_overcharge) AS tech_total
    FROM ro_issues_clean
    WHERE tech_initials = 'RL'
    GROUP BY category
),
shop_cat AS (
    SELECT
        category,
        AVG(cost_overcharge) AS shop_avg
    FROM ro_issues_clean
    WHERE tech_initials <> 'RL'
    GROUP BY category
)
SELECT
    COALESCE(t.category, s.category)              AS category,
    t.tech_total,
    s.shop_avg,
    CASE
        WHEN s.shop_avg IS NULL OR s.shop_avg = 0 THEN NULL
        ELSE ROUND(t.tech_total / s.shop_avg, 2)
    END AS ratio_tech_to_shop
FROM tech_cat t
FULL OUTER JOIN shop_cat s
    ON t.category = s.category
ORDER BY category;

-- (You can swap 'RL' for 'AD', 'FF', 'KG', etc. as needed.)

-- =========================================================
-- 8. RISK BUCKET & SEVERITY ANALYSIS
-- =========================================================

-- 8.1 Distribution by operational risk bucket
SELECT
    op_risk_bucket,
    COUNT(*)             AS incident_count,
    SUM(cost_overcharge) AS total_cost_overcharge,
    AVG(cost_overcharge) AS avg_cost_overcharge
FROM ro_issues_clean
GROUP BY op_risk_bucket
ORDER BY total_cost_overcharge DESC;

-- 8.2 High-risk incidents by tech
SELECT
    tech_initials,
    COUNT(*)             AS high_risk_incidents,
    SUM(cost_overcharge) AS high_risk_cost
FROM ro_issues_clean
WHERE op_risk_bucket = 'High-Risk'
GROUP BY tech_initials
ORDER BY high_risk_cost DESC;

-- 8.3 High-risk incidents by category
SELECT
    category,
    COUNT(*)             AS high_risk_incidents,
    SUM(cost_overcharge) AS high_risk_cost
FROM ro_issues_clean
WHERE op_risk_bucket = 'High-Risk'
GROUP BY category
ORDER BY high_risk_cost DESC;

-- =========================================================
-- 9. EXPORT FOR PYTHON OR BI
-- =========================================================

-- Example: export the cleaned view to CSV for downstream tools
-- (Path must be valid on the PostgreSQL server host)

-- COPY (
--     SELECT *
--     FROM ro_issues_clean
--     ORDER BY id
-- ) TO '/absolute/path/to/ro_issues_clean_for_python.csv'
-- WITH CSV HEADER;

-- =========================================================
-- END OF SCRIPT
-- =========================================================

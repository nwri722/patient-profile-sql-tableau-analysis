-- =====================================================
-- Patient Profile & Diagnosis Trends
-- SQL Analysis
-- Author: Nick Wright
-- =====================================================


-- =====================================================
-- 1. Patient Population Overview
-- =====================================================

-- Total Visits
SELECT
    COUNT(*) AS total_visits
FROM patient_visits;


-- Total Unique Patients
SELECT
    COUNT(DISTINCT patient_id) AS total_patients
FROM patient_visits;


-- Patient Count by Age Band
WITH patient_ages AS (
    SELECT
        patient_id,
        visit_date,
        EXTRACT(YEAR FROM AGE(visit_date, date_of_birth)) AS age,
        ROW_NUMBER() OVER (
            PARTITION BY patient_id
            ORDER BY visit_date DESC
        ) AS rn
    FROM patient_visits
)

SELECT
    CASE
        WHEN age BETWEEN 0 AND 17 THEN '0-17'
        WHEN age BETWEEN 18 AND 39 THEN '18-39'
        WHEN age BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS age_band,
    COUNT(*) AS patient_count
FROM patient_ages
WHERE rn = 1
GROUP BY age_band
ORDER BY age_band;


-- =====================================================
-- 2. Diagnosis Analysis
-- =====================================================

-- Diagnosis Frequency
SELECT
    icd_code,
    COUNT(*) AS diagnosis_count
FROM patient_visits
GROUP BY icd_code
ORDER BY diagnosis_count DESC;


-- Top 10 Diagnoses
SELECT
    icd_code,
    COUNT(*) AS diagnosis_count
FROM patient_visits
GROUP BY icd_code
ORDER BY diagnosis_count DESC
LIMIT 10;


-- Diagnosis by Sex
SELECT
    patient_sex,
    icd_code,
    COUNT(*) AS diagnosis_count
FROM patient_visits
GROUP BY
    patient_sex,
    icd_code
ORDER BY
    diagnosis_count DESC;


-- Diagnosis by Age Band
WITH patient_visits_age AS (
    SELECT
        patient_id,
        icd_code,
        CASE
            WHEN EXTRACT(YEAR FROM AGE(visit_date, date_of_birth)) BETWEEN 0 AND 17 THEN '0-17'
            WHEN EXTRACT(YEAR FROM AGE(visit_date, date_of_birth)) BETWEEN 18 AND 39 THEN '18-39'
            WHEN EXTRACT(YEAR FROM AGE(visit_date, date_of_birth)) BETWEEN 40 AND 64 THEN '40-64'
            ELSE '65+'
        END AS age_band
    FROM patient_visits
)

SELECT
    age_band,
    icd_code,
    COUNT(*) AS diagnosis_count
FROM patient_visits_age
GROUP BY
    age_band,
    icd_code
ORDER BY
    age_band,
    diagnosis_count DESC;


-- =====================================================
-- 3. Visit Utilization
-- =====================================================

-- Total Visits Per Patient
SELECT
    patient_id,
    COUNT(*) AS visit_count
FROM patient_visits
GROUP BY patient_id
ORDER BY visit_count DESC;


-- Average Visits Per Patient
SELECT
    ROUND(AVG(visit_count), 2) AS average_visits
FROM (
    SELECT
        patient_id,
        COUNT(*) AS visit_count
    FROM patient_visits
    GROUP BY patient_id
) AS patient_visit_counts;


-- High Utilizers (4+ Visits)
SELECT
    patient_id,
    COUNT(*) AS visit_count
FROM patient_visits
GROUP BY patient_id
HAVING COUNT(*) >= 4
ORDER BY visit_count DESC;


-- =====================================================
-- 4. Procedure (CPT) Insights
-- =====================================================

-- Procedure Frequency
SELECT
    cpt_code,
    COUNT(*) AS procedure_count
FROM patient_visits
GROUP BY cpt_code
ORDER BY procedure_count DESC;


-- Top 10 CPT Procedures
SELECT
    cpt_code,
    COUNT(*) AS procedure_count
FROM patient_visits
GROUP BY cpt_code
ORDER BY procedure_count DESC
LIMIT 10;

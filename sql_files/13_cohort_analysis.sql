-- ============================================================
-- RavenStack SaaS Dataset — Revenue Cohort Analysis by Referral Channel
-- Dialect: PostgreSQL (works on Redshift too; MySQL/BigQuery notes at bottom)
-- Tables used: accounts, subscriptions
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Build the cohort base (one row per account)
-- Each account is assigned to a cohort based on the month
-- they signed up, plus the referral channel that brought them in.
-- ------------------------------------------------------------
WITH cohort_base AS (
    SELECT
        a.account_id,
        a.referral_source,
        DATE_TRUNC('month', a.signup_date)::date AS cohort_month
    FROM accounts a
),

-- ------------------------------------------------------------
-- STEP 2: Pull subscription revenue activity per month
-- Each subscription row contributes its MRR to the month
-- in which it started (you could also model month-by-month
-- billing if you have a separate billing/invoice table).
-- ------------------------------------------------------------
sub_activity AS (
    SELECT
        s.account_id,
        s.subscription_id,
        s.mrr_amount,
        s.churn_flag,
        DATE_TRUNC('month', s.start_date)::date AS activity_month
    FROM subscriptions s
),

-- ------------------------------------------------------------
-- STEP 3: Join accounts to subscriptions and compute how many
-- months have passed since the account's cohort month
-- (month_number = 0, 1, 2, 3, ...)
-- ------------------------------------------------------------
joined AS (
    SELECT
        cb.account_id,
        cb.referral_source,
        cb.cohort_month,
        sa.activity_month,
        sa.mrr_amount,
        (
            (DATE_PART('year', sa.activity_month) - DATE_PART('year', cb.cohort_month)) * 12
            + (DATE_PART('month', sa.activity_month) - DATE_PART('month', cb.cohort_month))
        )::int AS month_number
    FROM cohort_base cb
    JOIN sub_activity sa
        ON cb.account_id = sa.account_id
    WHERE sa.activity_month >= cb.cohort_month   -- ignore any bad/pre-signup rows
),

-- ------------------------------------------------------------
-- STEP 4: Aggregate total MRR per referral_source + cohort_month
-- + month_number (this is the "long" format cohort table)
-- ------------------------------------------------------------
cohort_revenue AS (
    SELECT
        referral_source,
        cohort_month,
        month_number,
        SUM(mrr_amount)              AS total_mrr,
        COUNT(DISTINCT account_id)   AS active_accounts
    FROM joined
    GROUP BY referral_source, cohort_month, month_number
),

-- ------------------------------------------------------------
-- STEP 5: Get each cohort's Month 0 baseline MRR, used to
-- compute retention percentage in later months
-- ------------------------------------------------------------
month0_base AS (
    SELECT
        referral_source,
        cohort_month,
        total_mrr AS base_mrr
    FROM cohort_revenue
    WHERE month_number = 0
)

-- ------------------------------------------------------------
-- FINAL OUTPUT: long-format cohort table with retention %
-- ------------------------------------------------------------
-- SELECT
--     cr.referral_source,
--     cr.cohort_month,
--     cr.month_number,
--     cr.active_accounts,
--     cr.total_mrr,
--     ROUND(cr.total_mrr / NULLIF(m0.base_mrr, 0) * 100, 1) AS revenue_retention_pct
-- FROM cohort_revenue cr
-- JOIN month0_base m0
--     ON cr.referral_source = m0.referral_source
--     AND cr.cohort_month = m0.cohort_month
-- ORDER BY cr.referral_source, cr.cohort_month, cr.month_number;


-- ============================================================
-- OPTIONAL: Wide/pivot version — one row per cohort,
-- one column per month (easier to read as a heatmap-style table)
-- Extend the CASE WHEN list if you need more months.
-- ============================================================
/*
WITH cohort_base AS (
    SELECT
        a.account_id,
        a.referral_source,
        DATE_TRUNC('month', a.signup_date)::date AS cohort_month
    FROM accounts a
),
sub_activity AS (
    SELECT
        s.account_id,
        s.mrr_amount,
        DATE_TRUNC('month', s.start_date)::date AS activity_month
    FROM subscriptions s
),
joined AS (
    SELECT
        cb.referral_source,
        cb.cohort_month,
        sa.mrr_amount,
        (
            (DATE_PART('year', sa.activity_month) - DATE_PART('year', cb.cohort_month)) * 12
            + (DATE_PART('month', sa.activity_month) - DATE_PART('month', cb.cohort_month))
        )::int AS month_number
    FROM cohort_base cb
    JOIN sub_activity sa ON cb.account_id = sa.account_id
    WHERE sa.activity_month >= cb.cohort_month
)
SELECT
    referral_source,
    cohort_month,
    SUM(CASE WHEN month_number = 0 THEN mrr_amount ELSE 0 END) AS month_0,
    SUM(CASE WHEN month_number = 1 THEN mrr_amount ELSE 0 END) AS month_1,
    SUM(CASE WHEN month_number = 2 THEN mrr_amount ELSE 0 END) AS month_2,
    SUM(CASE WHEN month_number = 3 THEN mrr_amount ELSE 0 END) AS month_3,
    SUM(CASE WHEN month_number = 4 THEN mrr_amount ELSE 0 END) AS month_4,
    SUM(CASE WHEN month_number = 5 THEN mrr_amount ELSE 0 END) AS month_5
FROM joined
GROUP BY referral_source, cohort_month
ORDER BY referral_source, cohort_month;
*/


-- ============================================================
-- DIALECT NOTES
-- ============================================================
-- MySQL:
--   Replace DATE_TRUNC('month', col) with:
--     DATE_FORMAT(col, '%Y-%m-01')
--   Replace the month_number calculation with:
--     TIMESTAMPDIFF(MONTH, cohort_month, activity_month)
--
-- BigQuery:
--   DATE_TRUNC(col, MONTH) works natively.
--   Replace the month_number calculation with:
--     DATE_DIFF(activity_month, cohort_month, MONTH)
--
-- Snowflake:
--   DATE_TRUNC('month', col) works natively.
--   Replace the month_number calculation with:
--     DATEDIFF('month', cohort_month, activity_month)
-- ============================================================



-- month_number o'rniga to'g'ridan-to'g'ri quarter_number bilan guruhlash
SELECT
    referral_source,
    cohort_month,
    FLOOR(month_number / 3) AS quarter_number,
    COUNT(DISTINCT account_id) AS active_accounts,  -- endi chorak ichida noyob
    SUM(mrr_amount) AS total_mrr
FROM joined
GROUP BY referral_source, cohort_month, FLOOR(month_number / 3)
-- ============================================================================
-- vw_retention_analysis — TUZATILGAN VERSIYA
-- O'zgarishlar:
--   1. CURRENT_DATE o'rniga dataset snapshot sanasi ishlatildi (bug fix)
--   2. accounts.churn_flag = TRUE shartini qo'shdik — faqat "ishonchli"
--      (rasmiy ravishda churn bo'lgan VA churn_events'da tasdiqlangan)
--      accountlar retained_flag=0 deb belgilanadi
--   3. cohort_month qo'shildi (cohort_year yagona, faqat 2 qiymatli edi)
-- ============================================================================

CREATE OR REPLACE VIEW vw_retention_analysis AS

WITH snapshot AS (
    SELECT GREATEST(
        (SELECT MAX(signup_date) FROM accounts),
        (SELECT MAX(churn_date)  FROM churn_events)
    ) AS snapshot_date
),

account_churn AS (
    SELECT
        a.account_id,
        a.signup_date::date AS signup_date,
        EXTRACT(YEAR FROM a.signup_date)::int AS cohort_year,
        date_trunc('month', a.signup_date)::date AS cohort_month,

        -- faqat churn_flag = TRUE bo'lgan accountlar uchun churn_date olamiz;
        -- flag=False bo'lsa, churn_events'da yozuv bo'lsa ham e'tiborga olinmaydi
        MIN(ce.churn_date) FILTER (WHERE a.churn_flag = TRUE)::date AS churn_date

    FROM accounts a
    LEFT JOIN churn_events ce
        ON a.account_id = ce.account_id

    WHERE EXTRACT(YEAR FROM a.signup_date) IN (2023, 2024)

    GROUP BY
        a.account_id,
        a.signup_date,
        a.churn_flag
),

months AS (
    SELECT generate_series(0, 12) AS month_since_signup
),

account_months AS (
    SELECT
        a.account_id,
        a.signup_date,
        a.cohort_year,
        a.cohort_month,
        m.month_since_signup,
        (a.signup_date + (m.month_since_signup || ' months')::interval)::date AS retention_date,
        a.churn_date
    FROM account_churn a
    CROSS JOIN months m
),

final AS (
    SELECT
        am.account_id,
        am.signup_date,
        am.cohort_year,
        am.cohort_month,
        am.month_since_signup,
        am.retention_date,
        am.churn_date,

        -- account shu oyga "yetib kelganmi" (snapshot sanasiga nisbatan)
        CASE
            WHEN am.retention_date <= s.snapshot_date
            THEN 1 ELSE 0
        END AS eligible_flag,

        -- shu oyda hali ham faolmi (churn bo'lmagan yoki churn shu oydan keyin)
        CASE
            WHEN am.retention_date <= s.snapshot_date
                 AND (am.churn_date IS NULL OR am.churn_date > am.retention_date)
            THEN 1 ELSE 0
        END AS retained_flag

    FROM account_months am
    CROSS JOIN snapshot s
)

SELECT * FROM final;


SELECT cohort_month, month_since_signup,
       SUM(eligible_flag) AS n_eligible,
       SUM(retained_flag) AS n_retained,
       ROUND(SUM(retained_flag)::numeric / NULLIF(SUM(eligible_flag),0), 4) AS retention_rate
FROM vw_retention_analysis
GROUP BY cohort_month, month_since_signup
ORDER BY cohort_month, month_since_signup;







-- Retention Rate = 
-- DIVIDE(
--     SUM('public vw_retention_analysis'[retained_flag]),
--     SUM('public vw_retention_analysis'[eligible_flag])
-- )
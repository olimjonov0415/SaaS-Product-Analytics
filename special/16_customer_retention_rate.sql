-- 1. Har bir hisob uchun birinchi churn sanasini topish
--    (churn_events'da bitta hisob bir necha marta churn/reaktivatsiya bo'lgan bo'lishi mumkin)
-- WITH first_churn AS (
--     SELECT
--         account_id,
--         MIN(churn_date) AS first_churn_date
--     FROM churn_events
--     GROUP BY account_id
-- ),

-- -- 2. Signup'dan birinchi churn'gacha necha oy o'tganini hisoblash
-- account_churn_months AS (
--     SELECT
--         a.account_id,
--         a.signup_date,
--         fc.first_churn_date,
--         -- yil*12 + oy farqi = necha oy o'tgani
--         CASE WHEN fc.first_churn_date IS NOT NULL THEN
--             (EXTRACT(YEAR FROM fc.first_churn_date) - EXTRACT(YEAR FROM a.signup_date)) * 12
--             + (EXTRACT(MONTH FROM fc.first_churn_date) - EXTRACT(MONTH FROM a.signup_date))
--         END AS months_to_churn
--     FROM accounts a
--     LEFT JOIN first_churn fc ON fc.account_id = a.account_id
-- ),

-- -- 3. 0 dan 23 gagacha oylar ro'yxati (retention egri chizig'i uchun nuqtalar)
-- month_points AS (
--     SELECT generate_series(0, 23) AS n
-- ),

-- -- 4. Har bir N oy uchun: "munosib" hisoblar (N oyga yetib borganlar)
-- --    va shu N oygacha churn bo'lganlar
-- cohort_calc AS (
--     SELECT
--         mp.n,
--         COUNT(*) FILTER (
--             WHERE acm.signup_date + (mp.n || ' months')::interval <= DATE '2024-12-31'
--         ) AS eligible_accounts,
--         COUNT(*) FILTER (
--             WHERE acm.signup_date + (mp.n || ' months')::interval <= DATE '2024-12-31'
--               AND acm.months_to_churn IS NOT NULL
--               AND acm.months_to_churn <= mp.n
--         ) AS churned_by_n
--     FROM month_points mp
--     CROSS JOIN account_churn_months acm
--     GROUP BY mp.n
-- )

-- -- 5. Yakuniy retention foizi
-- SELECT
--     n AS month_since_signup,
--     eligible_accounts,
--     churned_by_n,
--     ROUND(100.0 * (1 - churned_by_n::numeric / NULLIF(eligible_accounts, 0)), 1) AS retention_pct
-- FROM cohort_calc
-- ORDER BY n;































CREATE OR REPLACE VIEW public.vw_cohort_retention_long AS

WITH customer_cohort AS (
    SELECT
        account_id,
        DATE_TRUNC('month', signup_date::date)::date AS cohort_month
    FROM public.accounts
),

first_churn AS (
    SELECT
        account_id,
        MIN(churn_date::date) AS first_churn_date
    FROM public.churn_events
    GROUP BY account_id
),

customers AS (
    SELECT
        c.account_id,
        c.cohort_month,
        f.first_churn_date
    FROM customer_cohort c
    LEFT JOIN first_churn f
        ON c.account_id = f.account_id
),

months AS (
    SELECT
        generate_series(0, 12) AS month_number
),

cohort_months AS (
    SELECT
        c.cohort_month,
        m.month_number
    FROM (
        SELECT DISTINCT cohort_month
        FROM customers
    ) c
    CROSS JOIN months m
),

retention AS (
    SELECT
        cm.cohort_month,
        cm.month_number,
        COUNT(c.account_id) AS retained_customers
    FROM cohort_months cm

    LEFT JOIN customers c
        ON c.cohort_month = cm.cohort_month

        AND (
            c.first_churn_date IS NULL

            OR c.first_churn_date >=
               (
                   cm.cohort_month
                   + (cm.month_number + 1) * INTERVAL '1 month'
               )::date
        )

    GROUP BY
        cm.cohort_month,
        cm.month_number
)

SELECT
    cohort_month,
    month_number,
    retained_customers,

    MAX(retained_customers) OVER (
        PARTITION BY cohort_month
    ) AS cohort_size,

    ROUND(
        100.0 * retained_customers
        / NULLIF(
            MAX(retained_customers) OVER (
                PARTITION BY cohort_month
            ),
            0
        ),
        1
    ) AS retention_rate

FROM retention

ORDER BY
    cohort_month,
    month_number;




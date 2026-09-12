-- CREATE OR REPLACE VIEW public.vw_retention_curve AS

-- WITH customer_data AS (
--     SELECT
--         a.account_id,
--         DATE_TRUNC('month', a.signup_date)::date AS cohort_month,
--         MIN(ce.churn_date::date) AS first_churn_date
--     FROM public.accounts a
--     LEFT JOIN public.churn_events ce
--         ON a.account_id = ce.account_id
--     GROUP BY
--         a.account_id,
--         DATE_TRUNC('month', a.signup_date)
-- ),

-- observation_end AS (
--     SELECT
--         GREATEST(
--             (SELECT MAX(signup_date::date) FROM public.accounts),
--             (SELECT MAX(churn_date::date) FROM public.churn_events)
--         ) AS last_date
-- ),

-- months AS (
--     SELECT
--         generate_series(0, 12) AS month_number
-- ),

-- monthly_retention AS (
--     SELECT
--         m.month_number,

--         COUNT(*) FILTER (
--             WHERE
--                 cd.first_churn_date IS NULL
--                 OR cd.first_churn_date >=
--                    (
--                        cd.cohort_month
--                        + (m.month_number + 1) * INTERVAL '1 month'
--                    )::date
--         ) AS retained_customers,

--         COUNT(*) AS eligible_customers

--     FROM months m

--     CROSS JOIN customer_data cd
--     CROSS JOIN observation_end oe

--     WHERE
--         (
--             cd.cohort_month
--             + (m.month_number + 1) * INTERVAL '1 month'
--         )::date <= oe.last_date

--     GROUP BY
--         m.month_number
-- )

-- SELECT
--     month_number,

--     retained_customers,
--     eligible_customers,

--     ROUND(
--         100.0 * retained_customers
--         / NULLIF(eligible_customers, 0),
--         1
--     ) AS retention_rate

-- FROM monthly_retention

-- ORDER BY
--     month_number;

-- SELECT * FROM public.vw_retention_curve;


CREATE OR REPLACE VIEW public.vw_retention_curve_2024 AS

WITH customer_data AS (
    SELECT
        a.account_id,
        DATE_TRUNC('month', a.signup_date)::date AS cohort_month,
        MIN(ce.churn_date::date) AS first_churn_date
    FROM public.accounts a

    LEFT JOIN public.churn_events ce
        ON a.account_id = ce.account_id

    -- FAQAT 2024-YILDA SIGNUP QILGANLAR
    WHERE a.signup_date >= '2024-01-01'
      AND a.signup_date < '2025-01-01'

    GROUP BY
        a.account_id,
        DATE_TRUNC('month', a.signup_date)
),

observation_end AS (
    SELECT
        GREATEST(
            (SELECT MAX(signup_date::date)
             FROM public.accounts),

            (SELECT MAX(churn_date::date)
             FROM public.churn_events)
        ) AS last_date
),

months AS (
    SELECT
        generate_series(0, 12) AS month_number
),

monthly_retention AS (
    SELECT
        m.month_number,

        COUNT(*) FILTER (
            WHERE
                cd.first_churn_date IS NULL
                OR cd.first_churn_date >=
                   (
                       cd.cohort_month
                       + (m.month_number + 1) * INTERVAL '1 month'
                   )::date
        ) AS retained_customers,

        COUNT(*) AS eligible_customers

    FROM months m

    CROSS JOIN customer_data cd
    CROSS JOIN observation_end oe

    WHERE
        (
            cd.cohort_month
            + (m.month_number + 1) * INTERVAL '1 month'
        )::date <= oe.last_date

    GROUP BY
        m.month_number
)

SELECT
    month_number,
    retained_customers,
    eligible_customers,

    ROUND(
        100.0 * retained_customers
        / NULLIF(eligible_customers, 0),
        1
    ) AS retention_rate

FROM monthly_retention

ORDER BY
    month_number;


SELECT * FROM public.vw_retention_curve_2024;
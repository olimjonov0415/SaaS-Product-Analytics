CREATE OR REPLACE VIEW vw_retention_analysis AS

WITH account_churn AS (
    SELECT
        a.account_id,
        a.signup_date::date AS signup_date,
        EXTRACT(YEAR FROM a.signup_date)::int AS cohort_year,

        MIN(ce.churn_date)::date AS churn_date

    FROM accounts a
    LEFT JOIN churn_events ce
        ON a.account_id = ce.account_id

    WHERE EXTRACT(YEAR FROM a.signup_date) IN (2023, 2024)

    GROUP BY
        a.account_id,
        a.signup_date
),

months AS (
    SELECT
        generate_series(0, 12) AS month_since_signup
),

account_months AS (
    SELECT
        a.account_id,
        a.signup_date,
        a.cohort_year,
        m.month_since_signup,

        (
            a.signup_date
            + (m.month_since_signup || ' months')::interval
        )::date AS retention_date,

        a.churn_date

    FROM account_churn a
    CROSS JOIN months m
),

final AS (
    SELECT
        account_id,
        signup_date,
        cohort_year,
        month_since_signup,
        retention_date,
        churn_date,

        -- Account has reached this month
        CASE
            WHEN retention_date <= CURRENT_DATE
            THEN 1
            ELSE 0
        END AS eligible_flag,

        -- Account has not churned before this month
        CASE
            WHEN retention_date <= CURRENT_DATE
                 AND (
                     churn_date IS NULL
                     OR churn_date > retention_date
                 )
            THEN 1
            ELSE 0
        END AS retained_flag

    FROM account_months
)

SELECT *
FROM final;

SELECT * FROM vw_retention_analysis
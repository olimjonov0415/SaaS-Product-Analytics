-- Creating tables for SaaS dataset

--accounts
-- CREATE TABLE IF NOT EXISTS accounts (
--   account_id VARCHAR PRIMARY KEY,
--   account_name VARCHAR,
--   industry VARCHAR,
--   country VARCHAR,
--   signup_date TIMESTAMP,
--   referral_source VARCHAR,
--   plan_tier VARCHAR,
--   seats INTEGER,
--   is_trial BOOLEAN,
--   churn_flag BOOLEAN
-- );


--churn_events
--churn_events failed, correct one below
-- CREATE TABLE IF NOT EXISTS churn_events (
--   churn_event_id TEXT,      
--   account_id VARCHAR PRIMARY KEY,
--   churn_date TIMESTAMP,
--   reason_code VARCHAR,
--   refund_amount_usd NUMERIC,
--   preceding_upgrade_flag BOOLEAN,
--   preceding_downgrade_flag BOOLEAN,
--   is_reactivation BOOLEAN,
--   feedback_text VARCHAR
-- );
--churn_events corrected
-- CREATE TABLE churn_events (
--   churn_event_id VARCHAR PRIMARY KEY,
--   account_id VARCHAR NOT NULL REFERENCES accounts(account_id),
--   churn_date DATE,
--   reason_code VARCHAR,
--   refund_amount_usd NUMERIC,
--   preceding_upgrade_flag BOOLEAN,
--   preceding_downgrade_flag BOOLEAN,
--   is_reactivation BOOLEAN,
--   feedback_text VARCHAR
-- );


--subscriptions
-- CREATE TABLE subscriptions (
--   subscription_id VARCHAR PRIMARY KEY,
--   account_id VARCHAR,
--   start_date TIMESTAMP,
--   end_date TIMESTAMP,
--   plan_tier VARCHAR,
--   seats INTEGER,
--   mrr_amount NUMERIC,
--   arr_amount NUMERIC,
--   is_trial BOOLEAN,
--   upgrade_flag BOOLEAN,
--   downgrade_flag BOOLEAN,
--   churn_flag BOOLEAN,
--   billing_frequency VARCHAR,
--   auto_renew_flag BOOLEAN
-- );



--feature_usage
-- feature_usage failed, correct one below
-- CREATE TABLE feature_usage(
--   usage_id TEXT,
--   subscription_id VARCHAR PRIMARY KEY,
--   usage_date TIMESTAMP,
--   feature_name TEXT,
--   usage_count INTEGER,
--   usage_duration_secs INTEGER,
--   error_count INTEGER,
--   is_beta_feature BOOLEAN
-- )
--feature_usage corrected
-- CREATE TABLE feature_usage (
--   row_id SERIAL PRIMARY KEY,
--   usage_id TEXT NOT NULL,
--   subscription_id VARCHAR NOT NULL REFERENCES subscriptions(subscription_id),
--   usage_date TIMESTAMP,
--   feature_name TEXT,
--   usage_count INTEGER,
--   usage_duration_secs INTEGER,
--   error_count INTEGER,
--   is_beta_feature BOOLEAN
-- );

--support_tickets
-- CREATE TABLE support_tickets (
--   ticket_id VARCHAR PRIMARY KEY,
--   account_id VARCHAR NOT NULL REFERENCES accounts(account_id),
--   submitted_at TIMESTAMP,
--   closed_at TIMESTAMP,
--   resolution_time_hours NUMERIC,
--   priority VARCHAR,
--   first_response_time_minutes NUMERIC,
--   satisfaction_score NUMERIC,
--   escalation_flag BOOLEAN
-- );

--DONE




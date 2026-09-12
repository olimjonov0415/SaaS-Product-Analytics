--importing data from csv files into the tables



copy accounts(account_id, account_name, industry, country, signup_date, referral_source, plan_tier, seats, is_trial, churn_flag) FROM 'E:\Data Analysis\Projects\SaaS_ Product_ Analytics\dataset\ravenstack_accounts.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

copy churn_events(churn_event_id,account_id, churn_date, reason_code, refund_amount_usd, preceding_upgrade_flag, preceding_downgrade_flag, is_reactivation, feedback_text) FROM 'E:\Data Analysis\Projects\SaaS_ Product_ Analytics\dataset\ravenstack_churn_events.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

copy subscriptions(subscription_id, account_id, start_date, end_date, plan_tier, seats, mrr_amount, arr_amount, is_trial, upgrade_flag, downgrade_flag, churn_flag, billing_frequency, auto_renew_flag) FROM 'E:\Data Analysis\Projects\SaaS_ Product_ Analytics\dataset\ravenstack_subscriptions.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

copy feature_usage(usage_id, subscription_id, usage_date, feature_name, usage_count, usage_duration_secs, error_count, is_beta_feature) FROM 'E:\Data Analysis\Projects\SaaS_ Product_ Analytics\dataset\ravenstack_feature_usage.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

copy support_tickets(ticket_id, account_id, submitted_at, closed_at, resolution_time_hours, priority, first_response_time_minutes, satisfaction_score, escalation_flag) FROM 'E:\Data Analysis\Projects\SaaS_ Product_ Analytics\dataset\ravenstack_support_tickets.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- verifying each table

-- 1) Knowing number of rows of each table
SELECT 
    'accounts' AS table_name,
    COUNT(*) AS rows 
FROM accounts

UNION ALL

SELECT 
    'churn_events', 
    COUNT(*) 
FROM churn_events

UNION ALL

SELECT 
    'feature_usage', 
    COUNT(*) 
FROM feature_usage

UNION ALL

SELECT 
    'subscriptions',
    COUNT(*) 
FROM subscriptions

UNION ALL

SELECT 
    'support_tickets', 
    COUNT(*) 
FROM support_tickets




-- 2) Checking tables' key(s) for NULL
SELECT 
    'accounts' AS table_name,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS null_account_id 
FROM accounts;

SELECT 
    'churn_events' AS table_name,
    COUNT(*) FILTER (WHERE account_id IS NULL OR churn_event_id IS NULL) 
FROM churn_events;





--3) Just seeing
SELECT 
    COUNT(account_name)
FROM accounts
ORDER BY signup_date DESC 
LIMIT 10;

SELECT * 
FROM churn_events 
LIMIT 10;

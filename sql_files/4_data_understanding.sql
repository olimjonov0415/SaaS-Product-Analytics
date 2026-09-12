-- understanding data

-- Unique customers
SELECT 
    COUNT(DISTINCT account_id) AS unique_accounts,
    COUNT(DISTINCT account_name) AS unique_account_unique_id 
FROM accounts;



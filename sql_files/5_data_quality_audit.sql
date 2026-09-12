-- 05_data_quality_audit.sql
-- Data quality checks: duplicates, orphan foreign keys, invalid values

-- 1) Duplicate primary keys
SELECT  
    account_id,
    COUNT(*)
FROM accounts 
GROUP BY account_id 
HAVING COUNT(*) > 1;


-- 4) Invalid dates (approved before submitted)
SELECT *
FROM support_tickets
WHERE closed_at < submitted_at;
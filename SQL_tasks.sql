Первое задание:

WITH churn_rate AS

(
SELECT 
t1.*,
CASE WHEN 
        LEAD (report_month) OVER (PARTITION BY client_id ORDER BY report_month) IS NULL 
    AND LEAD (report_month, 2) OVER (PARTITION BY client_id ORDER BY report_month) IS NULL
    AND LEAD (report_month, 3) OVER (PARTITION BY client_id ORDER BY report_month) IS NULL
        THEN 1 ELSE 0
    END as churn 
FROM active_clients
),

total AS

(
SELECT
    report_month,
    SUM (churn) OVER (PARTITION BY report_month) AS churn_total,
    SUM (client_id) OVER (PARTITION BY report_month) AS active_total
FROM churn_rate 
GROUP BY report_month 
)

SELECT 
    report_month,
    active_total,
    churn_total / active_total AS churn_rate 
FROM total
GROUP BY report_month


Второе задание с бонусами:

WITH total AS 
(
SELECT 
    t1.*,
    SUM (bonus_cnt) OVER (PARTITION BY client_id ORDER BY bonus_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS bonus_total 
    FROM bonus t1
INNER JOIN mcc_categories t2  ON t1.mcc_code=t2.mcc_code
WHERE LOWER(mcc_category) IN ('авиабилеты', 'отели') 
),

RN AS
(
SELECT 
    t1.*,
    ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY bonus_date ASC) AS rna
FROM total t1
WHERE bonus_total >= 1000
)

SELECT 
    client_id, 
    bonus_date
FROM rn
WHERE rna = 1
ORDER BY bonus_date
LIMIT 1000

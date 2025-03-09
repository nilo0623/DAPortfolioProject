select *
from [dbo].[Churn_dataset];

--creating a staging table for exploratory data analysis and data cleaning
--to prevent a sudden change to the original raw dataset.

select * into Churn_dataset_stg
from [dbo].[Churn_dataset];

select *
from Churn_dataset_stg;

--checking for duplicates
select customerID, count(*) as duplicate_num
from Churn_dataset_stg
group by customerID
having count(*) > 1;


select *
from Churn_dataset_stg;


--no null values on the dataset

select *
from Churn_dataset_stg;

SELECT Churn, COUNT(*) AS Total_Customers
FROM Churn_dataset_stg
WHERE Churn LIKE '%yes' OR Churn LIKE '%no'
GROUP BY Churn;

--Churn Percentage calculations
-- it shows a 27% Churn Percentage in the last month which is quite high for an ideal 5%-7.5% churn rate
SELECT 
    COUNT(CASE WHEN Churn = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS Churn_Percentage,
    COUNT(CASE WHEN Churn = 'No' THEN 1 END) * 100.0 / COUNT(*) AS Retention_Percentage
FROM Churn_dataset_stg;


----Services each customer has signed up for: phone, multiple lines, internet, online security,
--online backup, device protection, tech
--support, and streaming TV and movies

SELECT 
    SUM(CASE WHEN PhoneService = 'Yes' THEN 1 ELSE 0 END) AS Phone_Customers,
    SUM(CASE WHEN MultipleLines = 'Yes' THEN 1 ELSE 0 END) AS MultipleLines_Customers,
    SUM(CASE WHEN InternetService <> 'No' THEN 1 ELSE 0 END) AS Internet_Customers,
    SUM(CASE WHEN OnlineSecurity = 'Yes' THEN 1 ELSE 0 END) AS OnlineSecurity_Customers,
    SUM(CASE WHEN OnlineBackup = 'Yes' THEN 1 ELSE 0 END) AS OnlineBackup_Customers,
    SUM(CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END) AS DeviceProtection_Customers,
    SUM(CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END) AS TechSupport_Customers,
    SUM(CASE WHEN StreamingTV = 'Yes' THEN 1 ELSE 0 END) AS StreamingTV_Customers,
    SUM(CASE WHEN StreamingMovies = 'Yes' THEN 1 ELSE 0 END) AS StreamingMovies_Customers
FROM Churn_dataset_stg;

--Churn percentage for customers who subscribed to all the products
WITH SubscribedCustomers AS (
    SELECT 
        Churn, 
        COUNT(*) AS Total_Customers,
        SUM(TotalCharges) AS Total_Revenue
    FROM Churn_dataset_stg
    WHERE 
        PhoneService = 'Yes' 
        AND MultipleLines = 'Yes' 
        AND InternetService <> 'yes' 
        AND OnlineSecurity = 'Yes' 
        AND OnlineBackup = 'Yes' 
        AND DeviceProtection = 'Yes' 
        AND TechSupport = 'Yes' 
        AND StreamingTV = 'Yes' 
        AND StreamingMovies = 'Yes'
    GROUP BY Churn
)
SELECT 
    Total_Customers,
    Total_Revenue,
    (Total_Customers * 100.0) / SUM(Total_Customers) OVER() AS Churn_Percentage
FROM SubscribedCustomers
ORDER BY Churn DESC;


--Churn count
--total of 1869 customers churn. 48 people churned had 2 years subscription, 166 people had 1 year ssubscription
--and 1655 customers had a month to month subscription.
SELECT 
    [Contract], 
    COUNT(*) AS Churned_Customers
FROM Churn_dataset_stg
WHERE Churn = 'Yes'
GROUP BY [Contract]
ORDER BY Churned_Customers DESC;


--shows how many customers churn in each distinct tenure
-- it shows that the shorter the tenure of customer the more the customer leave

-- 1. Count tenure-based churn customers efficiently
SELECT 
    tenure, 
    COUNT(*) AS tenureContract
FROM Churn_dataset_stg
WHERE Churn = 'Yes'
GROUP BY tenure
ORDER BY tenureContract DESC;

-- 2. Retrieve PaperlessBilling customers with details, sorted by tenure
SELECT 
    customerID, tenure, PaperlessBilling, PaymentMethod, 
    MonthlyCharges, TotalCharges, numAdminTickets, numTechTickets
FROM Churn_dataset_stg
WHERE PaperlessBilling = 'Yes'
ORDER BY tenure DESC;

-- 3 & 4. Count customers based on PaperlessBilling in one go
SELECT 
    PaperlessBilling, 
    COUNT(*) AS Total_Customers
FROM Churn_dataset_stg
GROUP BY PaperlessBilling;


--Demographics
SELECT 
    SeniorCitizen, 
    Partner, 
    Dependents, 
    COUNT(customerID) AS Total_Customers
FROM Churn_dataset_stg
GROUP BY SeniorCitizen, Partner, Dependents;

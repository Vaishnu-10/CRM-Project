Use CRM

Select * from [dbo].[Activities$]
Select * from [dbo].[Contacts$]
Select * from [dbo].[Customers$]
Select * from [dbo].[Leads$]
Select * from [dbo].[Opportunities$]
Select * from [dbo].[Tasks$]

WITH CTE AS (
    SELECT 
        CustomerID, 
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY (SELECT NULL)) AS RowNum
    FROM Customers$
)
DELETE FROM CTE
WHERE RowNum > 1;

With CTE As(
	Select ActivityID,
	ROW_NUMBER() over (Partition By ActivityID Order BY (Select Null)) As RowNum
	From Activities$)
	Delete from CTE
	Where RowNum>1

With CTE As(
	Select ContactID,
	ROW_NUMBER() over (Partition By ContactID Order BY (Select Null)) As RowNum
	From Contacts$)
	Delete from CTE
	Where RowNum>1

With CTE As(
	Select LeadID,
	ROW_NUMBER() over (Partition By LeadID Order BY (Select Null)) As RowNum
	From Leads$)
	Delete from CTE
	Where RowNum>1

With CTE As(
	Select OpportunityID,
	ROW_NUMBER() over (Partition By OpportunityID Order BY (Select Null)) As RowNum
	From Opportunities$)
	Delete from CTE
	Where RowNum>1

With CTE As(
	Select TaskID,
	ROW_NUMBER() over (Partition By TaskID Order BY (Select Null)) As RowNum
	From Tasks$)
	Delete from CTE
	Where RowNum>1

SELECT *
FROM Customers$
WHERE CustomerID IS NULL;

DELETE FROM Customers$
WHERE CustomerID IS NULL;

-----------------------------------
--List all Customers
Select * from Customers$

---Find the total number of leads:
Select count(*) as Total_Leads from Leads$ 

---Get the details of all opportunities with a stage of 'Negotiation':
Select * from Opportunities$

SELECT * FROM Opportunities$ WHERE Stage = 'Negotiation';

--List all contacts for a given customerID=24:

Select * from Contacts$ where CustomerID= 24;

--Retrieve all activities that took place in the last 30 days:

Select * from Activities$

Select * from Activities$ where ActivityDate >= DATEADD(day, -30, GETDATE());

---Find the total amount of opportunities for each customer:
Select CustomerID, Sum(Amount) as TotalAmount
From Opportunities$ 
Group by CustomerID

---Find the average probability of closing for opportunities in the 'Prospecting' stage:
Select Avg(Probability) As AvgProbability from Opportunities$
Where Stage = 'Prospecting';


---Get the contact details for customers with opportunities greater than $50,000:
Select Concat(C.FirstName,' ',C.LastName) As Name, C.Phone from Contacts$ C
Join Opportunities$ O on C.CustomerID= O.CustomerID
Where O.Amount>50000

----List all tasks with their corresponding opportunity names and customer names:

Select T.*,O.OpportunityName,C.CustomerName from Tasks$ T
Join Opportunities$ O on T.OpportunityID=O.OpportunityID
Join Customers$ C on O.CustomerID= C.CustomerID

---Retrieve the top 5 customers with the highest total opportunity amounts:
Select * from Opportunities$
Select * from Customers$

Select Top 5 CustomerID, Sum(Amount) As TotalAmount
From Opportunities$
Group BY CustomerID
Order BY TotalAmount Desc;

---Calculate the conversion rate from leads to opportunities:
Select (Select Count(*) From Opportunities$)/(Select Count(*) From Leads$) As ConversionRate 

---Get the number of activities by type :
Select * from Activities$

Select ActivityType, Count(*) As ActivityCount
From Activities$
Group By ActivityType

---Find the most common industry among customers:
Select * From Customers$

Select Top 1 Industry, Count(*) As IndustryCount from Customers$
Group By Industry
Order By IndustryCount Desc

---List all tasks that are overdue:
SELECT * FROM Tasks$
WHERE DueDate < GETDATE() AND Status != 'Completed';

---Identify duplicate email addresses in contacts:
SELECT Email, COUNT(Email) AS CountOfEmails
FROM Contacts$
GROUP BY Email
HAVING COUNT(Email) > 1;

---Ensure that all opportunities have a probability value between 0 and 1:
Select * from Opportunities$
WHERE Probability > 0 OR Probability < 1;

---Create an index on the CustomerID column in the Opportunities table:
Create Index idx_CustomerID On Opportunities$(CustomerID)

---Get the total number of tasks assigned to each employee:
Select AssignedTo, Count(*) As TaskCount from Tasks$
Group BY AssignedTo

---Calculate the average amount of opportunities closed in the last year:
Select Avg(Amount) As AvgAmount From Opportunities$
where Stage='Closed' and CloseDate>= DATEADD(year, -1, GETDATE());

---Find customers who have both open and closed opportunities:

SELECT c.CustomerID, c.CustomerName
FROM Customers$ c
JOIN Opportunities$ o1 ON c.CustomerID = o1.CustomerID AND o1.Stage = 'Closed'
JOIN Opportunities$ o2 ON c.CustomerID = o2.CustomerID AND o2.Stage != 'Closed';

---List all leads that have been converted into opportunities:
SELECT l.*, o.OpportunityID
FROM Leads$ l
JOIN Opportunities$ o ON l.CustomerID = o.CustomerID;

---Get the change history of a specific opportunity:
SELECT *
FROM Opportunities$
ORDER BY LastModifiedDate DESC;

---Calculate the average lead response time:
SELECT AVG(DATEDIFF(Day,LastModifiedDate, CreatedDate)) AS AvgResponseTime
FROM Leads$;

---Identify the month with the highest number of new leads:
SELECT 
  DATENAME(month, CreatedDate) AS MonthName,
  COUNT(*) AS LeadCount
FROM Leads$
GROUP BY DATENAME(month, CreatedDate)
ORDER BY LeadCount DESC;

---Identify the top 5 customers by total revenue from closed opportunities.
Select Top 5 CustomerID,Sum(Amount) As TotalRevenue from Opportunities$
Where Stage = 'Closed'
Group By CustomerID
Order By TotalRevenue Desc

---Calculate the average time taken to close opportunities for each sales representative.
SELECT l.LeadOwner, AVG(DATEDIFF(Day,o.CloseDate, l.CreatedDate)) AS AvgCloseTime
FROM Opportunities$ o
JOIN Leads$ l ON o.CustomerID = l.CustomerID
WHERE o.Stage = 'Closed'
GROUP BY l.LeadOwner;

---Find the conversion rate from leads to opportunities for each lead source.
Select * from Leads$
Select * from Opportunities$
SELECT l.LeadSource, COUNT(o.OpportunityID) / COUNT(l.LeadID) AS ConversionRate
FROM Leads$ l
LEFT JOIN Opportunities$ o ON l.CustomerID = o.CustomerID
GROUP BY l.LeadSource;

---Determine the impact of different activity types on the likelihood of closing an opportunity.
SELECT a.ActivityType,  ROUND(AVG(o.Probability), 2) AS AvgCloseProbability
FROM Activities$ a
JOIN Opportunities$ o ON a.CustomerID = o.CustomerID
GROUP BY a.ActivityType;

---Identify customers who have never been contacted.
SELECT c.CustomerID, c.CustomerName
FROM Customers$ c
LEFT JOIN Activities$ a ON c.CustomerID = a.CustomerID
WHERE a.ActivityID IS NULL;

---Calculate the average response time for different types of activities.
SELECT ActivityType, AVG(DATEDIFF(Day,LastModifiedDate, CreatedDate)) AS AvgResponseTime
FROM Activities$
GROUP BY ActivityType;

---Identify the sales representative with the highest number of closed opportunities.
SELECT Top 2 L.LeadOwner, COUNT(*) AS ClosedCount
FROM Opportunities$ O
Join Leads$ L on L.CustomerID = O.CustomerID
WHERE O.Stage = 'Closed'
GROUP BY L.LeadOwner
ORDER BY ClosedCount DESC

Select * from Opportunities$
Select * from Leads$
 

 ---Find the customer with the highest number of activities and analyze the types of activities.
SELECT Top 1 CustomerID, COUNT(*) AS ActivityCount
FROM Activities$
GROUP BY CustomerID
ORDER BY ActivityCount DESC

---Identify any opportunities with missing or invalid probability values.
SELECT *
FROM Opportunities$
WHERE Probability < 0 OR Probability > 1 OR Probability IS NULL;

---Analyze the distribution of customers across different industries.
SELECT Industry, COUNT(*) AS CustomerCount
FROM Customers$
GROUP BY Industry;

---Identify customers with the longest average sales cycle
SELECT c.CustomerID, c.CustomerName, AVG(DATEDIFF(Month,o.CloseDate, o.CreatedDate)) AS AvgSalesCycle
FROM Customers$ c
JOIN Opportunities$ o ON c.CustomerID = o.CustomerID
WHERE o.Stage = 'Closed'
GROUP BY c.CustomerID, c.CustomerName
ORDER BY AvgSalesCycle DESC

---Calculate the total and average revenue per industry.
SELECT c.Industry, SUM(o.Amount) AS TotalRevenue, AVG(o.Amount) AS AvgRevenue
FROM Customers$ c
JOIN Opportunities$ o ON c.CustomerID = o.CustomerID
WHERE o.Stage = 'Closed'
GROUP BY c.Industry;

---Identify the most profitable customer and their associated opportunities.
SELECT Top 1 c.CustomerID, c.CustomerName, SUM(o.Amount) AS TotalRevenue
FROM Customers$ c
JOIN Opportunities$ o ON c.CustomerID = o.CustomerID
WHERE o.Stage = 'Closed'
GROUP BY c.CustomerID, c.CustomerName
ORDER BY TotalRevenue DESC






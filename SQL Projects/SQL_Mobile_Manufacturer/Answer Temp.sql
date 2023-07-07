--SQL Advance Case Study


--Q1--BEGIN 
	
SELECT		DL.State
FROM		FACT_TRANSACTIONS[FT]
INNER JOIN	DIM_LOCATION [DL]
ON			FT.IDLocation = DL.IDLocation
WHERE		FT.Date >= '2005' 
GROUP BY	DL.State;


--Q1--END


--Q2--BEGIN
	
SELECT		DMF.Manufacturer_Name, DL.State, SUM(FT.Quantity)[TOTAL_QTY]
FROM		DIM_MANUFACTURER [DMF]
INNER JOIN	DIM_MODEL [DM]
ON			DMF.IDManufacturer =DM.IDManufacturer
INNER JOIN	FACT_TRANSACTIONS [FT]
ON			DM.IDModel = FT.IDModel
INNER JOIN  DIM_LOCATION [DL]
ON			FT.IDLocation = DL.IDLocation
WHERE		[Country] = 'US' AND DMF.Manufacturer_Name = 'Samsung'
GROUP BY	DMF.Manufacturer_Name, DL.State
ORDER BY	TOTAL_QTY DESC;

--Q2--END


--Q3--BEGIN      
	
SELECT		FT.IDModel,DL.State,DL.ZipCode, COUNT(FT.IDCustomer)[Num_of_Transactions]
FROM		FACT_TRANSACTIONS[FT]
INNER JOIN	DIM_LOCATION [DL]
ON			FT.IDLocation = DL.IDLocation
GROUP BY	FT.IDModel,DL.State,DL.ZipCode;

--Q3--END


--Q4--BEGIN

SELECT		TOP 1 MIN(Unit_price)[MIN_PRICE], Model_Name
FROM		DIM_MODEL [DM]
GROUP BY	Model_Name
ORDER BY	MIN_PRICE;



--Q4--END

--Q5--BEGIN

SELECT		DMF.Manufacturer_Name, SUM(FT.Quantity)[Total_Quntity],ROUND(AVG(FT.TotalPrice),2)[AVG_Price]
FROM		DIM_MANUFACTURER [DMF]
INNER JOIN	DIM_MODEL [DM]
ON			DMF.IDManufacturer =DM.IDManufacturer
INNER JOIN	FACT_TRANSACTIONS [FT]
ON			DM.IDModel = FT.IDModel
WHERE		DMF.Manufacturer_Name != 'HTC'
GROUP BY	DMF.Manufacturer_Name
ORDER BY	AVG_Price DESC ;






--Q5--END

--Q6--BEGIN

WITH CET1 AS (

SELECT		FT.IDCustomer, AVG(FT.TotalPrice) [Price]
FROM		FACT_TRANSACTIONS [FT]

WHERE		YEAR(FT.DATE) = '2009'
GROUP BY	FT.IDCustomer
)

SELECT		DC.Customer_Name, C1.Price
FROM		DIM_CUSTOMER [DC]

INNER JOIN	CET1 [C1]
ON			DC.IDCustomer = C1.IDCustomer 

WHERE		C1.Price > 500;








--Q6--END
	
--Q7--BEGIN  




Select* from  (Select Top 5 IDModel
from
FACT_TRANSACTIONS
Where Year(Date) IN ('2008')
Group By IDModel,Year(Date)
order by sum(quantity) desc
) t1

INTERSECT

Select* from  (Select Top 5 IDModel
from
FACT_TRANSACTIONS
Where Year(Date) IN ('2009')
Group By IDModel,Year(Date)
order by sum(quantity) desc
) t2
INTERSECT

Select* from  (Select Top 5 IDModel
from
FACT_TRANSACTIONS
Where Year(Date) IN ('2010')
Group By IDModel,Year(Date)
order by sum(quantity) desc
) t3




--Q7--END	
--Q8--BEGIN


WITH		CET1	AS (
SELECT		DMF.Manufacturer_Name,Year(Date)[Sales_Year]
			,Dense_rank() OVER(Partition By (Year(Date))ORDER BY SUM(TotalPrice) DESC) 
			AS [Sales_Rank]
FROM		FACT_TRANSACTIONS [FT]

INNER JOIN	DIM_MODEL [DM]
ON			DM.IDModel = FT.IDModel

INNER JOIN	DIM_MANUFACTURER [DMF]
ON			DM.IDManufacturer = DMF.IDManufacturer

WHERE		YEAR(Date) IN ('2009', '2010')
						 
GROUP BY	DMF.Manufacturer_Name,
			FT.IDModel,YEAR(Date)
)

SELECT * FROM CET1
WHERE	Sales_Rank = 2;




--Q8--END
--Q9--BEGIN
	

SELECT		DMF.Manufacturer_Name
FROM		FACT_TRANSACTIONS [FT]
INNER JOIN	DIM_MODEL [DM]
ON			DM.IDModel = FT.IDModel
INNER JOIN	DIM_MANUFACTURER [DMF]
ON			DM.IDManufacturer = DMF.IDManufacturer
WHERE		YEAR(FT.Date) = '2010'

Except

SELECT		DMF.Manufacturer_Name
FROM		FACT_TRANSACTIONS [FT]
INNER JOIN	DIM_MODEL [DM]
ON			DM.IDModel = FT.IDModel
INNER JOIN	DIM_MANUFACTURER [DMF]
ON			DM.IDManufacturer = DMF.IDManufacturer
WHERE		YEAR(FT.Date) = '2009';




--Q9--END

--Q10--BEGIN
	

SELECT	    TOP 100 DM.Customer_Name
			,FT.IDCustomer
			,AVG(Quantity)[Avg_Qty]
			,AVG(TotalPrice)[Avg_Spend]
			,Sum(TotalPrice)[Total_Spend]
			,LAG(Sum(TotalPrice),1) over(order by FT.IDCustomer) [Pre_Yr_Spend]
			,((Sum(TotalPrice)-LAG(Sum(TotalPrice),1) over(order by FT.IDCustomer))/LAG(Sum(TotalPrice),1) over(order by FT.IDCustomer))*100 [YoY_Spend_Percent]
			,Year(Date)[S_Year]

FROM		FACT_TRANSACTIONS[FT]
INNER JOIN	DIM_CUSTOMER[DM]
ON			FT.IDCustomer = DM.IDCustomer 
GROUP BY	FT.IDCustomer,Year([Date]),DM.Customer_Name
ORDER BY	[Avg_Spend] desc;







--Q10--END
	
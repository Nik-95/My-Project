USE Project
--========================================
select * from [dbo].[Customer]

Alter Table [dbo].[Customer]
Alter Column Customer_id bigint;

Alter Table [dbo].[Customer]
Alter Column Gender varchar(7);

Alter Table [dbo].[Customer]
Alter Column city_code int;
--================================
--S1 TO CHANGE DATA TYPE
UPDATE Customer
SET DOB = CONVERT(DATE,DOB,105)
--S2
Alter Table [dbo].[Customer]
Alter Column [DOB]DATETIME ;
--===============================
SELECT * FROM Customer

--===========================================
select * from[dbo].[prod_cat_info]
--===========================================

select * from[dbo].[Transactions]

Alter Table [dbo].[Transactions]
Alter Column [prod_subcat_code] tinyint

Alter Table [dbo].[Transactions]
Alter Column [prod_cat_code] tinyint

Alter Table [dbo].[Transactions]
Alter Column [Qty] int

update Transactions 
set tran_date = convert(date,tran_date,105)

select * from Transactions

alter table transactions 
alter column tran_date date
--========================================
--Q1
select count(*) from [dbo].[Customer] 
select count(*) from[dbo].[prod_cat_info]
select count(*) from[dbo].[Transactions]

--Q2
select Count([transaction_id]) from[dbo].[Transactions];


--Q3
update Transactions 
set tran_date = convert(date,tran_date,105)

ALTER TABLE [dbo].[Transactions]
ALTER COLUMN trans_date year;

--Q4

Select min(tran_date)[First_tran_date]
,max(tran_date)[Last_trns_date]
,DATEDIFF(day,
    (SELECT MIN(tran_date) FROM [dbo].[Transactions]),  
    (SELECT MAX(tran_date) FROM [dbo].[Transactions])) [Date_Diff]
	,DATEDIFF(month,
    (SELECT MIN(tran_date) FROM [dbo].[Transactions]),  
    (SELECT MAX(tran_date) FROM [dbo].[Transactions])) [Date_Month]
	,DATEDIFF(Year,
    (SELECT MIN(tran_date) FROM [dbo].[Transactions]),  
    (SELECT MAX(tran_date) FROM [dbo].[Transactions])) [Date_Year]
from [dbo].[Transactions];


--Q5
select Prod_cat from[dbo].[prod_cat_info]
where prod_subcat ='DIY'



--DATA ANALYSIS

--Q1
Select		Top 1 Count(store_type)[num_of_Times], store_type 
from		[dbo].[Transactions]
group by	Store_type
order by	[num_of_Times] DESC;

--Q2
Select		Gender, count(Gender) from[dbo].[Customer]
Where		gender = 'M' or gender = 'F'
Group by	Gender;

--Q3
Select		count(distinct(customer_id))[Num_of_cust], city_code
From		[dbo].[Customer]
Group by	city_code
order by	Num_of_cust DESC;

--Q4
Select		[prod_cat], COUNT(DISTINCT(prod_subcat))[TOTAL_SUB_CAT]
From		[dbo].[prod_cat_info]
WHERE		[prod_cat] = 'BOOKS'
GROUP BY	prod_cat;

--Q5
SELECT		 P.[prod_cat], COUNT(QTY) [TOTAL_SOLD_ITEM]
FROM		[dbo].[Transactions] [T]
INNER JOIN	[dbo].[prod_cat_info] [P]
ON			T.[prod_cat_code] = P.[prod_cat_code]
GROUP BY	P.[prod_cat]
ORDER BY	[TOTAL_SOLD_ITEM] DESC;

--Q6
SELECT		P.[prod_cat], (SUM(T.TOTAL_AMT))-(SUM(TAX)) [NET_REVENUE]
FROM		prod_cat_info [P]
INNER JOIN	Transactions [T]
ON			P.[prod_cat_code] = T.[prod_cat_code]
WHERE		P.[prod_cat] = 'Electronics' OR P.[prod_cat] = 'Books'
AND			QTY NOT LIKE '-%' 
GROUP BY	P.[prod_cat];

--Q7
SELECT		cust_id,COUNT(transaction_id) [REPEATE_CUST]
FROM		[dbo].[Transactions]
GROUP BY	[cust_id], QTY
HAVING		QTY NOT LIKE '-%'
AND			COUNT(transaction_id) > 10;

--Q8
SELECT		P.[prod_cat],(SUM(T.TOTAL_AMT))-(SUM(TAX)) [REVENUE]
FROM		[dbo].[Transactions] [T]
INNER JOIN	[dbo].[prod_cat_info] [P]
ON			P.[prod_cat_code] = T.[prod_cat_code]
WHERE		[Store_type] = 'Flagship store'
AND			[prod_cat] IN ('Electronics','Clothing')
GROUP BY	P.[prod_cat];

--Q9
SELECT		P.[prod_subcat],ROUND((SUM(T.TOTAL_AMT))-(SUM(TAX)),2) [REVENUE]
FROM		[dbo].[Transactions] [T]
INNER JOIN	[dbo].[prod_cat_info] [P]
ON			P.[prod_cat_code] = T.[prod_cat_code]
INNER JOIN	[dbo].[Customer] [C]
ON			T.[cust_id] = C.[customer_Id]
WHERE		[Gender] = 'M'
AND			[prod_cat] IN ('Electronics')
GROUP BY	P.[prod_subcat];

--Q10
WITH CET1 AS 
( SELECT [prod_subcat_code], SUM(ABS(TOTAL_AMT))[TOTAL_SALES] FROM  [dbo].[Transactions]
GROUP BY [prod_subcat_code] 
),

CET2 AS
( SELECT [prod_subcat_code], SUM(ABS(TOTAL_AMT))[RETURN_SALES] FROM  [dbo].[Transactions]
WHERE	total_amt LIKE '-%'
GROUP BY [prod_subcat_code]
),
CET3 AS (
 SELECT		CET1.prod_subcat_code,
			ROUND((TOTAL_SALES-RETURN_SALES)*100/TOTAL_SALES,2) [SALES_Revenue_PERCENT]
  FROM		CET1, CET2
  )

  Select	 TOP 5 PR.prod_subcat,(T.prod_subcat_code),
			(SUM(ABS(QTY))-SUM(QTY))*100/SUM(ABS(QTY))[RETURN_Qty_PROD_PERCENT],
			C3.[SALES_Revenue_PERCENT]
FROM		[dbo].[Transactions][T]
INNER JOIN	CET3 [C3] 
ON			T.prod_subcat_code = C3.prod_subcat_code
INNER JOIN	[dbo].[prod_cat_info][PR]
ON			T.prod_cat_code = PR.prod_cat_code
GROUP BY	C3.[SALES_Revenue_PERCENT],T.prod_subcat_code,PR.prod_subcat
ORDER BY	[SALES_Revenue_PERCENT] DESC;

--Q11

	SELECT CUST_ID,SUM(TOTAL_AMT) AS REVENUE FROM Transactions
WHERE CUST_ID IN 
	(SELECT CUSTOMER_ID
	 FROM CUSTOMER
     WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
     AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,
	 (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)
GROUP BY CUST_ID

--Q12

select tran_date, prod_cat_code,total_amt into prod_amt from Transactions
where total_amt<0 and datediff(month, tran_date,'2014-02-28')<=3

select top 1 p.prod_cat, prodamt.prod_cat_code,sum(total_amt)[total value of returns] from prodamt inner join prod_cat_info p
on prodamt.prod_cat_code=p.prod_cat_code
group by prodamt.prod_cat_code, p.prod_cat 
order by sum(total_amt) asc


--Q13
SELECT		(Store_type),ROUND(SUM(total_amt),2)[Amt_Sum],SUM(Qty)[Total_Qty]
FROM		Transactions
Group BY	Store_type
Order BY	Amt_Sum DESC;

-- Q14
select p.prod_cat, avg(t.total_amt)[Avg_per_cat] into prod_value from prod_cat_info p inner join Transactions t on
p.prod_cat_code=t.prod_cat_code
group by p.prod_cat


select * from (select *, avg(Avg_per_cat) over ()[Overall_Avg]  from prodvalue) t1
where t1.Avg_per_cat > t1.Overall_Avg

--Q15
select p.prod_cat_code, p.prod_subcat,avg(t.total_amt)[Avg_sales], sum(t.total_amt)[total_sales], sum(t.Qty)[avg_qty] 
into prod_1 from prod_cat_info p inner join Transactions t on
p.prod_cat_code=t.prod_cat_code
group by p.prod_cat_code, p.prod_subcat


select top 5 p.prod_cat_code, p.prod_cat, sum(qty)[qty] into prod_2 from prod_cat_info p inner join Transactions t on
p.prod_cat_code=t.prod_cat_code
group by p.prod_cat_code, p.prod_cat
order by sum(qty) desc


select prod1.prod_cat_code, prod1.prod_subcat,prod1.total_sales, prod1.Avg_sales, prod1.avg_qty
from prod1 inner join prod2 on prod1.prod_cat_code=prod2.prod_cat_code
order by avg_qty desc

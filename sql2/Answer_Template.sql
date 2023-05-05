--SQL Advance Case Study

--Q1--BEGIN 
 select l.State as State,f.IDCustomer as CustomerID,Year(f.Date) as Year from FACT_TRANSACTIONS as f,DIM_LOCATION as l 
 where year(Date) >=2005 
 and 
 l.IDLocation=f.IDLocation order by year
 

--Q1--END

--Q2--BEGIN
 select top 1  l.Country,  l.State, count(m.IDManufacturer)[samsung_user] from FACT_TRANSACTIONS [f]
 inner join DIM_LOCATION [l] on f.IDLocation = l.IDLocation 
 inner join DIM_MODEL [m]  on f.IDModel = m.IDModel
 where country ='US'
 group by l.State ,l.Country
 order by count(m.IDManufacturer) desc



--Q2--END

--Q3--BEGIN      
	

select f.IdModel,l.ZipCode,l.State,count(f.Idmodel)[no_of_transcation] from FACT_TRANSACTIONS[f]
inner join DIM_LOCATION[l] on f.IDLocation =l.IDLocation 
group by f.IDModel, 

l.zipcode , l.State







--Q3--END

--Q4--BEGIN

---- I have added manufacturer_name from manufacturer table  ----
select top 1 ma.Manufacturer_Name , m.Model_Name,m.Unit_price 
from DIM_MODEL[m]
inner join DIM_MANUFACTURER[ma] on m.IDManufacturer = ma.IDManufacturer  
order by Unit_price 





--Q4--END

--Q5--BEGIN(question). 
select o.Manufacturer_Name, m.IDModel, sum(f.quantity)[quantity],avg(f.totalprice)[avg_price] from FACT_TRANSACTIONS[f] 
inner join DIM_MODEL[m] on f.IDModel = m.IDModel
inner join DIM_MANUFACTURER[o] on o.IDManufacturer = m.IDManufacturer  where o.Manufacturer_Name in 


(select top 5 o.Manufacturer_Name from FACT_TRANSACTIONS[f] 
inner join DIM_MODEL[m] on f.IDModel = m.IDModel
inner join DIM_MANUFACTURER[o] on o.IDManufacturer = m.IDManufacturer 
group by o.Manufacturer_Name order by avg(f.totalprice) desc)

group by m.IDModel,o.Manufacturer_Name 
order by avg(f.totalprice) desc

--Q5--END

--Q6--BEGIN
select c.Customer_Name,avg(f.totalprice)[avg_price] from FACT_TRANSACTIONS[f] 
inner join DIM_CUSTOMER[c] on f.IDCustomer = c.IDCustomer
where year(date) = 2009 
group by c.Customer_Name having avg(f.totalprice)>500 order by [avg_price]


--Q6--END
	
--Q7--BEGIN  
	

----advance sql---
with cte1 as 
(select rn1=rank() over (partition by year(date) order by sum(quantity) desc),IDModel,year(date)[year],sum(quantity)[sum_quantity] from FACT_TRANSACTIONS 
where year(date) in ('2008','2009','2010')
group by IDModel,year(date))

select Idmodel from cte1 where  rn1<6 group by idmodel having count(Idmodel) = 3


--Q7--END	
--Q8--BEGIN
---sql--

select * from
(select m.Manufacturer_Name,sum(totalprice)[2rd_TotalSales] , Year='2009' from FACT_TRANSACTIONS[f],DIM_MANUFACTURER[m],DIM_MODEL[ma]
where year(date)='2009' and f.IDModel=ma.IDModel and ma.IDManufacturer = m.IDManufacturer 
group by m.Manufacturer_Name 
order by [2rd_TotalSales] desc 
OFFSET 1 ROWS
FETCH NEXT 1 ROWS ONLY

union all

select m.Manufacturer_Name,sum(totalprice)[2rd_TotalSales] , Year='2010' from FACT_TRANSACTIONS[f],DIM_MANUFACTURER[m],DIM_MODEL[ma]
where year(date)='2010' and f.IDModel=ma.IDModel and ma.IDManufacturer = m.IDManufacturer
group by m.Manufacturer_Name
order by [2rd_TotalSales] desc 
OFFSET 1 ROWS
FETCH NEXT 1 ROWS ONLY) as f

---advance sql--
with cte1 as 
(select rn=rank() over (partition by year(f.date) order by sum(f.totalprice) desc),o.Manufacturer_Name,sum(f.TotalPrice)[t],Year(Date)[year] from  FACT_TRANSACTIONS[f] 
inner join DIM_MODEL[m] on f.IDModel = m.IDModel 
inner join DIM_MANUFACTURER[o] on o.IDManufacturer = m.IDManufacturer 
where year(date) in ('2009','2010') 
group by Manufacturer_Name , year(date))

select * from cte1 where rn = 2


--Q8--END
--Q9--BEGIN
	
select distinct(ma.Manufacturer_Name)[not_manufacturer_2009] from FACT_TRANSACTIONS[f],DIM_MODEL[m],DIM_MANUFACTURER[ma] 
where year(date)=2010  and f.IDModel =m.IDModel and m.IDManufacturer = ma.IDManufacturer and ma.Manufacturer_Name not in(
select distinct(ma.Manufacturer_Name) from FACT_TRANSACTIONS[f],DIM_MODEL[m],DIM_MANUFACTURER[ma] 
where year(date)=2009  and f.IDModel =m.IDModel and m.IDManufacturer = ma.IDManufacturer)



--Q9--END

--Q10--BEGIN . Find top 100 customers and their average spend, average quantity by each
---year. Also find the percentage of change in their spend.
-----giving rank for each year-----
	 select
    Customer_Name, 
    AVG(TotalPrice) as Average_Spend, 
    AVG(Quantity) as Avg_Qty,
    YEAR(Date) as [YEAR],
    ROW_NUMBER() over(PARTITION by YEAR(Date)
                      order by AVG(TotalPrice) desc) as rn
into #all_customers
from DIM_CUSTOMER as c 
inner join FACT_TRANSACTIONS as t
    on c.IDCustomer = t.IDCustomer
Group By Customer_Name, YEAR(Date);

-----based on rnk geting top 5 foreach year-----
select *
into #top_customers
from #all_customers
where rn <= 5
----------------YOY ------------
select
    L.Customer_Name,
    L.Year,
    L.Average_Spend,
    L.rn,
    R.Year as [Year_next],
    R.Average_Spend as Average_Spend_next,
    R.rn as rn_next,
    1.0 * R.Average_Spend / L.Average_Spend - 1.0 as diff
from #top_customers as L
left join #all_customers as R
    on L.Customer_Name = R.Customer_Name
    and R.[YEAR] = L.[YEAR] + 1 ;

select * from  #all_customers
select * from  #top_customers





--Q10--END
	

	
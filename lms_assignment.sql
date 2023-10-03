use classicmodels;

select wc.Name,sum(quantityOrdered*priceEach) as total_sales 
from  orderdetails join orders using (orderNumber)
join customers c using (customerNumber)
right join world.country wc on c.country=wc.Name
group by wc.Name;


------------------

select wcc.Name , sum(wct.population) as total_population , sum(quantityOrdered*priceEach) as total_sales 
from world.city wct join world.country wcc
on wct.CountryCode=wcc.code
join customers c on c.country=wcc.Name
join orders using (customerNumber)
join orderdetails using (orderNumber)
group by wcc.Name;

---------------








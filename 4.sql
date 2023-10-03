/* 1. “HealthDirect” pharmacy finds it difficult to deal with the product type of medicine being displayed 
in numerical form, they want the product type in words. Also, they want to filter the medicines based on tax criteria. 
Display only the medicines of product categories 1, 2, and 3 for medicines that come under tax category I 
and medicines of product categories 4, 5, and 6 for medicines that come under tax category II.
Write a SQL query to solve this problem.
ProductType numerical form and ProductType in words are given by
1 - Generic, 
2 - Patent, 
3 - Reference, 
4 - Similar, 
5 - New, 
6 - Specific,
7 - Biological, 
8 – Dinamized

3 random rows and the column names of the Medicine table are given for reference.
Medicine (medicineID, companyName, productName, description, substanceName, productType, taxCriteria, 
hospitalExclusive, governmentDiscount, taxImunity, maxPrice). */


with cat as(select medicineID ,productType,case when productType = 1 then 'Generic'
when productType=2 then 'Patent'
when productType=3 then 'Reference'
end as product_category
from medicine 
where taxCriteria='I' and  productType in (1,2,3)),
cat2 as (select medicineID ,productType,case when productType=4 then 'Similar'
when productType=5 then 'New'
when productType=6 then 'Specific'
end as product_category
from medicine where taxCriteria='II' and productType in (4,5,6))
select medicineID, productType,product_category from cat 
join keep using (medicineID)
join pharmacy using (pharmacyID)
where pharmacyName like 'HealthDirect'
union 
select medicineID ,productType,product_category from cat2
join keep using (medicineID)
join pharmacy using (pharmacyID)
where pharmacyName like 'HealthDirect';

-----
/*2. 'Ally Scripts' pharmacy company wants to find out the quantity of medicine prescribed in each of its prescriptions.
Write a query that finds the sum of the quantity of all the medicines in a prescription and if the total quantity 
of medicine is less than 20 tag it as “low quantity”. If the quantity of medicine is from 20 to 49 
(both numbers including) tag it as “medium quantity“ and 
if the quantity is more than equal to 50 then tag it as “high quantity”.
Show the prescription Id, the Total Quantity of all the medicines in that prescription, 
and the Quantity tag for all the prescriptions issued by 'Ally Scripts'.
3 rows from the resultant table may be as follows:
prescriptionID	totalQuantity	Tag
1147561399		43			Medium Quantity
1222719376		71			High Quantity
1408276190		48			Medium Quantity*/


with p as (select prescriptionID,sum(quantity) as totalQuantity,
case 
	when sum(quantity) < 20 then "low quantity"
    when sum(quantity) >=20 and sum(quantity)<=49 then "medium quantity"
    when sum(quantity)>=50 then "high quantity"
    end as Tag
from contain
group by prescriptionID)
select prescriptionID,totalQuantity,Tag
from p 
join prescription using (prescriptionID)
join pharmacy using (pharmacyID)
where pharmacyName like 'Ally Scripts' ;

-----
/* 3. In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’ 
when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls short of 1000.
 The discount is considered “HIGH” if the discount rate on a product is 30% or higher, 
 and the discount is considered “NONE” when the discount rate on a product is 0%.
 'Spot Rx' needs to find all the Low quantity products with high discounts
 and all the high-quantity products with no discount so they can adjust the discount rate according to the demand. 
Write a query for the pharmacy listing all the necessary details relevant to the given requirement.
Hint: Inventory is reflected in the Keep table. */

with m as (
select medicineID,quantity,discount,
case 
	when quantity >7500 then "High quantity"
    when quantity <1000 then "Low quantity"
    end as Tag,
case 
	when discount >=30 then "High"
    else "None"
end as discount_tag
from keep
join pharmacy using (pharmacyID)
where pharmacyName like 'Spot Rx')

select medicineID , Tag , discount_tag 
from m
where (Tag="High quantity" and discount_tag="None")
or (Tag="Low quantity" and discount_tag="High")
order by Tag ;

-----
/*4. Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, 
hospital-exclusive medicines in the database. Where affordable medicines are the medicines that have a 
maximum price of less than 50% of the avg maximum price of all the medicines in the database, 
and costly medicines are the medicines that have a maximum price of more than double the 
avg maximum price of all the medicines in the database.  Mack wants clear text next to each medicine name
to be displayed that identifies the medicine as affordable or costly. 
The medicines that do not fall under either of the two categories need not be displayed.
Write a SQL query for Mack for this requirement. */

select medicineID, maxprice ,
case 
	when maxprice < 0.5* (select avg(maxprice) as average
from medicine) then "less price"
    when maxprice > 2*(select avg(maxprice) as average
from medicine) then "max price"
end as tag
from medicine
join keep using (medicineID)
join pharmacy using (pharmacyID)
where hospitalExclusive='S'
and pharmacyName like 'HealthDirect';

-----

/*5.The healthcare department wants to categorize the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.

Write a SQL query to list all the patient name, gender, dob, and their category.*/

select personName,gender,dob,
case when dob >= '2005-01-01' then if (gender='male',"YoungMale","YoungFemale")
when dob< '2005-01-01' and dob >= '1985-01-01' then if (gender='male',"AdultMale","AdultFemale")
when dob< '1985-01-01' and dob >= '1970-01-01' then if (gender='male',"MidMale","MidFemale")
when dob< '1970-01-01' then if (gender='male',"ElderMale","ElderFemale")
end as age_category
from person join patient on person.personID=patient.patientID;


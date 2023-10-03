use health_care;

with age_category as (select patientID,case when FLOOR(DATEDIFF(CURDATE(), dob) / 365) > 0 and FLOOR(DATEDIFF(CURDATE(), dob) / 365) <=14 then "Children"
when floor(datediff(curdate(),dob)/365)>14 and  FLOOR(DATEDIFF(CURDATE(), dob) / 365) <=24 then "Youth"
when  FLOOR(DATEDIFF(CURDATE(), dob) / 365)>24 and  FLOOR(DATEDIFF(CURDATE(), dob) / 365)<=64 then "Adult"
when  FLOOR(DATEDIFF(CURDATE(), dob) / 365) >64 then "Seniors"
end as category 
from patient)
select category,count(category) from age_category join treatment using (patientID) where year(date)=2022 group by category;

with female_count as (select count(patientID) as femalecount,diseaseName from disease join treatment using (diseaseID) 
join person on treatment.patientID=person.personID
where gender='female'
group by diseaseID),
male_count as(select count(patientID) as malecount,diseaseName from disease join treatment using (diseaseID) 
join person on treatment.patientID=person.personID
where gender='male'
group by diseaseID )
select malecount/femalecount as ratio , diseaseName from female_count join male_count using(diseaseName) order by ratio desc;

select gender,count(distinct(treatmentID)) as treatments ,
count(distinct(claimID)) as claims, count(distinct(treatmentID))/count(distinct(claimID)) as ratio
from treatment join person on treatment.patientID=person.personID 
group by gender;

select pharmacyID ,count(quantity) as units ,
sum(maxprice) as retail_price,sum(maxprice-maxprice*(discount*0.01)) as discount_price
from keep join medicine using (medicineID)
group by pharmacyID;

with quantity_count as (select pharmacyID,prescription.prescriptionID ,sum(quantity) as quantity
from contain join prescription on contain.prescriptionID=prescription.prescriptionID
group by prescriptionID,pharmacyID)
select max(quantity),min(quantity),avg(quantity) from quantity_count 
group by pharmacyID;


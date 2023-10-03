use health_care;

/* 1.Jimmy, from the healthcare department, has requested 
a report that shows how the number of treatments each age category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years),
Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report. 
*/

with age_category 
as (select patientID,case when FLOOR(DATEDIFF(CURDATE(), dob) / 365) > 0 
and FLOOR(DATEDIFF(CURDATE(), dob) / 365) <=14 then "Children"
when floor(datediff(curdate(),dob)/365)>14 and  FLOOR(DATEDIFF(CURDATE(), dob) / 365) <=24 then "Youth"
when  FLOOR(DATEDIFF(CURDATE(), dob) / 365)>24 and  FLOOR(DATEDIFF(CURDATE(), dob) / 365)<=64 then "Adult"
when  FLOOR(DATEDIFF(CURDATE(), dob) / 365) >64 then "Seniors"
end as category 
from patient)
select category,count(category)
from age_category join treatment using (patientID) 
where year(date)=2022 
group by category;


/* 2.Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio.
Sort the data in a way that is helpful for Jimmy.
*/

with female_count as 
(select count(patientID) as femalecount,diseaseName from disease join treatment using (diseaseID) 
join person on treatment.patientID=person.personID
where gender='female'
group by diseaseID),
male_count as 
(select count(patientID) as malecount,diseaseName
from disease join treatment using (diseaseID) 
join person on treatment.patientID=person.personID
where gender='male'
group by diseaseID )
select malecount/femalecount as ratio , diseaseName 
from female_count join male_count using(diseaseName) order by ratio desc;

/* 3.Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments.
 He also wants to figure out if the gender of the patient has any impact on the insurance claim.
 Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, 
 number of claims, and treatment-to-claim ratio.
 And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients.*/
 
select gender,count(distinct(treatmentID)) as treatments ,
count(distinct(claimID)) as claims, 
count(distinct(treatmentID))/count(distinct(claimID)) as ratio
from treatment join person on treatment.patientID=person.personID 
group by gender;

/* 4. The Healthcare department wants a report about the inventory of pharmacies.
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory, 
the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price. */
select pharmacyID ,count(quantity) as units ,
sum(maxprice) as retail_price,sum(maxprice-maxprice*(discount*0.01)) as discount_price
from keep join medicine using (medicineID)
group by pharmacyID;

/* 5. The healthcare department suspects that some pharmacies prescribe more medicines 
 than others in a single prescription, for them, generate a report that
 finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions. */

with quantity_count as 
(select pharmacyID,prescription.prescriptionID ,sum(quantity) as quantity
from contain join prescription on contain.prescriptionID=prescription.prescriptionID
group by prescriptionID,pharmacyID)
select max(quantity),min(quantity),avg(quantity) from quantity_count 
group by pharmacyID;


use health_care;

#--------1.

/*Brian, the healthcare department, has requested for a report 
that shows for each state how many people underwent treatment for the disease “Autism”. 
 He expects the report to show the data for each state as well as each gender and for each state and gender combination. 
Prepare a report for Brian for his requirement. */

select state,gender, count(patientID)
from address join person using (addressID)
join treatment on person.personID=treatment.patientID
join disease using (diseaseID)
where diseaseName like 'Autism'
group by state,gender with rollup;

#---------2.
/*Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan, 
and the number of treatments the plan was claimed for. The report would be more relevant 
if the data compares the performance for different years(2020, 2021 and 2022) and 
if the report also includes the total number of claims in the different years, 
as well as the total number of claims for each plan in all 3 years combined.*/

select companyName, planName,year(date),count(claimID) as total_claimed
from insurancecompany join insuranceplan
using (companyID) join claim using (uin)
left join treatment using (claimID)
where year(date)!=2019
group by companyName,planName,year(date) with rollup;

#-----3.

/*Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows each state the number of the most and least treated diseases
 by the patients of that state in the year 2022. It would be helpful for 
 Sarah if the aggregation for the different combinations is found as well. Assist Sarah to create this report. */

with s as (select state,diseaseName,
count(patientID) as cnt
from address join person 
using (addressID) join treatment 
on person.personID=treatment.patientid
right join disease using (diseaseID)
where year(date)='2022'
group by state,diseaseName with rollup
order by state,cnt desc),
ordered as (select state,diseaseName,cnt,
row_number() over (partition by state order by cnt desc) rnk_high,
row_number() over (partition by state order by cnt) rnk_low
from s)
select coalesce(state,"All state") as state,
coalesce(diseaseName,"All disease") as disease,cnt
from ordered 
where rnk_high<5 or rnk_low <4; 
# here rnk_high taken as 5 bec the total roll up is also considered .

#----------4.

/*Jackson has requested a detailed pharmacy report that shows each pharmacy name, 
and how many prescriptions they have prescribed for each disease in the year 2022, 
along with this Jackson also needs to view how many prescriptions were prescribed by each pharmacy, 
and the total number prescriptions were prescribed for each disease.
Assist Jackson to create this report. */

select pharmacyName,diseaseName,count(prescriptionID)
from pharmacy left join prescription using(pharmacyID)
join treatment using (treatmentID)
join disease using (diseaseID)
where year(date)=2022
group by pharmacyName,diseaseName with rollup;


#--------5.
/*Praveen has requested for a report that finds for every disease how many males and females underwent treatment 
for each in the year 2022. It would be helpful for Praveen if the aggregation for the different combinations 
is found as well.
Assist Praveen to create this report. */

select diseaseName,gender,count(treatmentID)
from disease join treatment using (diseaseID)
left join person 
on treatment.patientID=person.personID
where year(date)=2022
group by diseaseName,gender with rollup;
 
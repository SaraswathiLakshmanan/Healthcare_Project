use health_care;

/*1.Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, 
and their age,
Sort the data in a way that the patients who have undergone more treatments appear on top.*/

select personName , year(now())-year(dob) as age , count(treatmentID) as cnt
from person right join patient
on person.personID=patient.patientID
join treatment using (patientID)
group by patientID
having cnt > 1
order by cnt desc;
-----

/*2.Bharat is researching the impact of gender on different diseases, He wants to analyze 
if a certain disease is more likely to infect a certain gender or not.
Help Bharat analyze this by creating a report showing for every disease 
how many males and females underwent treatment for each in the year 2021.
 It would also be helpful for Bharat if the male-to-female ratio is also shown.*/

with female as (select diseaseID,count(*) as female_cnt
from person right join patient
on person.personID=patient.patientID
join treatment using (patientID)
join disease using (diseaseID)
where year(date)='2021'
and gender='female'
group by diseaseID),
male as (select diseaseID,count(*) as male_cnt
from person right join patient
on person.personID=patient.patientID
join treatment using (patientID)
join disease using (diseaseID)
where year(date)='2021'
and gender='male'
group by diseaseID)
select diseaseID,female_cnt,male_cnt,round(female_cnt/male_cnt,2) as ratio
from female join male
using (diseaseID)
order by diseaseID;

-----
/*3.Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, 
the top 3 cities that had the most number treatment for that disease.
Generate a report for Kelly’s requirement.
---- 
*/

with d as (select diseaseID , city , count(treatmentID) as cnt,
dense_rank() over ( partition by diseaseID  order by count(treatmentID) desc)as rnk
from disease join treatment using (diseaseID)
join person on treatment.patientID=person.personID
join address using (addressID)
group by diseaseID , city)
select diseaseID,city, cnt 
from d 
where rnk <4;


-----
/*4.Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not,
For this purpose, she has requested a detailed pharmacy report that shows each pharmacy name,
and how many prescriptions they have prescribed for each disease in 2021 and 2022, 
She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
Write a query for Brooke’s requirement.*/

with t21 as (select diseaseName, pharmacyName , count(prescriptionID) as cnt
from disease join treatment using (diseaseID)
join prescription using (treatmentID)
join pharmacy using (pharmacyID)
where year(date)='2021'
group by diseaseName,pharmacyName),
t22 as (select diseaseName, pharmacyName , count(prescriptionID) as cnt
from disease join treatment using (diseaseID)
join prescription using (treatmentID)
join pharmacy using (pharmacyID)
where year(date)='2022'
group by diseaseName,pharmacyName)

select diseaseName,t21.pharmacyName,t21.cnt as year_21,t22.cnt as year_22
from t21 left join t22
using(diseaseName,pharmacyName)
union 
select diseaseName,t22.pharmacyName,t21.cnt as year_21,t22.cnt as year_22
from t21 right join t22
using(diseaseName,pharmacyName);

-----
/*5.Walde, from Rock tower insurance, has sent a requirement for a report that presents 
which insurance company is targeting the patients of which state the most. 
Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more 
if the patients of that region are claiming more insurance of that company.*/

with c as (select state,companyName
from address
join insuranceCompany 
using (addressID)
order by state),
ct as (select state,count(patientID) as cnt
from address join person using (addressID)
join patient on person.personID=patient.patientID
join treatment using (patientID)
group by state
order by state)
select companyName,state,cnt
from c join ct
using (state)
order by companyName,cnt;

use health_care;


-----
select personName , year(now())-year(dob) as age , count(treatmentID) as cnt
from person right join patient
on person.personID=patient.patientID
join treatment using (patientID)
group by patientID
having cnt > 1
order by cnt desc;
-----

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

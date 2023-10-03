/* 1. Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine 
that they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, 
wants to get a report of which pharmacies have prescribed hospital-exclusive medicines
 the most in the years 2021 and 2022. Assist Joshua to generate the report so that
 the pharmacies who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.*/
 
select pharmacyName,pharmacyID,count(pharmacyID) as c
from pharmacy join prescription using (pharmacyID) 
join treatment using (treatmentID) 
where prescriptionID in 
(select distinct(prescriptionID) 
from contain join medicine using (medicineID) 
where hospitalExclusive='S') and 
year(treatment.date) in ('2021','2022')
group by pharmacyID order by c desc;
----

/*2. Insurance companies want to assess the performance of their insurance plans. Generate a report
 that shows each insurance plan, the company that issues the plan, 
 and the number of treatments the plan was claimed for.*/
 
 select companyName,planName, count(claimID) as claimed_count
 from insuranceCompany 
 join insuranceplan using (companyID)
 left join claim using (UIN)
 join treatment using (claimID)
 group by companyName,planName;
 
 ------
 /*3: Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance company's name with their most and least claimed insurance plans.*/
 
with pc as (select planName,companyName,companyID
from insurancecompany join
insuranceplan using (companyID) join claim using(uin)
join treatment using (claimID)
group by planName,companyID)
select companyName,max(planName) as mostclaimed, min(planName) as minclaimed
from pc group by companyID;

-----
/*4:  The healthcare department wants a state-wise health report to assess 
which state requires more attention in the healthcare sector. Generate a report for them that shows the state name, 
number of registered people in the state, 
number of registered patients in the state, and the people-to-patient ratio. sort the data by people-to-patient ratio. */

select state , count(distinct(personID)) as persons ,
count(distinct(patientID)) as patients ,
count(distinct(personID)) /count(distinct(patientID)) as person_to_patient_ratio
from address left join person using (addressID)
left join patient on person.personID=patient.patientID
group by state;

----
/*5.Jhonny, from the finance department of Arizona(AZ),
 has requested a report that lists the total quantity of medicine each pharmacy in his state 
 has prescribed that falls under Tax criteria I for treatments that took place in 2021. 
 Assist Jhonny in generating the report. */
 
with t as (select prescriptionID,sum(quantity) as quantity
from  contain
join medicine using (medicineID) 
where taxCriteria='I'
group by prescriptionID),
d as(select pharmacyID,prescriptionID
from treatment
join prescription
using (treatmentID)
where year(date)=2021),
s as (select distinct(pharmacyID) , pharmacyName
from address join pharmacy
using (addressID) where state='AZ')
select pharmacyID,pharmacyName, sum(quantity) from t join d 
using(prescriptionID) join
s using (pharmacyID)
group by pharmacyID;


/* 1. A company needs to set up 3 new pharmacies, 
they have come up with an idea that the pharmacy can be set up in cities 
where the pharmacy-to-prescription ratio is the lowest and the 
number of prescriptions should exceed 100. 
Assist the company to identify those cities where the pharmacy can be set up.
*/

with ctte as (select city,count(distinct(pharmacyID)) as pharmacy_cnt 
,count(prescriptionID) as cnt
from address right join pharmacy using (addressID)
join prescription using (pharmacyID)
group by city )
select city , pharmacy_cnt/cnt as ratio , cnt 
from ctte 
where cnt > 100
order by pharmacy_cnt/cnt 
limit 3;

-----
/* 2. The State of Alabama (AL) is trying to manage its healthcare resources more efficiently.
 For each city in their state, they need to 
identify the disease for which the maximum number of patients have gone for treatment. 
Assist the state for this purpose. */

with pc as (select city , personID 
from address 
join person using (addressID) 
where state = 'AL' and personID in (select distinct(patientID) from patient)),
dc as (select count(patientID) as patcount, diseaseName , city 
from pc join treatment on pc.personID=treatment.patientID 
join disease using (diseaseID)
group by diseaseName , city ),
t as (select rank() over  (partition by city order by patcount desc) as rnk,patcount,diseaseName,city
from dc )
select diseaseName , city ,rnk from t ;

-------

/* 3. The healthcare department needs a report about insurance plans. 
The report is required to include the insurance plan, which was claimed the most and least for each disease. 
 Assist to create such a report. */

with most_claimed_planName as (select diseaseName, planName ,count(claimID) as cnt,
row_number() over (partition by diseaseName order by count(claimID) desc,planName) as row_num_desc
from disease join treatment using (diseaseID)
join claim using (claimID)
join insuranceplan using (uin)
group by diseaseName , planName),
least_claimed_planName as (select diseaseName, planName ,count(claimID) as cnt,
row_number() over (partition by diseaseName order by count(claimID),planName) as row_num_asc
from disease join treatment using (diseaseID)
join claim using (claimID)
join insuranceplan using (uin)
group by diseaseName , planName)
select mc.diseaseName,mc.planName as most_claimed ,
lc.planName as least_claimed 
from most_claimed_planName mc join least_claimed_planName lc
using (diseaseName) 
where row_num_asc=1 and row_num_desc=1;

------------
/* 4. The Healthcare department wants to know which disease is most likely to infect 
multiple people in the same household.
For each disease find the number of households that has more than one patient with the same disease.*/
 
 select diseaseName,count(*) as household_count 
 from (select diseaseName , addressID,count(distinct(patientID))
 from disease left join treatment using (diseaseID)
 join patient using (patientID)
 join person on person.personID=patient.patientID
 join address using (addressID)
 group by diseaseName,addressID
 having count(distinct(patientID))>1)t
 group by diseaseName;
 
 ----------
 
 /* 5. An Insurance company wants a state wise report of the treatments to claim ratio
 between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report. */
 
 select state , count(treatmentID)/ count(claimID) as treatment_to_claim_ratio
 from address left join person using (addressID)
 join patient on person.personID=patient.patientID
 join treatment using (patientID)
 join disease using (diseaseID)
 where date between '2021-04-01' and '2022-03-31'
 group by state 
 order by  treatment_to_claim_ratio;
 

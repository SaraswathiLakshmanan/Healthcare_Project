/* 
1: The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed
 in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, 
total quantity of medicine prescribed in 2022, total quantity of hospital-exclusive medicine prescribed 
by the pharmacy in 2022, and the percentage of hospital-exclusive medicine to the total medicine prescribed in 2022.
Order the result in descending order of the percentage found. 
*/

select ph.pharmacyID,ph.pharmacyName,sum(quantity) as total_quantity_for_each ,
(sum(quantity)/(select sum(quantity) as total_quantity
					from prescription pr 
					join treatment t using(treatmentID)
					join pharmacy ph using(pharmacyID)
					join contain c using(prescriptionID)
					join medicine m using(medicineID)
					where year(t.date) = 2022
					and hospitalExclusive='S'))*100 as percentage_of_total
from prescription pr 
join treatment t using(treatmentID)
join pharmacy ph using(pharmacyID)
join contain c using(prescriptionID)
join medicine m using(medicineID)
where year(t.date) = 2022
and hospitalExclusive='S'
group by ph.pharmacyID,ph.pharmacyName
order by percentage_of_total desc
;

/*
2: Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. 
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance.
 Assist Sarah by creating a report as per her requirement.
*/

select state,count(treatmentID)as total_treatment,count(claimID) as total_claims,(count(claimID)/count(treatmentID)) *100 as percentage_of_claim
from treatment
join patient p using(patientID)
join person pr 
on pr.personID = p.patientID
join address a 
on a.addressID=pr.addressID
group by state
;

/*
3: Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases by the
 patients of that state in the year 2022. 
*/

with disease_count as 
(
select state,diseaseName,count(diseaseName) as count_dis,DENSE_RANK() over()
from disease
join treatment t using(diseaseID)
join patient p using(patientID)
left join person pr 
on pr.personID = p.patientID
join address a 
on a.addressID=pr.addressID
where year(t.date) =2022
group by state,diseaseName order by count_dis desc
)

select state,diseaseName,max(count_dis),min(count_dis) from disease_count
-- select state,max(diseaseName),min(diseaseName) from disease_count
group by state,diseaseName
limit 5
;

/*
 4: Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, 
 in each city. Generate a report that shows each city that has 10 or more registered people belonging to it
 and the number of patients from that city as well as the percentage of the patient with respect to the registered people.
 
*/

select city,count(personID) as person_count,count(patientID) as patient_count, (count(patientID)/count(personID))*100 as percentage_patient_to_person 
from address a 
join person pr using(addressID)
left join patient p 
on pr.personID = p.patientID
group by city
having person_count > 10
;

/* 5: It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects. Find the top 3 companies using the substance in their medicine so that they can be informed about it.
*/

select companyName,sum(quantity)as quantity
from medicine m
join contain c using(medicineID)
where substanceName like '%ranitidina%'
group by companyName
order by quantity desc
limit 3
;
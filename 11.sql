use health_care;

/* 1. Patients are complaining that it is often difficult to find some medicines. 
They move from pharmacy to pharmacy to get the required medicine. A system is required that finds the pharmacies 
and their contact number that have the required medicine in their inventory. 
So that the patients can contact the pharmacy and order the required medicine.
Create a stored procedure that can fix the issue. */

delimiter //

create procedure pharDetail(in medname varchar(20))
begin
	select pharmacyName,phone ,quantity
    from pharmacy join keep using (pharmacyID)
    join medicine using (medicineID)
    where productName=medname
    order by quantity desc;
end //
delimiter ;

call pharDetail("assert");

-----------------

/* 2. The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription,
 for all the prescriptions they have prescribed in a particular year. 
 Create a stored function that will return the required value when the pharmacyID and year are passed to it.
 Test the function with multiple values. 
 */
 
drop function avgcost;
delimiter //
create function avgcost(idd int , yr int)
returns decimal (10,2)
deterministic
begin 
	declare total_amnt decimal(10,2);
    declare total_pres int;
    
	select sum(quantity*maxprice) , count(distinct(prescriptionID))
    into total_amnt,total_pres 
    from prescription join treatment t using (treatmentID)
    join contain using (prescriptionID)
    join medicine using (medicineID)
    where pharmacyID=idd and 
    year(t.date) =yr;
    
    if total_pres > 0 then 
    return total_amnt/total_pres;
    else
    return 0.00;
    end if;
end //
delimiter ;
select avgcost(7454,2021) as avg_amount_per_pharmacy;


---------------
/*3. The healthcare department has requested an application that finds out the disease that was spread the most in a state for a given year.
 So that they can use the information to compare the historical data and gain some insight.
Create a stored function that returns the name of the disease for which the patients 
from a particular state had the most number of treatments for a particular year.
 Provided the name of the state and year is passed to the stored function.*/

use health_care;
drop function if exists maxdisease;

delimiter //
create function maxdisease( statee varchar(40),yrr int)
returns varchar(40)
deterministic 
begin 
	declare dN varchar(40);
	select diseaseName into dN
    from disease join treatment using (diseaseID)
    join patient using (patientID)
    join person on patient.patientID=person.personID
    join address using (addressID)
    where state=statee and year(date)=yrr
    group by state , diseaseName
    order by count(diseaseID) desc
    Limit 1;
    return dN ;
end //
delimiter ;
select maxdisease("AK",2018) as most_affected_disease;

#------------

/* 4. The representative of the pharma union, Aubrey, has requested a system that she can use to find how many people 
in a specific city have been treated for a specific disease in a specific year.
Create a stored function for this purpose. */


drop function if exists maxpatient;

delimiter //
create function maxpatient( diseasee varchar(40), cityy varchar(40),yrr int)
returns int
deterministic 
begin 
	declare cnt varchar(40);
	select count(patientID) into cnt
    from disease join treatment using (diseaseID)
    join patient using (patientID)
    join person on patient.patientID=person.personID
    join address using (addressID)
    where city=cityy and year(date)=yrr
    and diseaseName=diseasee
    order by count(patientID) desc;
    return cnt ;
end //
delimiter ;

select maxpatient("Chronic fatigue syndrome","Montgomery",2021) as patient;


------------------

/* 5. The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies. 
She has requested a system that can be used to find the average balance for claims submitted by a 
specific insurance company in the year 2022. 
Create a stored function that can be used in the requested application. */


drop function if exists avgbalance;
delimiter //
create function avgbalance(company varchar(60))
returns decimal (10,2)
deterministic 
begin 
	declare cnt decimal (10,2);
	select sum(balance) into cnt
    from insuranceCompany join insuranceplan using (companyID)
    join claim using (UIN)
    join treatment using (claimID)
    where companyName=company and year(date)=2022;
    return cnt ;
end //
delimiter ;

select avgbalance("Star Health and Allied Insurrance Co. Ltd.") as Average_balance;

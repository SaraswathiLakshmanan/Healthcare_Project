
/* 1. The healthcare department has requested a system to analyze the performance of insurance companies and their plan.
For this purpose, create a stored procedure that returns the performance of different insurance plans 
of an insurance company. When passed the insurance company ID the procedure 
should generate and return all the insurance plan names the provided company issues, 
the number of treatments the plan was claimed for, and the name of the disease the plan was claimed for the most. 
The plans which are claimed more are expected to appear above the plans that are claimed less. */

drop procedure if exists top_pharmacy;
delimiter //
create procedure company(in compID int)
begin
	select planName,diseaseName,count(claimID) as cnt
    from insurancecompany join insuranceplan
    using(companyID) join claim using (uin)
    left join treatment using(claimID)
    join disease using (diseaseID)
    where companyID=compID
    group by planName,diseaseName
    order by planName,cnt desc;
end //
delimiter ;

call company(4559);

--------------
/*2. It was reported by some unverified sources that some pharmacies are more popular for certain diseases. 
The healthcare department wants to check the validity of this report.
Create a stored procedure that takes a disease name as a parameter and would return the top 3 pharmacies the patients
 are preferring for the treatment of that disease in 2021 as well as for 2022.
Check if there are common pharmacies in the top 3 list for a disease, in the years 2021 and the year 2022.
Call the stored procedure by passing the values “Asthma” and “Psoriasis” as disease names and 
draw a conclusion from the result. */

delimiter //
create procedure top_pharmacy(in disease_Name varchar(20))
begin
	select pharmacyName,year(date) as datee,count(treatmentID) as cnt,
    rank() over (partition by year(date) order by count(treatmentID) desc) as rnk
    from pharmacy join prescription
    using(pharmacyID) join treatment using(treatmentID)
    join disease using (diseaseID)
    where diseaseName=disease_Name
    and year(date) in (2021,2022)
    group by pharmacyName,datee
    order by pharmacyName,datee,cnt desc;
end //
delimiter ;

call top_pharmacy("Asthma");

--------------------

/* 3. Jacob, as a business strategist, wants to figure out if a state is appropriate for setting up an insurance company
 or not.
Write a stored procedure that finds the num_patients, num_insurance_companies, and 
insurance_patient_ratio, the stored procedure should also find the avg_insurance_patient_ratio and if 
the insurance_patient_ratio of the given state is less than the avg_insurance_patient_ratio then 
it Recommendation section can have the value “Recommended” otherwise the value can be “Not Recommended”. */

DROP PROCEDURE IF EXISTS new_insurance_company_reccomendation_proc;
DELIMITER //

CREATE PROCEDURE new_insurance_company_reccomendation_proc(IN input_state VARCHAR(10))
BEGIN
	with patient_details as 
	(
		select DISTINCT state ,count(patientID) as patient_count_by_state
		from address a
		join person pr using(addressID)
		join patient pt 
		on pt.patientID = pr.personID
		group by state
	),
	company_details as 
	(
		select DISTINCT state ,count(companyName) as company_count_by_state
		from address a
		join insuranceCompany ic using(addressID)
		group by state
	),
	insurance_patient_ratio_table as (
	select distinct a.state,patient_count_by_state,company_count_by_state, 
	case when (patient_count_by_state IS NULL or company_count_by_state IS NULL) then 0
		 else (patient_count_by_state/company_count_by_state) 
		 end as insurance_patient_ratio
	 from address a
	left join patient_details pd 
	on a.state = pd.state
	left join company_details cd 
	on a.state = cd.state
	)
	select state,insurance_patient_ratio,
    case when insurance_patient_ratio<(select avg(insurance_patient_ratio) 
    from insurance_patient_ratio_table) then 'Recommended'
		   else 'Not Recommended'
		   end as Reccomendation
	from insurance_patient_ratio_table
	where state= input_state
	;	
END //
DELIMITER ;
CALL new_insurance_company_reccomendation_proc('VT');

------
/* 4. Currently, the data from every state is not in the database, The management has decided to add the data from other states and cities
 as well. It is felt by the management that it would be helpful if the date and time were to be stored whenever new city or state data 
 is inserted.
The management has sent a requirement to create a PlacesAdded table if it doesn’t already exist, 
that has four attributes. placeID, placeName, placeType, and timeAdded. */

CREATE TABLE IF NOT EXISTS PlacesAdded (
    placeID INT AUTO_INCREMENT PRIMARY KEY,
    placeName VARCHAR(255) NOT NULL,
    placeType ENUM('city', 'state') NOT NULL,
    timeAdded DATETIME NOT NULL
);
DELIMITER //
CREATE TRIGGER address_after_insert
AFTER INSERT ON Address
FOR EACH ROW
BEGIN
    DECLARE place_id INT;
    SELECT placeID INTO place_id
    FROM PlacesAdded
    WHERE placeName = NEW.city OR placeName = NEW.state
    LIMIT 1;
    IF place_id IS NULL THEN
        -- Insert the new city/state into PlacesAdded
        INSERT INTO PlacesAdded (placeName, placeType, timeAdded)
        VALUES (NEW.city, 'city', NOW());

        INSERT INTO PlacesAdded (placeName, placeType, timeAdded)
        VALUES (NEW.state, 'state', NOW());
    END IF;
END;
//
DELIMITER ;

# ---------

/*5.Some pharmacies suspect there is some discrepancy in their inventory management. 
The quantity in the ‘Keep’ is updated regularly and there is no record of it. They have requested to create a system that 
keeps track of all the transactions whenever the quantity of the inventory is updated.
You have been given the responsibility to create a system that automatically updates a Keep_Log table which has  
the following fields:
id: It is a unique field that starts with 1 and increments by 1 for each new entry. */

create table if not exists keep_log(
id int auto_increment primary key,
medicineID int not null,
quantity int not null);

delimiter //

create trigger keep_after_update
after update on keep
for each row
begin 
	declare updated_quantity int;
    set updated_quantity = new.quantity-old.quantity;
    insert into keep_log (medicineID,quantity)
    values(medicineID,updated_quantity);
end //
delimiter ;

#-----

/*with patient_details as 
	(
		select DISTINCT state ,count(patientID) as patient_count_by_state
		from address a
		join person pr using(addressID)
		join patient pt 
		on pt.patientID = pr.personID
		group by state
	),
	company_details as 
	(
		select DISTINCT state ,count(companyName) as company_count_by_state
		from address a
		join insuranceCompany ic using(addressID)
		group by state
	)
select distinct a.state,patient_count_by_state,company_count_by_state, 
	case when (patient_count_by_state IS NULL or company_count_by_state IS NULL) then 0
		 else (patient_count_by_state/company_count_by_state) 
		 end as insurance_patient_ratio
	 from address a
	left join patient_details pd 
	on a.state = pd.state
	left join company_details cd 
	on a.state = cd.state;
*/

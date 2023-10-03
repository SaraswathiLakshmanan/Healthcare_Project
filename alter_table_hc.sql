use health_care;
alter table pharmacy 
add constraint fk_pharmacy_addressID 
foreign key (addressID) references address(addressID) ;

alter table insurancecompany 
add constraint fk_insurancecompany_addressID 
foreign key (addressID) references address(addressID);

alter table person 
add constraint fk_person_addressID
foreign key (addressID) references address(addressID);

#adding composite primary key as there are duplicate entries in pk 
#delete the existing primary key 
alter table insuranceplan 
drop primary key;

alter table insuranceplan 
add constraint pk_insuranceplan_composite primary key (uin,planName,companyID);

alter table claim 
add constraint fk_claim_uin foreign key (uin) references insuranceplan (uin);

#replacing special characters with '' as the foreign key constraint doesn't satisfy
UPDATE claim
SET uin = REGEXP_REPLACE(uin, '[^a-zA-Z0-9]', '') 
WHERE uin LIKE '%�%';

alter table patient
add constraint fk_patient_patientID foreign key (patientID) references person(personID);

alter table treatment
add constraint fk_treatment_patientID foreign key (patientID) references patient(patientID);

alter table treatment
add constraint fk_treatment_diseaseID foreign key (diseaseID) references disease(diseaseID);

alter table treatment
add constraint fk_treatment_claimID foreign key (claimID) references claim(claimID);

alter table prescription
add constraint fk_prescription_pharmacyID foreign key (pharmacyID) references pharmacy(pharmacyID);

alter table prescription
add constraint fk_prescription_treatmentID foreign key(treatmentID) references treatment(treatmentID);


alter table contain
add constraint fk_contain_prescriptionID foreign key(prescriptionID) references prescription(prescriptionID);

alter table contain
add constraint fk_contain_medicineID foreign key(medicineID) references medicine(medicineID);

alter table keep
drop primary key;

alter table keep
add constraint pk_keep_composite primary key(pharmacyID,medicineID,quantity,discount);

alter table keep
add constraint fk_keep_pharmacyID foreign key(pharmacyID) references pharmacy(pharmacyID);

alter table keep 
add constraint fk_keep_medicineID foreign key(medicineID) references medicine(medicineID);
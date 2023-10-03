use health_care;


drop procedure if exists c;

#-------------1.
/*Insurance companies want to know if a disease is claimed higher or lower than average. 
Write a stored procedure that returns “claimed higher than average” or “claimed lower than average” when the diseaseID 
is passed to it. 
Hint: Find average number of insurance claims for all the diseases. 
If the number of claims for the passed disease is higher than the average return “claimed higher than average” 
otherwise “claimed lower than average”. */

delimiter //
create procedure claims(IN dD int)
begin
	declare resultant varchar(20);
	select case
    when 
	(select count(claimID) from treatment where diseaseID=dD)
    >=
    (select avg(cnt) from (select count(claimID) as cnt 
    from treatment group by diseaseID)t)
    then 
    "Above average"
    else
    "Below average"
    end as result into resultant;
   select resultant;
end //

delimiter ;

CALL claims(40);


#-----2.
/* Joseph from Healthcare department has requested for an application which helps him get genderwise report 
for any disease. 
Write a stored procedure when passed a disease_id returns 4 columns,
disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender 
underwent more often for the disease, if the number is same for both the genders, the value should be ‘same’.
*/

delimiter //
create procedure c(in idd int)
begin
	declare ID varchar(20);
	declare male_cnt int;
    declare female_cntt int;
    declare more varchar(20);
    select diseaseID,
    sum(if(gender='male',1,0)) as male,
    sum(if(gender='female',1,0)) as female
    into ID,male_cnt,female_cntt
    from treatment join person
    on treatment.patientID = person.personID
    where diseaseID=idd
    group by diseaseID;
    if male_cnt > female_cntt then 
    set more="male";
    elseif male_cnt < female_cntt then
    set more="female";
    elseif male_cnt = female_cntt then 
    set more="same";
    end if;
    select ID,male_cnt,female_cntt,more;
END //

delimiter ;

call c(1);

#-----------3.
/*The insurance companies want a report on the claims of different insurance plans. 
Write a query that finds the top 3 most and top 3 least claimed insurance plans.
The query is expected to return the insurance plan name, the insurance company name which has that plan,
and whether the plan is the most claimed or least claimed. 
*/

with plan as (select companyName,planName,count(claimID) as cnt,
row_number() over (order by count(claimID) desc) as rnk_desc,
row_number() over (order by count(claimID) ) as rnk
from insuranceCompany join insuranceplan
using(companyID) join claim using (uin)
left join treatment using (claimID)
group by companyName,planName)
select companyName,planName,cnt
from plan where rnk_desc in (1,2,3)
or rnk in (1,2,3);

#--------4.
/*The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.
*/
select patientID,dob,case 
	when dob >= date('2005-01-01') 
    then if(gender='male',"Youngmale","YoungFemale")
    when dob between date('1985-01-01') and date('2005-01-01') 
    then if(gender='male',"Adultmale","AdultFemale")
    when dob between date('1970-01-02') and date('1985-01-02') 
    then if(gender='male',"MidAgemale","MidAgeFemale")
    when dob < date('1970-01-01') 
    then if(gender='male',"ElderMale","ElderFemale")
end as category
from patient join person 
on patient.patientID=person.personID;

#---------5.

/*Anna wants a report on the pricing of the medicine. She wants a list of the most expensive
and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable,
listing the companyName, productName, description, maxPrice, and the price category of each. 
Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5.
Write a query to find */


with ct as (select companyName,productName,description,maxprice,
if(maxprice >1000, "pricey",if (maxprice<5,"affordable",null)) as category
from medicine)
select companyName,productName,description,maxprice,category
from ct
where category is not null
order by maxprice desc;






    



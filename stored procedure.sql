create database Stored_procedures;
use Stored_procedures;
Create table Donation(
    DonorID int primary key,
    Department varchar(50),
    Amount int
);
DELIMITER //
create procedure insertDonations()
begin
    insert into Donation values(1,'Education',1000);
    insert into Donation values(2,'Health',2000);
    insert into Donation values(3,'Environment',1500);
end //
DELIMITER ;

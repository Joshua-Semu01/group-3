show databases;
use appointment_system;
show tables;
select * from appointment;
select * from doctor;
select * from patient;
select * FROM appointment where doctor_id = 1;
SELECT
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.status,
    p.patient_id
FROM appointment a
INNER JOIN patient p
    ON a.patient_id = p.patient_id;
SELECT
    a.appointment_id,
    p.patient_id,
    per.first_name,
    per.last_name,
    a.appointment_date,
    a.appointment_time,
    a.status
FROM appointment a
INNER JOIN patient p
    ON a.patient_id = p.patient_id
INNER JOIN person per
    ON p.person_id = per.person_id;
SELECT
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.status,
    p.patient_id,
    d.doctor_id,
    d.speciality
FROM appointment a
INNER JOIN patient p
    ON a.patient_id = p.patient_id
INNER JOIN doctor d
    ON a.doctor_id = d.doctor_id;
SELECT
    appointment_id,
    appointment_date,
    status,
    CASE
        WHEN status = 'Confirmed' THEN 'Appointment confirmed'
        WHEN status = 'Pending' THEN 'Waiting for confirmation'
        WHEN status = 'Cancelled' THEN 'Appointment cancelled'
        ELSE 'Unknown status'
    END AS appointment_message
FROM appointment;
SELECT
    payment_id,
    patient_id,
    amount,
    CASE
        WHEN amount >= 70000 THEN 'High Payment'
        WHEN amount >= 50000 THEN 'Medium Payment'
        ELSE 'Low Payment'
    END AS payment_category
FROM payment;
SELECT
    payment_id,
    patient_id,
    amount,
    insurance_status,
    CASE
        WHEN insurance_status = 'insured' THEN 'Insurance Available'
        ELSE 'Self Payment'
    END AS payment_type
FROM payment;
SHOW TRIGGERS;
DELIMITER //

CREATE TRIGGER check_appointment_date
BEFORE INSERT ON appointment
FOR EACH ROW
BEGIN
    IF NEW.appointment_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment date cannot be in the past';
    END IF;
END//

DELIMITER ;
DELIMITER //

CREATE TRIGGER prevent_double_booking
BEFORE INSERT ON appointment
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM appointment
        WHERE doctor_id = NEW.doctor_id
          AND appointment_date = NEW.appointment_date
          AND appointment_time = NEW.appointment_time
          AND status <> 'Cancelled'
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor is already booked at this date and time';

    END IF;
END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE book_appointment(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_receptionist_id INT,
    IN p_date DATE,
    IN p_time TIME
)
BEGIN

    IF EXISTS (
        SELECT 1
        FROM appointment
        WHERE doctor_id = p_doctor_id
          AND appointment_date = p_date
          AND appointment_time = p_time
          AND status <> 'Cancelled'
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor is already booked at this time';

    ELSE

        INSERT INTO appointment
        (
            patient_id,
            doctor_id,
            receptionist_id,
            appointment_date,
            appointment_time,
            status
        )
        VALUES
        (
            p_patient_id,
            p_doctor_id,
            p_receptionist_id,
            p_date,
            p_time,
            'Pending'
        );

    END IF;

END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE cancel_appointment(
    IN p_appointment_id INT
)
BEGIN

    UPDATE appointment
    SET status = 'Cancelled'
    WHERE appointment_id = p_appointment_id;

END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE reschedule_appointment(
    IN p_appointment_id INT,
    IN p_new_date DATE,
    IN p_new_time TIME
)
BEGIN

    UPDATE appointment
    SET
        appointment_date = p_new_date,
        appointment_time = p_new_time,
        status = 'Pending'
    WHERE appointment_id = p_appointment_id;

END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE get_doctor_schedule(
    IN p_doctor_id INT,
    IN p_date DATE
)
BEGIN

    SELECT
        a.appointment_id,
        a.patient_id,
        a.appointment_date,
        a.appointment_time,
        a.status
    FROM appointment a
    WHERE a.doctor_id = p_doctor_id
      AND a.appointment_date = p_date
    ORDER BY a.appointment_time;

END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE get_patient_history(
    IN p_patient_id INT
)
BEGIN

    SELECT
        a.appointment_id,
        a.appointment_date,
        a.appointment_time,
        a.doctor_id,
        a.status
    FROM appointment a
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date DESC,
             a.appointment_time DESC;

END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE count_doctor_appointments(
    IN p_doctor_id INT,
    OUT p_total INT
)
BEGIN

    SELECT COUNT(*)
    INTO p_total
    FROM appointment
    WHERE doctor_id = p_doctor_id;

END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE mark_completed(
    IN p_appointment_id INT
)
BEGIN

    UPDATE appointment
    SET status = 'Completed'
    WHERE appointment_id = p_appointment_id;

END//

DELIMITER ;
SELECT
    a.appointment_id,
    a.doctor_id
FROM appointment a
LEFT JOIN doctor d
    ON a.doctor_id = d.doctor_id
WHERE d.doctor_id IS NULL;
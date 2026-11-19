CREATE DATABASE HospitalDB1;

USE HospitalDB1;

CREATE TABLE Hospital_Records (
    patient_name VARCHAR(100),
    address VARCHAR(150),
    doctor_name VARCHAR(100),
    department VARCHAR(100),
    visit_date DATE,
    diagnosis VARCHAR(100),
    prescription VARCHAR(150),
    bill_amount DECIMAL(10,2)
);

INSERT INTO Hospital_Records VALUES
('Arun', 'Chennai', 'Dr. Ravi', 'Cardiology', '2026-11-10', 'BP', 'Medicine A', 1500),
('Arun', 'Chennai', 'Dr. Ravi', 'Cardiology', '2026-11-15', 'BP', 'Medicine B', 2000),
('Priya', 'Madurai', 'Dr. Kumar', 'Neurology', '2026-11-12', 'Migraine', 'Medicine C', 1200),
('Priya', 'Madurai', 'Dr. Kumar', 'Neurology', '2026-11-18', 'Migraine', 'Medicine D', 1800),
('Rahul', 'Chennai', 'Dr. Meena', 'Orthopedics', '2026-11-13', 'Fracture', 'Medicine E', 5000);
select * from hospital_records;

update Hospital_Records
set address = 'Coimbatore'
where patient_name = 'Arun';

delete from  hospital_Records
where patient_name = 'Rahul';

create table Patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(100),
    address VARCHAR(150)
);

CREATE TABLE Department (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100)
);

create table Doctor (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_name VARCHAR(100),
    department_id INT, foreign key (department_id)
	references Department(department_id)
);

CREATE TABLE Visit (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    diagnosis VARCHAR(100),
    prescription VARCHAR(150),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
);

CREATE TABLE Billing (
    billing_id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT UNIQUE,
    bill_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'OPEN',
    FOREIGN KEY (visit_id) REFERENCES Visit(visit_id)
);

INSERT INTO Department (department_name)
VALUES
('Cardiology'),
('Neurology'),
('Orthopedics');

INSERT INTO Patient (patient_name, address)
VALUES
('Arun', 'Chennai'),
('Priya', 'Madurai'),
('Rahul', 'Chennai');

INSERT INTO Doctor (doctor_name, department_id)
VALUES
('Dr. Ravi', 1),
('Dr. Kumar', 2),
('Dr. Meena', 3);

INSERT INTO Visit
(patient_id, doctor_id, visit_date, diagnosis, prescription)
VALUES
(1, 1, '2026-11-10', 'BP', 'Medicine A'),
(1, 1, '2026-11-15', 'BP', 'Medicine B'),
(2, 2, '2026-11-12', 'Migraine', 'Medicine C'),
(2, 2, '2026-11-18', 'Migraine', 'Medicine D'),
(3, 3, '2026-11-13', 'Fracture', 'Medicine E');

INSERT INTO Billing (visit_id, bill_amount)
VALUES
(1, 1500),
(2, 2000),
(3, 1200),
(4, 1800),
(5, 5000);

SELECT
    p.patient_name,
    p.address,
    d.doctor_name,
    dep.department_name,
    v.visit_date,
    v.diagnosis,
    v.prescription,
    b.bill_amount,
    b.status
FROM Patient p
JOIN Visit v ON p.patient_id = v.patient_id
JOIN Doctor d ON v.doctor_id = d.doctor_id
JOIN Department dep ON d.department_id = dep.department_id
JOIN Billing b ON v.visit_id = b.visit_id;

USE HospitalDB1;
SHOW TABLES;
ALTER TABLE Visit
MODIFY visit_date DATE NOT NULL;

ALTER TABLE Billing
MODIFY bill_amount DECIMAL(10,2) NOT NULL,
ADD CONSTRAINT chk_bill_amount
CHECK (bill_amount >= 0);

INSERT INTO Billing (visit_id, bill_amount)
VALUES (100, -500);

ALTER TABLE Billing
MODIFY status VARCHAR(20) NOT NULL DEFAULT 'OPEN';

INSERT INTO Billing (visit_id, bill_amount)
VALUES (6, 2500);
DESC Visit;
DESC Billing;
SHOW CREATE TABLE Billing;

CREATE DATABASE HospitalDemoDB;
SHOW DATABASES;
USE HospitalDB1;

CREATE TABLE Test_Rename (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);
INSERT INTO Test_Rename
VALUES (1, 'Sample');
RENAME TABLE Test_Rename TO Renamed_Test;
SHOW TABLES;
SELECT * FROM Renamed_Test;
RENAME TABLE Renamed_Test TO Test_Rename;
USE HospitalDemoDB;
CREATE TABLE Demo_Patient (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50)
);

INSERT INTO Demo_Patient
VALUES (1, 'Arun');
SELECT * FROM Demo_Patient;
DROP DATABASE HospitalDemoDB;

USE HospitalDB1;
SELECT * FROM Patient;
SELECT * FROM Doctor;
SELECT * FROM Department;
SELECT * FROM Visit;
SELECT * FROM Billing;

UPDATE Patient
SET address = 'Coimbatore'
WHERE patient_id = 1;
SELECT * FROM Patient
WHERE patient_id = 1;

DELETE FROM Billing
WHERE visit_id = 5;
DELETE FROM visit
WHERE visit_id = 5;

SELECT
    p.patient_name,
    v.visit_date,
    v.diagnosis
FROM Patient p
JOIN Visit v
    ON p.patient_id = v.patient_id
WHERE v.visit_date >= '2026-11-01'
  AND v.visit_date < '2026-12-01';
  
  SELECT
    d.doctor_name,
    dep.department_name
FROM Doctor d
JOIN Department dep
    ON d.department_id = dep.department_id
ORDER BY dep.department_name;


-- This is a MySQL query for an imaginary clinic's database

create database if not exists `B-Sky Database` default character set utf8mb4 collate utf8mb4_0900_ai_ci;
use `B-Sky Database`;

create table `insurance` (
`insurance_id` int not null auto_increment,
`insurance_provider` varchar(50),
`coverage_details` varchar(100),
primary key (`insurance_id`)
);

create table `patient` (
`patient_id` int not null auto_increment,
`first_name` varchar(50) not null,
`other_name` varchar(100),
`last_name` varchar(50) not null,
`email` varchar(50),
`phone` varchar(50) not null,
`emergency_contact` varchar(50) not null,
`address` varchar(100) not null,
`allergies` text,
`insurance_info` int not null,
primary key (`patient_id`),
foreign key (`insurance_info`) references `insurance`(`insurance_id`)
);

create table `branch` (
`branch_id` int not null auto_increment,
`location` varchar(50) not null,
`contact_info` varchar(50) not null,
`email` varchar(50) not null,
`office_hrs` varchar(50) not null,
primary key (`branch_id`)
);

create table `department` (
`department_id` int not null auto_increment,
`department_name` varchar(100) not null,
`manager_id` int,
`branch_id` int not null,
`created_at` timestamp default current_timestamp,
`updated_at` timestamp default current_timestamp on update current_timestamp,
primary key (`department_id`),
foreign key (`branch_id`) references `branch`(`branch_id`)
);

create table `non_medical_staff` (
`staff_id` int not null auto_increment,
`first_name` varchar(50) not null,
`other_name` varchar(100),
`last_name` varchar(50) not null,
`role` varchar(50) not null,
`contact_info` varchar(50) not null,
`email` varchar(50),
`branch_id` int not null,
`department_id` int not null,
primary key (`staff_id`),
foreign key (`branch_id`) references `branch`(`branch_id`),
foreign key (`department_id`) references `department`(`department_id`)
);

create table `medical_staff` (
`staff_id` int not null auto_increment,
`first_name` varchar(50) not null,
`other_name` varchar(100),
`last_name` varchar(50) not null,
`role` enum ('nurse', 'doctor', 'lab_tecnician', 'therapist', 'pharmacist', 'medical_assistant', 'orthoptist'),
`specialty` varchar(50),
`contact_info` varchar(50) not null,
`availability` varchar(100),
`email` varchar(50),
`branch_id` int not null,
primary key (`staff_id`),
foreign key (`branch_id`) references `branch`(`branch_id`)
);

create table `feedback` (
`feedback_id` int not null auto_increment,
`patient_id` int not null,
`date` date not null,
`rating` enum ('0','1','2','3','4','5'),
`comment` text,
primary key (`feedback_id`),
foreign key (`patient_id`) references `patient`(`patient_id`)
 );
 
 create table `invoice` (
`invoice_id` int not null auto_increment,
`patient_id` int not null,
`invoice_date` date not null,
`due_date` date not null,
`total_amount` decimal(10,2) not null,
`status` enum('pending', 'paid', 'overdue'),
`description` text,
primary key (`invoice_id`),
foreign key (`patient_id`) references `patient`(`patient_id`)
);
 
 create table `payment` (
 `payment_id` int not null auto_increment,
 `patient_id` int not null,
 `amount` decimal(10,2),
 `payment_method` varchar(50),
 `date` date,
 `invoice_id` int,
 primary key (`payment_id`),
 foreign key (`patient_id`) references `patient`(`patient_id`),
 foreign key (`invoice_id`) references `invoice`(`invoice_id`)
);

CREATE TABLE `doctor` (
`doctor_id` int not null auto_increment,  
`staff_id` int unique,
`license_number` varchar(50) unique not null, 
`consultation_fee` decimal(10,2),
primary key (`doctor_id`),
foreign key (`staff_id`) references `medical_staff`(`staff_id`)
);

create table `service` (
`service_id` int not null auto_increment,
`service_name` varchar(50),
`description` text,
`cost` decimal(10,2),
`duration` varchar(50),
primary key (`service_id`)
);

create table `appointment` (
`appointment_id` int not null auto_increment,  
`patient_id` int not null,  
`doctor_id` int not null,
`service_id` int not null,
`appointment_date` datetime not null,  
`status` enum('scheduled', 'completed', 'cancelled', 'rescheduled') default 'scheduled',  
`reason` text,  
`created_at` timestamp default current_timestamp,  
`updated_at` timestamp default current_timestamp on update current_timestamp,
primary key (`appointment_id`),
foreign key (`patient_id`) references `patient`(`patient_id`),  
foreign key (`doctor_id`) references `doctor`(`doctor_id`),
foreign key (`service_id`) references `service`(`service_id`)
);

create table `medication` (
`medication_id` int not null auto_increment,
`name` varchar(100),
`type` varchar(50),
`description` text,
`price` decimal(10,2),
`stock_quantity` int,
`expiration_date` date,
`manufacturer` varchar(100),
primary key (`medication_id`)
);

create table `prescription` (
`prescription_id` int not null auto_increment,
`patient_id` int not null,  
`doctor_id` int not null,
`medication_id` int not null,
`dosage` varchar(50),
`date_issued` date,
primary key (`prescription_id`),
foreign key (`patient_id`) references `patient`(`patient_id`),
foreign key (`doctor_id`) references `doctor`(`doctor_id`),
foreign key (`medication_id`) references `medication`(`medication_id`)
);

create table `treatment_history` (
`treatment_id` int not null auto_increment,
`patient_id` int not null,  
`doctor_id` int not null,
`service_id` int not null,
`treatment_date` date,
`notes` text,
primary key (`treatment_id`),
foreign key (`patient_id`) references `patient`(`patient_id`),  
foreign key (`doctor_id`) references `doctor`(`doctor_id`),
foreign key (`service_id`) references `service`(`service_id`)
);

-- to solve the circular dependecy problem
alter table `department`
add foreign key (`manager_id`) references `non_medical_staff`(`staff_id`);


-- indexes for patient table
create index `idx_patient_email` on `patient`(`email`);
create index `idx_patient_phone` on `patient`(`phone`);
create index `idx_patient_insurance` on `patient`(`insurance_info`);

-- indexes for payment table
create index `idx_payment_patient` on `payment`(`patient_id`);
create index `idx_payment_invoice` on `payment`(`invoice_id`);
create index `idx_payment_date` on `payment`(`date`);

-- indexes for invoice table
create index `idx_invoice_patient` on `invoice`(`patient_id`);
create index `idx_invoice_date` on `invoice`(`invoice_date`);
create index `idx_invoice_status` on `invoice`(`status`);

-- indexes for doctor table
create index `idx_doctor_license` on `doctor`(`license_number`);
create index `idx_doctor_staff` on `doctor`(`staff_id`);

-- indexes for appointment table
create index `idx_appointment_patient` on `appointment`(`patient_id`);
create index `idx_appointment_doctor` on `appointment`(`doctor_id`);
create index `idx_appointment_date` on `appointment`(`appointment_date`);
create index `idx_appointment_status` on `appointment`(`status`);

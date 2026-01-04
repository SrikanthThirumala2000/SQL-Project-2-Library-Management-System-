-- Library Management System
CREATE DATABASE p2_library_management_system;


-- create table "branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(80),
            contact_no VARCHAR(15)
);

-- create table "employees"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
             emp_id VARCHAR(10) PRIMARY KEY,
             emp_name VARCHAR(30),
             position VARCHAR(30),
             salary DECIMAL(10,2),
             branch_id VARCHAR(10),
             FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- create table "members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
             member_id VARCHAR(10) PRIMARY KEY,
             member_name VARCHAR(30),
             member_address VARCHAR(80),
             reg_date DATE
);             
             
-- create table "books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
( 
		     isbn VARCHAR(50) PRIMARY KEY,
             book_title VARCHAR(80),
             category VARCHAR(30),
             rental_price DECIMAL(10,2),
             status VARCHAR(10),
             author VARCHAR(30),
             publisher VARCHAR(30)
);             
             
-- create table "issue status"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
             issued_id VARCHAR(10) PRIMARY KEY,
             issued_member_id VARCHAR(10),
             issued_book_name VARCHAR(80),
             issued_date DATE,
             issued_book_isbn VARCHAR(50),
             issued_emp_id VARCHAR(10),
             FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
             FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
             FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);    

-- create table "retrun status"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
             return_id VARCHAR(10) PRIMARY KEY,
             issued_id VARCHAR(30),
             return_book_name VARCHAR(80),
             return_date DATE,
             return_book_isbn VARCHAR(50),
             FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);             


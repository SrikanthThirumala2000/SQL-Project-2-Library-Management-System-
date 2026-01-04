-- CRUD OPERATIONS

-- 1. Create a New Book Record"('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books 
                (isbn, 
                 book_title, 
				 category, 
                 rental_price, 
                 status, 
                 author, 
                 publisher
                 )
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- 2. Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- 3. Update an Existing Member's Address with id 'C103' has changed to '125 Oak st'.

UPDATE members
SET member_address = '125 Oak st'
WHERE member_id = 'C103';
SELECT * FROM members
WHERE member_id = 'C103';

-- 4. Delete a Record from the Issued Status Table. Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- 5. List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_member_id AS book_members, 
	COUNT(*) as count
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;

-- CTAS (Create Table As Select) 
-- 6. Create Summary Tables: Used CTAS to generate new tables to join columns from 2 tables based on query results - each book and total book_issued_cnt

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status AS ist
JOIN books AS b
ON ist.issued_book_isbn = b.isbn 
GROUP BY b.isbn, b.book_title;

-- Data Analysis & Findings
-- Intermediate SQL operations

-- 1. Retrieve All Books in a Specific Category: lets say history
SELECT * FROM books
WHERE category = 'history';

-- 2. Find Total Rental Income by Category
SELECT 
     b.category,
     COUNT(*) AS count,
     SUM(b.rental_price)
FROM 
issued_status AS ist
JOIN 
books AS b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;

-- 3. List Members Who Registered in the Last 180 Days:
SELECT member_name, reg_date
FROM members
WHERE reg_date >= CURRENT_DATE() - INTERVAL 180 DAY; 
-- this query gives a blank output because 
SELECT MAX(reg_date) FROM members;
-- the latest date is 2024-06-01, which is more than the 180 days from current date
-- hence use the below query to find the data from the latest of 180 days from the table. 
SELECT member_name, reg_date
FROM members
WHERE reg_date >= (
				   SELECT 
                         MAX(reg_date) - INTERVAL 180 DAY
                         FROM members
				  )
;                         

-- 4. List Employees with Their Branch Manager's Name and their branch details:
SELECT 
	e1.emp_id,
    e1.emp_name,
    e1.position,
    b.*,
    e2.emp_name AS manager_name-- manager's name
FROM employees AS e1
JOIN 
branch AS b
ON e1.branch_id = b.branch_id
JOIN 
employees AS e2
ON e2.emp_id = b.manager_id;

-- 5. Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS rst
ON ist.issued_book_isbn = rst.return_book_isbn
WHERE rst.return_book_isbn IS NULL;


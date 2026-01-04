-- Advanced SQL Operations

/*
 1. Identify Members with Overdue Books
    Write a query to identify members who have overdue books 
    (assume a 30-day return period). 
	Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- the following needs to be done
-- join issued_status, members, books and return_status
-- filter out the table that has null return_status


SELECT 
      ist.issued_member_id,
      m.member_name,
      b.book_title,
      ist.issued_date,
      DATEDIFF(CURDATE(), ist.issued_date) AS days_pending
FROM issued_status AS ist
JOIN members AS m
    ON m.member_id = ist.issued_member_id
JOIN books AS b
    ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rst
    ON rst.issued_id = ist.issued_id
WHERE
    rst.return_date IS NULL
    AND DATEDIFF(CURDATE(), ist.issued_date) > 30
ORDER BY ist.issued_member_id;

/*
 2. Update Book Status on Return
	Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/


DELIMITER $$

DROP PROCEDURE IF EXISTS add_return_record $$

CREATE PROCEDURE add_return_records
(
  IN p_return_id VARCHAR(10),
  IN P_issued_id VARCHAR(10),
  IN p_book_quality VARCHAR(10)
) 

BEGIN
     DECLARE v_isbn VARCHAR(50);  -- like call by reference
     DECLARE v_book_name VARCHAR(80);  -- like call by reference
     
-- insert return record
     INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
     VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);
     
-- fetch book details
     SELECT issued_book_isbn, issued_book_name
     INTO v_isbn, v_book_name
     FROM issued_status
     WHERE issued_id = p_issued_id
     LIMIT 1;
     
-- update book status
     UPDATE books
     SET status = 'yes'
     WHERE isbn = v_isbn;
     
-- message output
     SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
     
END $$

DELIMITER ;  

-- Testing FUNCTION add_return_records

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

CALL add_return_records('RS138', 'IS135', 'Good');

SHOW PROCEDURE STATUS WHERE Name = 'add_return_records';



/*
3. Branch Performance Report
   Create a query that generates a performance report for each branch, 
   showing the number of books issued, 
   the number of books returned, and 
   the total revenue generated from book rentals.
*/

CREATE TABLE branch_reports
AS
SELECT 
      b.branch_id,
      b.manager_id,
      COUNT(ist.issued_id) AS num_of_books_issued,
      COUNT(rst.return_id) AS num_of_books_returned,
      SUM(bk.rental_price) AS total_revenue

FROM issued_status AS ist

JOIN
    employees AS e
ON
    e.emp_id = ist.issued_emp_id
    
JOIN 
    branch AS b
ON
    e.branch_id = b.branch_id
    
LEFT JOIN 
    return_status AS rst
ON
    rst.issued_id = ist.issued_id

JOIN 
    books AS bk
ON 
    ist.issued_book_isbn = bk.isbn

GROUP BY 1,2;

SELECT * FROM branch_reports;

/*
4. CTAS: Create a Table of Active Members
   Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
   who have issued at least one book in the last 2 months.
*/
CREATE TABLE active_members
AS
SELECT 
	  DISTINCT m.member_id,
      m.member_name,
      ist.issued_book_name,
      ist.issued_date
FROM members AS m
JOIN issued_status AS ist
ON m.member_id = ist.issued_member_id
WHERE ist.issued_date >= (SELECT MAX(issued_date) - INTERVAL 2 MONTH FROM issued_status);

SELECT * FROM active_members;


/*
5. Find Employees with the Most Book Issues Processed
   Write a query to find the top 3 employees who have processed the most book issues. 
   Display the employee name, number of books processed, and their branch.
*/

SELECT
      e.emp_id,
      e.emp_name,
      e.position,
      b.branch_id,
      b.branch_address,
      COUNT(ist.issued_id) AS num_of_books_processed
FROM issued_status AS ist

JOIN employees AS e
ON e.emp_id = ist.issued_emp_id

JOIN branch AS b
on e.branch_id = b.branch_id

GROUP BY 1
ORDER BY 6 DESC
LIMIT 3;


/*
6. Identify Members Issuing High-Risk Books
   Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
   Display the member name, book title, and the number of times they've issued damaged books.
*/  

SELECT 
    m.member_name,
    ist.issued_book_name AS book_title,
    COUNT(*) AS damaged_count
FROM issued_status AS ist
JOIN members AS m
    ON m.member_id = ist.issued_member_id
JOIN return_status AS rst
    ON rst.issued_id = ist.issued_id
WHERE rst.book_quality = 'Damaged'
GROUP BY 
    m.member_name,
    ist.issued_book_name
HAVING COUNT(*) > 2
ORDER BY damaged_count DESC;

/*
  7. Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
	 Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
	 The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
     The procedure should first check if the book is available (status = 'yes'). 
     If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
     If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS issue_book $$

CREATE PROCEDURE issue_book
(
 p_issued_id VARCHAR(10),
 p_issued_member_id VARCHAR(30), 
 p_issued_book_isbn VARCHAR(30),
 p_issued_emp_id VARCHAR(10)
)

BEGIN
   -- user invoked variable
   DECLARE v_status VARCHAR(10);
    
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status
							(
                             issued_id, 
                             issued_member_id, 
							 issued_date, 
                             issued_book_isbn, 
                             issued_emp_id
							)
        VALUES
              (
               p_issued_id, 
			   p_issued_member_id, 
               CURRENT_DATE, 
               p_issued_book_isbn, 
               p_issued_emp_id
               );

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
           -- message output
             SELECT CONCAT('Book records added successfully for book isbn :', p_issued_book_isbn) AS message;


    ELSE
	    SELECT CONCAT('Sorry to inform you the book you have requested is unavailable book_isbn: ', p_issued_book_isbn) AS message;
    END IF;

END $$

DELIMITER ;

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'     
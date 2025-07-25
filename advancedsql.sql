CREATE DATABASE BOOKS_LIBRARY;

USE BOOKS_LIBRARY;
GO
/* INT: Whole numbers (e.g., BookID).
VARCHAR(n): Variable-length strings (e.g., Title).
NVARCHAR(n): Unicode strings (e.g., LastName).
DATE: Dates (e.g., BorrowDate).
DATETIME: Date and time (e.g., ActionDate).
BIT: Binary flags (0, 1, or NULL).
GEOGRAPHY: Spatial data.
HIERARCHYID: Hierarchical data.
Note: BOOLEAN and NVARBINARY are not valid data types. 
Use BIT for boolean-like values, and VARBINARY for binary data. 
NTEXT is valid but deprecated. */

/* Keys and Constraints

Primary Key (PK): Uniquely identifies rows (e.g., BookID in Books). 
Creates a clustered index automatically.
Foreign Key (FK): References a PK in another table (e.g., BookID in Borrowing).
Unique Key: Ensures unique values (e.g., Email in Members).
CHECK Constraint: Enforces conditions (e.g., AvailableCopies >= 0).
NOT NULL Constraint: Ensures a column isn’t empty (e.g., FirstName).
Note: UNION is not a constraint; it’s a set operation (covered later). */

/* Section 1: DDL, DML, DCL, TCL, Data Types, Keys, and Constraints */
/* DDL: Data Definition Language (CREATE, ALTER, DROP) */
/* Create Tables with Data Types and Constraints */
/* Create the Books table to store book details */
drop table EMPLOYEES
DROP TABLE dbo.Borrowing_Log;
DROP TABLE Borrowing;
DROP TABLE Members;
DROP TABLE Books;

CREATE TABLE Books (
    BookID INT PRIMARY KEY,  -- BookID: Primary key, creates a clustered index, unique identifier for each book
    Title VARCHAR(100) NOT NULL,  -- Title: Variable-length string for book title, max 100 characters, cannot be NULL
    Author VARCHAR(50),  -- Author: Variable-length string for author name, max 50 characters, can be NULL
    AvailableCopies INT CHECK (AvailableCopies >= 0),  -- AvailableCopies: Integer for available copies, CHECK ensures non-negative
    TotalCopies INT CHECK (TotalCopies >= 0),  -- TotalCopies: Integer for total copies, CHECK ensures non-negative
    Location GEOGRAPHY,  -- Location: GEOGRAPHY data type for spatial data (e.g., library coordinates)
    IsActive BIT  -- IsActive: BIT data type for binary flag (0, 1, or NULL), no BOOLEAN in SQL Server
);

/* Create the Members table to store member details */
CREATE TABLE Members (
    MemberID INT PRIMARY KEY,  -- MemberID: Primary key, creates a clustered index, unique identifier for each member
    FirstName VARCHAR(50) NOT NULL,  -- FirstName: Variable-length string for first name, max 50 characters, cannot be NULL
    LastName NVARCHAR(50) NOT NULL,  -- LastName: Unicode variable-length string for last name, max 50 characters, cannot be NULL
    Email VARCHAR(100) UNIQUE,  -- Email: Variable-length string for email, max 100 characters, must be unique
    JoinDate DATE,  -- JoinDate: DATE data type for the member's join date (YYYY-MM-DD format)
    OrgPath HIERARCHYID  -- OrgPath: HIERARCHYID data type for hierarchical data (e.g., membership structure)
);

/* Create the Borrowing table to track borrowing transactions */
CREATE TABLE Borrowing (
    BorrowID INT PRIMARY KEY,  -- BorrowID: Primary key, creates a clustered index, unique identifier for each borrowing
    BookID INT,  -- BookID: Integer to reference a book, part of foreign key
    MemberID INT,  -- MemberID: Integer to reference a member, part of foreign key
    BorrowDate DATE,  -- BorrowDate: DATE data type for the borrowing date
    ReturnDate DATE,  -- ReturnDate: DATE data type for the return date, can be NULL
    FOREIGN KEY (BookID) REFERENCES Books(BookID),  -- Foreign key linking BookID to Books(BookID)
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),  -- Foreign key linking MemberID to Members(MemberID)
    CHECK (ReturnDate IS NULL OR ReturnDate >= BorrowDate)  -- CHECK constraint ensuring ReturnDate is after BorrowDate or NULL
);

/* Create the Borrowing_Log table to log actions (used by triggers) */
CREATE TABLE Borrowing_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,  -- LogID: Auto-incrementing primary key for each log entry
    BorrowID INT,  -- BorrowID: Integer to reference the borrowing record
    Action VARCHAR(50),  -- Action: Variable-length string for the action type (e.g., 'Return')
    ActionDate DATETIME,  -- ActionDate: DATETIME data type for the date and time of the action
    OldReturnDate DATE,  -- OldReturnDate: DATE data type for the previous ReturnDate (before update)
    NewReturnDate DATE  -- NewReturnDate: DATE data type for the updated ReturnDate (after update)
);
/* DML: Data Manipulation Language (INSERT, UPDATE, DELETE) */
/* Insert Sample Data with Transactions */
/* Insert data into Books table */
BEGIN TRANSACTION;  -- Start a transaction to ensure data consistency
INSERT INTO Books (BookID, Title, Author, AvailableCopies, TotalCopies)  -- Insert records into Books table
VALUES 
(1, 'The Great Gatsby', 'F. Scott Fitzgerald', 5, 5),  -- First book: ID 1, 5 copies available and total
(2, 'To Kill a Mockingbird', 'Harper Lee', 3, 3),  -- Second book: ID 2, 3 copies available and total
(3, '1984', 'George Orwell', 2, 2);  -- Third book: ID 3, 2 copies available and total
COMMIT;  -- Commit the transaction to save the changes

/* Insert data into Members table */
BEGIN TRANSACTION;  -- Start a transaction to ensure data consistency
INSERT INTO Members (MemberID, FirstName, LastName, Email, JoinDate)  -- Insert records into Members table
VALUES 
(101, 'Alice', 'Smith', 'alice@example.com', '2024-01-15'),  -- First member: ID 101, joined Jan 15, 2024
(102, 'Bob', 'Johnson', 'bob@example.com', '2024-02-20'),  -- Second member: ID 102, joined Feb 20, 2024
(103, 'Charlie', 'Brown', 'charlie@example.com', '2024-03-10');  -- Third member: ID 103, joined Mar 10, 2024
COMMIT;  -- Commit the transaction to save the changes

/* Insert data into Borrowing table */
BEGIN TRANSACTION;  -- Start a transaction to ensure data consistency
INSERT INTO Borrowing (BorrowID, BookID, MemberID, BorrowDate, ReturnDate)  -- Insert records into Borrowing table
VALUES 
(1001, 1, 101, '2025-05-01', NULL),  -- First borrowing: BorrowID 1001, BookID 1, MemberID 101, borrowed May 1, 2025
(1002, 2, 102, '2025-05-10', '2025-05-20'),  -- Second borrowing: BorrowID 1002, BookID 2, MemberID 102, borrowed May 10, returned May 20, 2025
(1003, 1, 103, '2025-05-15', NULL);  -- Third borrowing: BorrowID 1003, BookID 1, MemberID 103, borrowed May 15, 2025
COMMIT;  -- Commit the transaction to save the changes

/* Update a Book Title */
UPDATE Books  -- Update the Books table
SET Title = 'The Great Gatsby (Updated)'  -- Change the Title to 'The Great Gatsby (Updated)'
WHERE BookID = 1;  -- For the book with BookID 1

/* Delete a Member with Transaction */
BEGIN TRANSACTION;  -- Start a transaction to ensure data consistency
DELETE FROM Members  -- Delete a record from the Members table
WHERE MemberID = 103;  -- For MemberID 103
ROLLBACK;  -- Roll back the transaction to undo the delete

/* Insert Violations to Demonstrate Constraints */
/* Primary Key Violation */
INSERT INTO Books (BookID, Title, Author, AvailableCopies, TotalCopies)  -- Attempt to insert a new book
VALUES (1, 'Duplicate Book', 'Author', 1, 1);  -- BookID 1 already exists, violates Primary Key constraint

/* Foreign Key Violation */
INSERT INTO Borrowing (BorrowID, BookID, MemberID, BorrowDate, ReturnDate)  -- Attempt to insert a new borrowing record
VALUES (1004, 999, 101, '2025-05-25', NULL);  -- BookID 999 does not exist in Books, violates Foreign Key constraint

/* Check Constraint Violation */
INSERT INTO Books (BookID, Title, Author, AvailableCopies, TotalCopies)  -- Attempt to insert a new book
VALUES (4, 'Invalid Copies', 'Author', -1, 5);  -- AvailableCopies -1 violates CHECK constraint (must be >= 0)

/* NOT NULL Constraint Violation */
INSERT INTO Members (MemberID, FirstName, LastName, Email, JoinDate)  -- Attempt to insert a new member
VALUES (104, NULL, 'Doe', 'doe@example.com', '2024-04-01');  -- FirstName NULL violates NOT NULL constraint

/* DCL: Data Control Language (GRANT, REVOKE) */

/* Grant Permissions */
GRANT SELECT, UPDATE ON Borrowing TO PUBLIC;  -- Grant SELECT and UPDATE permissions on Borrowing table to all users (PUBLIC)

/* Revoke Permissions */
REVOKE SELECT, UPDATE ON Borrowing FROM PUBLIC;  -- Revoke the previously granted SELECT and UPDATE permissions from all users

/* Section 2: Stored Procedures, Views, Triggers, and User-Defined Functions */

/* Stored Procedure: BorrowBook */
/* Purpose: Allows a member to borrow a book if available, updates available copies */
CREATE PROCEDURE BorrowBook
    @BookID INT,        -- Parameter: BookID to identify the book to borrow
    @MemberID INT,      -- Parameter: MemberID to identify the borrowing member
    @BorrowDate DATE    -- Parameter: BorrowDate to record the borrowing date
AS
BEGIN
    DECLARE @Available INT;  -- Declare a variable to store the number of available copies
    SELECT @Available = AvailableCopies FROM Books WHERE BookID = @BookID;  -- Retrieve the available copies for the specified BookID
    IF @Available > 0  -- Check if there are available copies (greater than 0)
    BEGIN
        INSERT INTO Borrowing (BorrowID, BookID, MemberID, BorrowDate, ReturnDate)  -- Insert a new borrowing record
        VALUES (
            (SELECT ISNULL(MAX(BorrowID), 0) + 1 FROM Borrowing),  -- Generate a new BorrowID by finding the maximum existing BorrowID and adding 1
            @BookID,      -- Use the provided BookID
            @MemberID,    -- Use the provided MemberID
            @BorrowDate,  -- Use the provided BorrowDate
            NULL          -- Set ReturnDate to NULL since the book hasn't been returned
        );
        UPDATE Books  -- Update the Books table
        SET AvailableCopies = AvailableCopies - 1  -- Decrease the available copies by 1
        WHERE BookID = @BookID;  -- For the specified BookID
        PRINT 'Book borrowed successfully.';  -- Output a success message
    END
    ELSE  -- If no copies are available
    BEGIN
        PRINT 'Book not available.';  -- Output a message indicating the book isn't available
    END
END;

/* Execute the BorrowBook Procedure */
EXEC BorrowBook @BookID = 3, @MemberID = 102, @BorrowDate = '2025-05-25';  -- Borrow BookID 3 for MemberID 102 on May 25, 2025

/* Stored Procedure: ReturnBook */
/* Purpose: Marks a book as returned and increases available copies */
CREATE PROCEDURE ReturnBook
    @BorrowID INT,      -- Parameter: BorrowID to identify the borrowing record
    @ReturnDate DATE    -- Parameter: ReturnDate to record when the book is returned
AS
BEGIN
    DECLARE @BookID INT;  -- Declare a variable to store the BookID of the borrowed book
    SELECT @BookID = BookID FROM Borrowing WHERE BorrowID = @BorrowID;  -- Retrieve the BookID for the specified BorrowID
    UPDATE Borrowing  -- Update the Borrowing table
    SET ReturnDate = @ReturnDate  -- Set the ReturnDate to the provided date
    WHERE BorrowID = @BorrowID AND ReturnDate IS NULL;  -- Only update if the book hasn't been returned
    UPDATE Books  -- Update the Books table
    SET AvailableCopies = AvailableCopies + 1  -- Increase the available copies by 1
    WHERE BookID = @BookID;  -- For the retrieved BookID
    PRINT 'Book returned successfully.';  -- Output a success message
END;

/* Execute the ReturnBook Procedure */
EXEC ReturnBook @BorrowID = 1001, @ReturnDate = '2025-05-30';  -- Return BorrowID 1001 on May 30, 2025

/* Stored Procedure: DeleteMember */
/* Purpose: Deletes a member if they have no active borrowings */
CREATE PROCEDURE DeleteMember
    @MemberID INT  -- Parameter: MemberID to identify the member to delete
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Borrowing WHERE MemberID = @MemberID AND ReturnDate IS NULL)  -- Check for active borrowings
    BEGIN
        PRINT 'Cannot delete member with active borrowings.';  -- Output a message if deletion is not allowed
    END
    ELSE  -- If no active borrowings exist
    BEGIN
        DELETE FROM Members  -- Delete the member from the Members table
        WHERE MemberID = @MemberID;  -- For the specified MemberID
        PRINT 'Member deleted successfully.';  -- Output a success message
    END
END;

/* Execute the DeleteMember Procedure */
EXEC DeleteMember @MemberID = 102;  -- Delete MemberID 102

/* View: vw_BooksAvailable */
/* Purpose: Shows books with available copies, updatable since it references one table */
CREATE VIEW vw_BooksAvailable AS  -- Create a view named vw_BooksAvailable
SELECT BookID, Title, AvailableCopies  -- Select BookID, Title, and AvailableCopies columns
FROM Books  -- Source table: Books
WHERE AvailableCopies > 0;  -- Filter to show only books with available copies

/* Query the vw_BooksAvailable View */
SELECT * FROM vw_BooksAvailable;  -- Retrieve all columns from the vw_BooksAvailable view

/* Update the vw_BooksAvailable View */
UPDATE vw_BooksAvailable  -- Update the vw_BooksAvailable view
SET AvailableCopies = AvailableCopies - 1  -- Decrease AvailableCopies by 1
WHERE BookID = 2;  -- For BookID 2
-- Succeeds because the view references one table and meets updatability conditions

/* View: vw_BorrowingDates */
/* Purpose: Shows borrowing dates from Borrowing table */
CREATE VIEW vw_BorrowingDates AS  -- Create a view named vw_BorrowingDates
SELECT BorrowID, BorrowDate  -- Select BorrowID and BorrowDate columns
FROM Borrowing  -- Source table: Borrowing
WHERE BorrowDate IS NOT NULL;  -- Filter to ensure BorrowDate is not NULL

/* Query the vw_BorrowingDates View */
SELECT * FROM vw_BorrowingDates;  -- Retrieve all columns from the vw_BorrowingDates view

/* AFTER Trigger: trg_AfterReturn */
/* Purpose: Logs an action when a book is returned */
CREATE TRIGGER trg_AfterReturn  -- Create a trigger named trg_AfterReturn
ON Borrowing  -- On the Borrowing table
AFTER UPDATE  -- Trigger fires after an UPDATE operation
AS

BEGIN
    INSERT INTO Borrowing_Log (BorrowID, Action, ActionDate, OldReturnDate, NewReturnDate)  -- Insert a log entry into Borrowing_Log
    SELECT 
        i.BorrowID,  -- BorrowID from the inserted table (post-update data)
        'Return',    -- Action: Hardcoded value indicating a return action
        GETDATE(),   -- ActionDate: Current date and time of the action
        d.ReturnDate,  -- OldReturnDate: ReturnDate from the deleted table (pre-update data)
        i.ReturnDate   -- NewReturnDate: ReturnDate from the inserted table (post-update data)
    FROM inserted i, deleted d  -- Use inserted (post-update) and deleted (pre-update) tables
    WHERE i.BorrowID = d.BorrowID  -- Match records on BorrowID
    AND i.ReturnDate IS NOT NULL AND d.ReturnDate IS NULL;  -- Only log if the book was returned (ReturnDate updated from NULL)
END;

/* Execute ReturnBook to Trigger trg_AfterReturn */
EXEC ReturnBook @BorrowID = 1003, @ReturnDate = '2025-05-31';  -- Update BorrowID 1003 to trigger trg_AfterReturn

/* Query the Borrowing_Log Table */
SELECT * FROM Borrowing_Log;  -- Retrieve all records from Borrowing_Log to see the logged action

/* INSTEAD OF Trigger: trg_InsteadOfDeleteBorrowing */
/* Purpose: Prevents deletion of active borrowings */
CREATE TRIGGER trg_InsteadOfDeleteBorrowing  -- Create a trigger named trg_InsteadOfDeleteBorrowing
ON Borrowing  -- On the Borrowing table
INSTEAD OF DELETE  -- Trigger fires instead of a DELETE operation
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted WHERE ReturnDate IS NULL)  -- Check if any records being deleted are active
    BEGIN
        PRINT 'Cannot delete active borrowings. Please return the book first.';  -- Output a message if deletion is not allowed
    END
    ELSE  -- If all records are returned books
    BEGIN
        DELETE FROM Borrowing  -- Perform the actual deletion
        WHERE BorrowID IN (SELECT BorrowID FROM deleted);  -- Delete records matching the BorrowIDs in the deleted table
    END
END;

/* Test the trg_InsteadOfDeleteBorrowing Trigger */
DELETE FROM Borrowing WHERE BorrowID = 1001;  -- Attempt to delete BorrowID 1001 (active, should fail)
DELETE FROM Borrowing WHERE BorrowID = 1002;  -- Attempt to delete BorrowID 1002 (returned, should succeed)

/* Scalar Function: CalculateOverdueDays */
/* Purpose: Calculates overdue days for a borrowing */

/* UDFs are reusable routines:
Scalar Function: Returns a single value (e.g., CalculateOverdueDays).
Table-Valued Function: Returns a table (e.g., GetBorrowingsByMember).
Note: UDFs can return scalars, sets, or result sets. */


CREATE FUNCTION CalculateOverdueDays (@BorrowDate DATE, @ReturnDate DATE)  -- Create a scalar function with two DATE parameters
RETURNS INT  -- Function returns an integer (number of overdue days)
AS
BEGIN
    DECLARE @DueDate DATE = DATEADD(DAY, 14, @BorrowDate);  -- Calculate the due date by adding 14 days to BorrowDate
    IF @ReturnDate IS NULL  -- Check if the book hasn't been returned
        SET @ReturnDate = GETDATE();  -- Set ReturnDate to the current date for calculation
    RETURN DATEDIFF(DAY, @DueDate, @ReturnDate);  -- Return the difference in days between DueDate and ReturnDate
END;

/* Query Using the CalculateOverdueDays Function */
SELECT 
    BorrowID,  -- Select BorrowID from Borrowing
    BorrowDate,  -- Select BorrowDate from Borrowing
    ReturnDate,  -- Select ReturnDate from Borrowing
    dbo.CalculateOverdueDays(BorrowDate, ReturnDate) AS OverdueDays  -- Calculate overdue days for each borrowing
FROM Borrowing;  -- Source table: Borrowing

/* Table-Valued Function: GetBorrowingsByMember */
/* Purpose: Returns a table of borrowing details for a member */
CREATE FUNCTION GetBorrowingsByMember (@MemberID INT)  -- Create a table-valued function with MemberID parameter
RETURNS TABLE  -- Function returns a table result
AS
RETURN
(
    SELECT 
        BorrowID,  -- Select BorrowID from Borrowing
        BorrowDate,  -- Select BorrowDate from Borrowing
        ReturnDate,  -- Select ReturnDate from Borrowing
        dbo.CalculateOverdueDays(BorrowDate, ReturnDate) AS OverdueDays  -- Calculate overdue days
    FROM Borrowing  -- Source table: Borrowing
    WHERE MemberID = @MemberID  -- Filter for the specified MemberID
);

/* Query Using the GetBorrowingsByMember Function */
SELECT * FROM dbo.GetBorrowingsByMember(101);  -- Retrieve borrowing details for MemberID 101

/* Section 3: Set Operations (UNION, INTERSECT, EXCEPT) */
/* Set Operations
Set operations combine or compare query results:
UNION: Combines results, removes duplicates.
UNION ALL: Combines results, keeps duplicates.
INTERSECT: Returns common rows.
EXCEPT: Returns rows in the first query not in the second. 
We’ll use these to compare books, 
members, and borrowings without joins. */
/* UNION: Combine BookIDs and MemberIDs */
/* Purpose: Combines BookIDs and MemberIDs into a single list, removes duplicates */

SELECT CAST(BookID AS VARCHAR) AS ID  -- Select BookID from Books, cast to VARCHAR for compatibility
FROM Books  -- Source table: Books
UNION  -- Combine results, remove duplicates
SELECT CAST(MemberID AS VARCHAR)  -- Select MemberID from Members, cast to VARCHAR
FROM Members;  -- Source table: Members

/* UNION ALL: List Borrowing Dates */
/* Purpose: Combines borrowing dates before and after a date, keeps duplicates */
SELECT BorrowDate  -- Select BorrowDate from Borrowing
FROM Borrowing  -- Source table: Borrowing
WHERE BorrowDate >= '2025-05-10'  -- Filter for dates on or after May 10, 2025
UNION ALL  -- Combine results, keep duplicates
SELECT BorrowDate  -- Select BorrowDate from Borrowing
FROM Borrowing  -- Source table: Borrowing
WHERE BorrowDate < '2025-05-20';  -- Filter for dates before May 20, 2025

/* EXCEPT: Find Books Never Borrowed */
/* Purpose: Finds books that have not been borrowed */
SELECT BookID  -- Select BookID from Books
FROM Books  -- Source table: Books
EXCEPT  -- Return BookIDs not present in the second query
SELECT BookID  -- Select BookID from Borrowing
FROM Borrowing;  -- Source table: Borrowing

/* INTERSECT: Find Common Borrow Dates */
/* Purpose: Finds dates present in two overlapping date ranges */
SELECT BorrowDate  -- Select BorrowDate from Borrowing
FROM Borrowing  -- Source table: Borrowing
WHERE BorrowDate >= '2025-05-01'  -- Filter for dates on or after May 1, 2025
INTERSECT  -- Return dates common to both queries
SELECT BorrowDate  -- Select BorrowDate from Borrowing
FROM Borrowing  -- Source table: Borrowing
WHERE BorrowDate <= '2025-05-15';  -- Filter for dates on or before May 15, 2025

/* Section 4: Indexes and Performance Basics */
/* Indexes, Heap Tables, and SQL Server Profiler
Objective: Understand indexes, their types, and performance monitoring.

Classroom Strategy:

Step 1: Indexes
An index improves query performance by storing data in sorted order:
Clustered Index: Physically sorts the table (one per table, created by PK). 
Affects how data is stored on disk.
Non-Clustered Index: Separate structure with pointers (multiple allowed).
Heap Table: A table without a clustered index, slower for large datasets.
Performance: Clustered index seeks are fastest for SELECT queries, 
followed by index scans, then table scans. */
/* Heap Table: Borrowing_Heap */
/* Purpose: Demonstrates a table without a clustered index */
CREATE TABLE Borrowing_Heap (  -- Create a table named Borrowing_Heap
    BorrowID INT,  -- BorrowID: Integer for borrowing ID, no primary key
    BookID INT,  -- BookID: Integer for book ID
    MemberID INT,  -- MemberID: Integer for member ID
    BorrowDate DATE  -- BorrowDate: DATE for borrowing date
);

/* Insert Data into Borrowing_Heap */
INSERT INTO Borrowing_Heap (BorrowID, BookID, MemberID, BorrowDate)  -- Insert data into Borrowing_Heap
SELECT BorrowID, BookID, MemberID, BorrowDate  -- Select columns from Borrowing
FROM Borrowing;  -- Source table: Borrowing

/* Query Borrowing_Heap (Table Scan) */
SELECT * FROM Borrowing_Heap WHERE BorrowDate > '2025-05-10';  -- Query for records after May 10, 2025; performs a table scan (no index)

/* Add a Non-Clustered Index */
CREATE NONCLUSTERED INDEX IX_Borrowing_Heap_BorrowDate  -- Create a non-clustered index
ON Borrowing_Heap (BorrowDate);  -- On the BorrowDate column

/* Query Borrowing_Heap (Index Seek) */
SELECT * FROM Borrowing_Heap WHERE BorrowDate > '2025-05-10';  -- Query again; uses index seek due to the non-clustered index

/* Query Borrowing Table (Clustered Index Seek) */
SELECT * FROM Borrowing WHERE BorrowDate > '2025-05-10';  -- Query Borrowing; uses clustered index seek due to primary key

/* Drop the Heap Table */
DROP TABLE Borrowing_Heap;  -- Drop the Borrowing_Heap table

/* Section 5: Advanced SQL Constructs */

/* CASE Statement */
/* Purpose: Categorizes books by availability */
SELECT 
    BookID,  -- Select BookID from Books
    Title,  -- Select Title from Books
    CASE 
        WHEN AvailableCopies > 0 THEN 'Available'  -- If AvailableCopies > 0, label as 'Available'
        ELSE 'Not Available'  -- Otherwise, label as 'Not Available'
    END AS Status  -- Name the calculated column 'Status'
FROM Books;  -- Source table: Books

/* IIF Function */
/* Purpose: Same categorization using IIF */
SELECT 
    BookID,  -- Select BookID from Books
    Title,  -- Select Title from Books
    IIF(AvailableCopies > 0, 'Available', 'Not Available') AS Status  -- Use IIF to label as 'Available' or 'Not Available'
FROM Books;  -- Source table: Books

/* CTE: DuplicateBorrowings , Common Table Expressions (CTEs)
A CTE is a temporary result set. We’ll use a CTE to delete duplicate borrowings.
Step 3: ER Diagrams
An ER Diagram (Entity-Relationship Diagram) models entities (Books, Members, Borrowing) and 
their relationships (e.g., members borrow books). */
/* Purpose: Deletes duplicate borrowing records */
WITH DuplicateBorrowings AS (  -- Define a CTE named DuplicateBorrowings
    SELECT 
        BookID,  -- Select BookID from Borrowing
        MemberID,  -- Select MemberID from Borrowing
        BorrowDate,  -- Select BorrowDate from Borrowing
        ROW_NUMBER() OVER (PARTITION BY BookID, MemberID, BorrowDate ORDER BY BorrowID) AS RowNum  -- Assign a row number, partitioned by BookID, MemberID, BorrowDate
    FROM Borrowing  -- Source table: Borrowing
)
DELETE FROM DuplicateBorrowings WHERE RowNum > 1;  -- Delete duplicates (RowNum > 1) from the CTE

/* Star Schema Example */
/* Create DIM_Book Table (Dimension Table) */
CREATE TABLE DIM_Book (  -- Create a dimension table named DIM_Book
    BookID INT PRIMARY KEY,  -- BookID: Primary key for the book
    Title VARCHAR(100),  -- Title: Variable-length string for book title
    Author VARCHAR(50)  -- Author: Variable-length string for author name
);

/* Create DIM_Member Table (Dimension Table) */
CREATE TABLE DIM_Member (  -- Create a dimension table named DIM_Member
    MemberID INT PRIMARY KEY,  -- MemberID: Primary key for the member
    FullName VARCHAR(100)  -- FullName: Variable-length string for the member's full name
);

/* Create FACT_Borrowing Table (Fact Table) */
CREATE TABLE FACT_Borrowing (  -- Create a fact table named FACT_Borrowing
    BorrowID INT PRIMARY KEY,  -- BorrowID: Primary key for the borrowing record
    BookID INT,  -- BookID: Integer to reference a book
    MemberID INT,  -- MemberID: Integer to reference a member
    FOREIGN KEY (BookID) REFERENCES DIM_Book(BookID),  -- Foreign key linking BookID to DIM_Book
    FOREIGN KEY (MemberID) REFERENCES DIM_Member(MemberID)  -- Foreign key linking MemberID to DIM_Member
);

/* Snowflake Schema (Normalize DIM_Book) */
/* Create DIM_Author Table */
CREATE TABLE DIM_Author (  -- Create a table named DIM_Author to normalize Author data
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,  -- AuthorID: Auto-incrementing primary key
    AuthorName VARCHAR(50)  -- AuthorName: Variable-length string for the author’s name
);

/* Alter DIM_Book to Add AuthorID */
ALTER TABLE DIM_Book  -- Modify the DIM_Book table
ADD AuthorID INT,  -- Add a new column AuthorID
FOREIGN KEY (AuthorID) REFERENCES DIM_Author(AuthorID);  -- Add a foreign key linking AuthorID to DIM_Author

/* Final Cleanup: Drop All Tables */
DROP TABLE FACT_Borrowing;  -- Drop the FACT_Borrowing table
DROP TABLE DIM_Book;  -- Drop the DIM_Book table
DROP TABLE DIM_Member;  -- Drop the DIM_Member table
DROP TABLE DIM_Author;  -- Drop the DIM_Author table
DROP TABLE Borrowing_Log;  -- Drop the Borrowing_Log table
DROP TABLE Borrowing;  -- Drop the Borrowing table
DROP TABLE Members;  -- Drop the Members table
DROP TABLE Books;  -- Drop the Books table
DROP VIEW vw_BooksAvailable;  -- Drop the vw_BooksAvailable view
DROP VIEW vw_BorrowingDates;  -- Drop the vw_BorrowingDates view
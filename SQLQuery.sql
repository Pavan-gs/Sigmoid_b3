/* Create database */
CREATE DATABASE HR;
GO

/* Use HR database */
USE HR;
GO

CREATE TABLE JOBS (
    JOB_ID VARCHAR(10) PRIMARY KEY,
    JOB_TITLE VARCHAR(50),
    MIN_SALARY DECIMAL(10,2),
    MAX_SALARY DECIMAL(10,2)
);

CREATE TABLE LOCATIONS (
    LOCATION_ID INT PRIMARY KEY,
    CITY VARCHAR(50),
    STATE_PROVINCE VARCHAR(50),  -- Added for queries
    COUNTRY_ID CHAR(2)
);

CREATE TABLE DEPARTMENTS (
    DEPARTMENT_ID INT PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR(50),
    MANAGER_ID INT,
    LOCATION_ID INT
);

CREATE TABLE EMPLOYEES (
    EMPLOYEE_ID INT PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    JOB_ID VARCHAR(10),
    SALARY DECIMAL(10,2),
    COMMISSION_PCT DECIMAL(4,2),
    DEPARTMENT_ID INT,
    HIRE_DATE DATE,
    END_DATE DATE,  
    MANAGER_ID INT,
    FOREIGN KEY (JOB_ID) REFERENCES JOBS(JOB_ID),
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID)
);
GO

INSERT INTO JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) VALUES
('AD_PRES', 'President', 20000, 40000),
('AD_VP', 'Vice President', 15000, 30000),
('IT_PROG', 'Programmer', 4000, 10000),
('SA_REP', 'Sales Representative', 6000, 12000),
('ST_CLERK', 'Stock Clerk', 2000, 5000),
('MK_MAN', 'Marketing Manager', 9000, 15000),
('HR_REP', 'HR Representative', 4000, 9000),
('AC_MGR', 'Accounting Manager', 8000, 16000);

INSERT INTO LOCATIONS (LOCATION_ID, CITY, STATE_PROVINCE, COUNTRY_ID) VALUES
(1000, 'Seattle', 'Washington', 'US'),
(1100, 'Houston', 'Texas', 'TX'),
(1200, 'Los Angeles', 'California', 'CA'),
(1300, 'Newark', 'New Jersey', 'NJ'),
(1400, 'Chicago', 'Illinois', 'US'),
(1500, 'Miami', 'Florida', 'US'),
(1600, 'Austin', 'Texas', 'TX'),
(1700, 'San Francisco', 'California', 'CA');

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, LOCATION_ID) VALUES
(10, 'Administration', 101, 1000),
(20, 'Marketing', 201, 1300),
(30, 'Purchasing', 114, 1400),
(40, 'Human Resources', 203, 1100),
(50, 'Shipping', 121, 1100),
(60, 'IT', 103, 1000),
(70, 'Public Relations', 204, 1200),
(80, 'Sales', 145, 1200),
(90, 'Executive', 100, 1000),
(100, 'Accounting', 205, 1400);

INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, JOB_ID, SALARY, COMMISSION_PCT, DEPARTMENT_ID, HIRE_DATE, END_DATE, MANAGER_ID) VALUES
(100, 'Steven', 'King', 'AD_PRES', 24000, NULL, 90, '2003-06-17', NULL, NULL),
(101, 'Neena', 'Kochhar', 'AD_VP', 17000, NULL, 90, '2005-09-21', NULL, 100),
(102, 'Lex', 'De Haan', 'IT_PROG', 17000, NULL, 60, '2001-01-13', NULL, 100),
(103, 'Alexander', 'Hunold', 'IT_PROG', 9000, NULL, 60, '2006-01-03', NULL, 102),
(104, 'Bruce', 'Ernst', 'IT_PROG', 6000, NULL, 60, '2007-05-21', NULL, 103),
(105, 'David', 'Austin', 'IT_PROG', 4800, NULL, 60, '2005-06-25', '2010-12-31', 103),
(106, 'Valli', 'Pataballa', 'IT_PROG', 4800, NULL, 60, '2006-02-05', NULL, 103),
(107, 'Diana', 'Lorentz', 'IT_PROG', 4200, NULL, 60, '2007-02-07', NULL, 103),
(108, 'Nancy', 'Greenberg', 'AC_MGR', 12000, NULL, 100, '2002-08-17', NULL, 101),
(109, 'Daniel', 'Faviet', 'AC_MGR', 9000, NULL, 100, '2002-08-16', NULL, 108),
(110, 'John', 'Chen', 'ST_CLERK', 8200, NULL, 50, '2005-09-28', NULL, 108),
(111, 'Ismael', 'Sciarra', 'ST_CLERK', 7700, NULL, 50, '2005-09-30', NULL, 108),
(112, 'Jose Manuel', 'Urman', 'ST_CLERK', 7800, NULL, 50, '2006-03-07', '2012-06-30', 108),
(113, 'Luis', 'Popp', 'ST_CLERK', 6900, NULL, 50, '2007-12-07', NULL, 108),
(114, 'Den', 'Raphaely', 'MK_MAN', 11000, NULL, 20, '2002-12-07', NULL, 100),
(115, 'Alexander', 'Khoo', 'MK_MAN', 8800, NULL, 20, '2003-05-18', NULL, 114),
(116, 'Shelli', 'Baida', 'HR_REP', 7900, NULL, 40, '2005-12-24', NULL, 114),
(117, 'Sigal', 'Tobias', 'HR_REP', 7000, NULL, 40, '2005-07-24', NULL, 114),
(118, 'Guy', 'Himuro', 'HR_REP', 6500, NULL, 40, '2006-11-15', NULL, 114),
(119, 'Karen', 'Colmenares', 'HR_REP', 6000, NULL, 40, '2007-08-10', '2015-03-31', 114),
(120, 'Matthew', 'Weiss', 'ST_CLERK', 8000, NULL, 50, '2004-07-18', NULL, 100),
(121, 'Adam', 'Fripp', 'ST_CLERK', 8200, NULL, 50, '2005-04-10', NULL, 100),
(122, 'Payam', 'Kaufling', 'ST_CLERK', 7900, NULL, 50, '2003-05-01', NULL, 100),
(123, 'Shanta', 'Vollman', 'ST_CLERK', 6500, NULL, 50, '2005-10-10', NULL, 100),
(124, 'Kevin', 'Mourgos', 'ST_CLERK', 5800, NULL, 50, '2007-11-16', NULL, 100),
(125, 'Julia', 'Nayer', 'ST_CLERK', 3200, NULL, 50, '2005-07-16', NULL, 123),
(126, 'Irene', 'Mikkilineni', 'ST_CLERK', 2700, NULL, 50, '2006-09-28', NULL, 123),
(127, 'James', 'Landry', 'SA_REP', 6000, 0.20, 80, '2007-01-14', NULL, 123),
(128, 'Steven', 'Markle', 'SA_REP', 2200, 0.10, 80, '2008-03-08', NULL, 123),
(129, 'Laura', 'Bissot', 'SA_REP', 3300, 0.15, 80, '2005-08-20', NULL, 123),
(130, 'Mozhe', 'Atkinson', 'SA_REP', 2800, 0.25, 80, '2005-10-30', NULL, 123);
GO


CREATE TABLE Customerss (
   CustomerID int PRIMARY KEY,
   Name VARCHAR(100),
   DOB DATE,
   Balance int ,
   LastModified DATE
);

CREATE TABLE Accounts (
   AccountID int PRIMARY KEY,
   CustomerID int,
   AccountType VARCHAR(20),
   Balance int,

   LastModified DATE,
   FOREIGN KEY (CustomerID) REFERENCES Customerss(CustomerID)
);

CREATE TABLE Transactions (
   TransactionID int PRIMARY KEY,
   AccountID int,
   TransactionDate DATE,
   Amount int,
   TransactionType VARCHAR(10),
   FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE Loans (
   LoanID int PRIMARY KEY,
   CustomerID int,
   LoanAmount int,
   InterestRate int,
   StartDate DATE,
   EndDate DATE,
   FOREIGN KEY (CustomerID) REFERENCES Customerss(CustomerID)
);

CREATE TABLE Employe (
   EmployeeID int PRIMARY KEY,
   Name VARCHAR(100),
   Position VARCHAR(50),
   Salary int,
   Department VARCHAR(50),
   HireDate DATE
);  



INSERT INTO Customerss (CustomerID, Name, DOB, Balance, LastModified)
VALUES (13, 'John Doe', '1985-05-15',  1000, getdate());

INSERT INTO Customerss(CustomerID, Name, DOB, Balance, LastModified)
VALUES (23, 'Jane Smith', '1990-07-20',  1500, GETDATE());

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
VALUES (13, 1, 'Savings', 1000, getdate());

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)

VALUES (23, 2, 'Checking', 1500, getdate());

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (13, 1, getdate(), 200, 'Deposit');

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (23, 2, getdate(), 300, 'Withdrawal');

INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
VALUES (13, 1, 5000, 5,  getdate(), '2025-08-27');

INSERT INTO Employe (EmployeeID, Name, Position, Salary, Department, HireDate)
VALUES (13, 'Alice Johnson', 'Manager', 70000, 'HR', '2015-06-15');

INSERT INTO Employe (EmployeeID, Name, Position, Salary, Department, HireDate)
VALUES (23, 'Bob Brown', 'Developer', 60000, 'IT', '2017-03-20');

----apply discount to loan intrest rates-------------------------------------------------------------------------------
BEGIN TRANSACTION;
DECLARE @customerId INT;
DECLARE customer_cursor CURSOR FOR
SELECT CustomerId
FROM customerss
WHERE DATEDIFF(YEAR, DOB, GETDATE()) > 60;
OPEN customer_cursor;
FETCH NEXT FROM customer_cursor INTO @customerId;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE loans
    SET InterestRate = InterestRate + 0.01
    WHERE CustomerID = @customerId;
    FETCH NEXT FROM customer_cursor INTO @customerId;
END;
CLOSE customer_cursor;
DEALLOCATE customer_cursor;
COMMIT TRANSACTION;

---Promoting customers to vip status---------------------------------------------------------------------------------
alter table customerss add IsVIP BIT;
DECLARE @Customerid INT;
DECLARE customer_cursor CURSOR FOR
SELECT CustomerID
FROM Customerss
WHERE Balance > 10000;
OPEN customer_cursor;
FETCH NEXT FROM customer_cursor INTO @Customerid;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Customerss
    SET IsVIP=1
    WHERE CustomerID = @Customerid;
    FETCH NEXT FROM customer_cursor INTO @Customerid;
END;
CLOSE customer_cursor;
DEALLOCATE customer_cursor;

--------------Sending remainders to customers----------------------------------------------------------------------------
DECLARE @CustomerID INT;
DECLARE @DueDate DATE;
DECLARE @Message NVARCHAR(200);
DECLARE loan_cursor CURSOR FOR
SELECT c.CustomerID, l.EndDate
FROM Loans l
JOIN Customerss c ON l.CustomerID = c.CustomerID
WHERE l.EndDate BETWEEN GETDATE() AND DATEADD(DAY, 30, GETDATE());
OPEN loan_cursor;
FETCH NEXT FROM loan_cursor INTO @CustomerID, @DueDate;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Message = 'Reminder: Customer ID ' + CAST(@CustomerID AS NVARCHAR(10)) + 
                   ', your loan is due on ' + CONVERT(VARCHAR, @DueDate, 106);
    PRINT @Message;
    FETCH NEXT FROM loan_cursor INTO @CustomerID, @DueDate;
END;
CLOSE loan_cursor;
DEALLOCATE loan_cursor;


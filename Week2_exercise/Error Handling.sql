-------Handle Exceptions during fund transfers----------------------------------------------------------------------------
 CREATE PROCEDURE SafeTransferFunds
  @p_from_account_id INT,
  @p_to_account_id INT,
  @p_amount DECIMAL(18, 2)
AS
BEGIN
  DECLARE @v_balance DECIMAL(18, 2);
  BEGIN TRY
    BEGIN TRANSACTION;
    SELECT @v_balance = Balance 
    FROM Accounts 
    WHERE AccountID = @p_from_account_id 
    WITH (UPDLOCK,HOLDLOCK);
    IF @v_balance < @p_amount
    BEGIN
      THROW 50000, 'Error: Insufficient funds.', 1;
    END
    UPDATE Accounts
    SET Balance = Balance - @p_amount
    WHERE AccountID = @p_from_account_id;
    UPDATE Accounts
    SET Balance = Balance + @p_amount
    WHERE AccountID = @p_to_account_id;
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
    END
    DECLARE @ErrorMessage NVARCHAR(4000);
    SET @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
  END CATCH
END;

-------Manage Errors while updating salarie-------------------------------------------------------------------------

CREATE PROCEDURE UpdateSalary
    @EmployeeID INT,
    @PercentageIncrease FLOAT
AS
BEGIN
    DECLARE @OldSalary DECIMAL(10, 2);
    DECLARE @NewSalary DECIMAL(10, 2);
    DECLARE @ErrorMessage NVARCHAR(4000);
    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @OldSalary = Salary
        FROM Employe
        WHERE EmployeeID = @EmployeeID;
        
        -- If @OldSalary is NULL, the employee does not exist
        IF @OldSalary IS NULL
        BEGIN
            SET @ErrorMessage = 'Employee ID ' + CAST(@EmployeeID AS NVARCHAR) + ' does not exist.';
            THROW 50000, @ErrorMessage, 1;
        END
        SET @NewSalary = @OldSalary * (1 + @PercentageIncrease / 100.0);
        UPDATE Employe
        SET Salary = @NewSalary
        WHERE EmployeeID = @EmployeeID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        INSERT INTO ErrorLog(ErrorMessage, ErrorDate)
        VALUES (@ErrorMessage, GETDATE());
        THROW;
    END CATCH;
END;
----------------------------------------------------------------------------------
---Ensuring Data Integrity
CREATE TABLE ErrorLog (
    ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorMessage NVARCHAR(4000),
    ErrorDate DATETIME
);
CREATE PROCEDURE AddNewCustomer
    @CustomerID INT,
    @CustomerName NVARCHAR(100),
    @CustomerEmail NVARCHAR(100),
    @CustomerPhone NVARCHAR(20)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(4000);
    BEGIN TRY
        BEGIN TRANSACTION;
                IF EXISTS (SELECT 1 FROM Customerss WHERE CustomerID = @CustomerID)
        BEGIN
            SET @ErrorMessage = 'Customer ID ' + CAST(@CustomerID AS NVARCHAR) + ' already exists.';
            THROW 50000, @ErrorMessage, 1;
        END        
        INSERT INTO Customerss(CustomerID, Name, DOB,Balance)
        VALUES (@CustomerID, @CustomerName, @CustomerEmail, @CustomerPhone);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        INSERT INTO ErrorLog (ErrorMessage, ErrorDate)
        VALUES (@ErrorMessage, GETDATE());
        THROW;
    END CATCH;
END;
EXEC AddNewCustomer @CustomerID = 1, @CustomerName = 'John Doe', @CustomerEmail = 'john.doe@example.com', @CustomerPhone = '123-456-7890';

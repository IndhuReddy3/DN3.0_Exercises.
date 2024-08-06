---Process Mothly Intrest
CREATE PROCEDURE ProcessMonthlyInterest
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(4000);
    BEGIN TRY
        BEGIN TRANSACTION;      
        UPDATE Customerss
        SET Balance = Balance * 1.01;
        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction on error
        ROLLBACK TRANSACTION;
        -- Get the error message
        SET @ErrorMessage = ERROR_MESSAGE();
        -- Log the error
        INSERT INTO ErrorLog (ErrorMessage, ErrorDate)
        VALUES (@ErrorMessage, GETDATE());
        THROW;
    END CATCH;
END;
EXEC ProcessMonthlyInterest;

------------Customers Transfer funds between accounts----------------------------------------------------------------------------------
CREATE PROCEDURE TransferFunds
    @SourceAccountID INT,
    @TargetAccountID INT,
    @Amount DECIMAL(10, 2)
AS
BEGIN
    DECLARE @SourceBalance DECIMAL(10, 2);
    DECLARE @ErrorMessage NVARCHAR(4000);
    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @SourceBalance = Balance
        FROM Accounts
        WHERE AccountID = @SourceAccountID;
        IF @SourceBalance < @Amount
        BEGIN
            SET @ErrorMessage = 'Insufficient balance in source account.';
            THROW 50000, @ErrorMessage, 1;
        END
        UPDATE Accounts
        SET Balance = Balance - @Amount
        WHERE AccountID = @SourceAccountID;
        UPDATE Accounts
        SET Balance = Balance + @Amount
        WHERE AccountID = @TargetAccountID;
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
EXEC TransferFunds @SourceAccountID = 1, @TargetAccountID = 2, @Amount = 100.00;
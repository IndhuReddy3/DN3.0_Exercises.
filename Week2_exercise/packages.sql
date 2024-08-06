CREATE SCHEMA AccountOperations;
GO
CREATE PROCEDURE AccountOperations.OpenNewAccount
    @CustomerID INT,
    @InitialBalance DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO Accounts (CustomerID, Balance)
    VALUES (@CustomerID, @InitialBalance);
END;
GO
CREATE PROCEDURE AccountOperations.CloseAccount
    @AccountID INT
AS
BEGIN
    DELETE FROM Accounts
    WHERE AccountID = @AccountID;
END;
GO
CREATE FUNCTION AccountOperations.GetTotalBalance(@CustomerID INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TotalBalance DECIMAL(18, 2);

    SELECT @TotalBalance = SUM(Balance)
    FROM Accounts
    WHERE CustomerID = @CustomerID;

    RETURN @TotalBalance;
END;
GO
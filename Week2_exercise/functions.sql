CREATE FUNCTION dbo.CalculateAge (@DateOfBirth DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;

    -- Calculate the age
    SET @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE()) 
               - CASE 
                     WHEN (MONTH(@DateOfBirth) > MONTH(GETDATE())) 
                          OR (MONTH(@DateOfBirth) = MONTH(GETDATE()) AND DAY(@DateOfBirth) > DAY(GETDATE()))
                     THEN 1 
                     ELSE 0 
                 END;

    RETURN @Age;
END;

SELECT *
FROM sys.objects
WHERE type = 'FN' AND name = 'CalculateAge';

SELECT CustomerID, Name, dbo.CalculateAge(DOB) AS Age
FROM Customerss;
SELECT CustomerID, Name, dbo.CalculateAge(DOB) AS Age
FROM Customerss;

---------------To Check Sufficent Balance---------------------------

CREATE FUNCTION dbo.HasSufficientBalance (
    @AccountID INT,
    @Amount DECIMAL(10, 2)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Balance DECIMAL(10, 2);
    DECLARE @HasSufficientBalance BIT;
    SELECT @Balance = Balance
    FROM Accounts
    WHERE AccountID = @AccountID;
    IF @Balance >= @Amount
    BEGIN
        SET @HasSufficientBalance = 1; -- True
    END
    ELSE
    BEGIN
        SET @HasSufficientBalance = 0; -- False
    END
    RETURN @HasSufficientBalance;
END;
DECLARE @AccountID INT = 1;
DECLARE @Amount1 DECIMAL(10,2) = 100.00;
DECLARE @Result BIT;
SET @Result = dbo.HasSufficientBalance(@AccountID, @Amount1);
IF @Result = 1
    PRINT 'The account has sufficient balance.';
ELSE
    PRINT 'The account does not have sufficient balance.';
SELECT AccountID, dbo.HasSufficientBalance(AccountID, 100.00) AS HasBalance
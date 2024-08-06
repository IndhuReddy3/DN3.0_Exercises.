DECLARE @AccountID INT;
DECLARE @Balance DECIMAL(18, 2);
DECLARE @AnnualFee DECIMAL(18, 2) = 50.00; -- Set the annual fee amount here
DECLARE ApplyAnnualFee CURSOR FOR
SELECT AccountID, Balance
FROM Accounts;
OPEN ApplyAnnualFee;
FETCH NEXT FROM ApplyAnnualFee INTO @AccountID, @Balance;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Accounts
    SET Balance = Balance - @AnnualFee
    WHERE AccountID = @AccountID;
    FETCH NEXT FROM ApplyAnnualFee INTO @AccountID, @Balance;
END
CLOSE ApplyAnnualFee;
DEALLOCATE ApplyAnnualFee;
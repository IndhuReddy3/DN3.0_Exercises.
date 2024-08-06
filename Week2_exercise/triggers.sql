CREATE TRIGGER UpdateCustomerLastModified
ON Customerss
AFTER UPDATE
AS
BEGIN
    -- Update the LastModified column for the updated rows
    UPDATE Customerss
    SET LastModified = GETDATE()
    FROM Customerss
    INNER JOIN inserted ON Customerss.CustomerID = inserted.CustomerID;
END;
UPDATE Customerss
SET Name = 'New Name'
WHERE CustomerID = 1;
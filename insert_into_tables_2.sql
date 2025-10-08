USE GameStore;
GO

DECLARE @numOrders INT = 400; -- Set the number of orders you want to generate

-- Generate random data for the Orders table
DECLARE @i INT = 1;
WHILE @i <= @numOrders
BEGIN
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
    VALUES (
        (SELECT TOP 1 CustomerID FROM Customers ORDER BY NEWID()), -- Random CustomerID
        DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 730), DATEADD(YEAR, -2, GETDATE())), -- Random OrderDate within the last 2 years
        0 -- Placeholder for TotalAmount, will be updated by the trigger
    );
    SET @i = @i + 1;
END
GO

-- Generate random data for the OrderDetails table
DECLARE @orderCount INT = (SELECT COUNT(*) FROM Orders);
DECLARE @j INT = 1;
WHILE @j <= @orderCount
BEGIN
    DECLARE @OrderID INT = (SELECT OrderID FROM Orders WHERE OrderID = @j);
    DECLARE @CustomerID INT = (SELECT CustomerID FROM Orders WHERE OrderID = @OrderID);
    DECLARE @numDetails INT = ABS(CHECKSUM(NEWID()) % 5) + 1; -- Random number of details between 1 and 5

    DECLARE @k INT = 1;
    WHILE @k <= @numDetails
    BEGIN
        DECLARE @GameID INT = (SELECT TOP 1 GameID FROM Games WHERE ReleaseDate <= (SELECT OrderDate FROM Orders WHERE OrderID = @OrderID) AND GameID NOT IN (SELECT GameID FROM OrderDetails WHERE OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = @CustomerID)) ORDER BY NEWID());
        IF @GameID IS NOT NULL
        BEGIN
            DECLARE @Price DECIMAL(10, 2) = (SELECT Price FROM Games WHERE GameID = @GameID);

            INSERT INTO OrderDetails (OrderID, GameID, Price)
            VALUES (
                @OrderID, -- Random OrderID
                @GameID, -- Random GameID with ReleaseDate before OrderDate
                @Price -- Price of the selected GameID
            );
        END
        SET @k = @k + 1;
    END

    SET @j = @j + 1;
END
GO

-- Update the TotalAmount in the Orders table
UPDATE Orders
SET TotalAmount = (
    SELECT SUM(Price)
    FROM OrderDetails
    WHERE OrderDetails.OrderID = Orders.OrderID
);
GO

DECLARE @numWishlistEntries INT = 200; -- Set the number of wishlist entries you want to generate
-- Generate random data for the Wishlist table
DECLARE @i INT = 1;
WHILE @i <= @numWishlistEntries
BEGIN
    DECLARE @CustomerID INT = (SELECT TOP 1 CustomerID FROM Customers ORDER BY NEWID());
    DECLARE @GameID INT = (SELECT TOP 1 GameID FROM Games WHERE GameID NOT IN (SELECT GameID FROM OrderDetails WHERE OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = @CustomerID)) ORDER BY NEWID());
    DECLARE @DateAdded DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 730), DATEADD(YEAR, -2, GETDATE())); -- Random DateAdded within the last 2 years

    IF @GameID IS NOT NULL
    BEGIN
        INSERT INTO Wishlist (CustomerID, GameID, DateAdded)
        VALUES (
            @CustomerID, -- Random CustomerID
            @GameID, -- Random GameID not already owned by the customer
            @DateAdded -- Random DateAdded within the last 2 years
        );
    END
    SET @i = @i + 1;
END
GO

DECLARE @numReviews INT = 300; -- Set the number of reviews you want to generate
-- Generate random data for the Reviews table
DECLARE @i INT = 1;
WHILE @i <= @numReviews
BEGIN
    DECLARE @OrderDetailID INT = (SELECT TOP 1 OrderDetailID FROM OrderDetails ORDER BY NEWID());
    DECLARE @GameID INT = (SELECT GameID FROM OrderDetails WHERE OrderDetailID = @OrderDetailID);
    DECLARE @CustomerID INT = (SELECT CustomerID FROM Orders WHERE OrderID = (SELECT OrderID FROM OrderDetails WHERE OrderDetailID = @OrderDetailID));
    DECLARE @Rating INT = ABS(CHECKSUM(NEWID()) % 5) + 1; -- Random Rating between 1 and 5

    IF @GameID IS NOT NULL AND @CustomerID IS NOT NULL
    BEGIN
        -- Check if the customer has already reviewed this game
        IF NOT EXISTS (SELECT 1 FROM Reviews WHERE GameID = @GameID AND CustomerID = @CustomerID)
        BEGIN
            INSERT INTO Reviews (GameID, CustomerID, Rating)
            VALUES (
                @GameID, -- GameID from OrderDetails
                @CustomerID, -- CustomerID from Orders
                @Rating -- Random Rating between 1 and 5
            );
        END
    END
    SET @i = @i + 1;
END
GO
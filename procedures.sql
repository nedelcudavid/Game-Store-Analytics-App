IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetSalesByCategory')
BEGIN
    DROP PROCEDURE GetSalesByCategory;
END
GO

CREATE PROCEDURE GetSalesByCategory
AS
BEGIN
    SELECT 
        c.CategoryName AS [Category Name],
        COUNT(od.GameID) AS [Total Games Sold]
    FROM 
        OrderDetails od
    JOIN 
        Games g ON od.GameID = g.GameID
    JOIN 
        Categories c ON g.CategoryID = c.CategoryID
    GROUP BY 
        c.CategoryID, c.CategoryName
    ORDER BY 
        [Total Games Sold] DESC;
END
GO


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetGameSalesAndReviewAnalysis')
BEGIN
    DROP PROCEDURE GetGameSalesAndReviewAnalysis;
END
GO

CREATE PROCEDURE GetGameSalesAndReviewAnalysis
AS
BEGIN
    SELECT 
        g.GameID AS [Game ID],
        g.Title AS [Game Title],
        cat.CategoryName AS [Category Name],
        COUNT(od.OrderID) AS [Total Sales],
        SUM(od.Price) AS [Total Revenue],
        COALESCE(CAST(ROUND(AVG(CAST(r.Rating AS FLOAT)), 2) AS VARCHAR), '-') AS [Average Rating],
        COUNT(r.ReviewID) AS [Total Reviews]
    FROM 
        Games g
    LEFT JOIN 
        OrderDetails od ON g.GameID = od.GameID
    LEFT JOIN 
        Orders o ON od.OrderID = o.OrderID
    LEFT JOIN 
        Reviews r ON g.GameID = r.GameID
    LEFT JOIN 
        Categories cat ON g.CategoryID = cat.CategoryID
    WHERE 
        o.OrderDate IS NOT NULL
    GROUP BY 
        g.GameID, g.Title, cat.CategoryName
    HAVING 
        COUNT(od.OrderID) > 0 -- Only include games with at least one sale
    ORDER BY 
        [Total Revenue] DESC, [Average Rating] DESC;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetRevenueByCategoryLast6Months')
BEGIN
    DROP PROCEDURE GetRevenueByCategoryLast6Months;
END
GO

-- Get the sales in the last 6 months grouped by category, showing the total revenue per day for each category
CREATE PROCEDURE GetRevenueByCategoryLast6Months
AS
BEGIN
    SELECT 
        c.CategoryName AS [Category Name],
        CAST(o.OrderDate AS DATE) AS [Date],
        SUM(od.Price) AS [Total Revenue]
    FROM 
        OrderDetails od
    JOIN 
        Orders o ON od.OrderID = o.OrderID
    JOIN 
        Games g ON od.GameID = g.GameID
    JOIN 
        Categories c ON g.CategoryID = c.CategoryID
    WHERE 
        o.OrderDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY 
        c.CategoryName, CAST(o.OrderDate AS DATE)
    ORDER BY 
        c.CategoryName, [Date];
END
GO

-- Get number of wishlist additions for each game in order to determine its relation to the game's average rating, price or category
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetWishlistAdditionsAndGameDetails')
BEGIN
    DROP PROCEDURE GetWishlistAdditionsAndGameDetails;
END
GO

CREATE PROCEDURE GetWishlistAdditionsAndGameDetails
AS
BEGIN
    SELECT 
        g.GameID AS [Game ID],
        g.Title AS [Game Title],
        g.Price AS [Game Price],
        c.CategoryName AS [Category Name],
        COUNT(w.WishlistID) AS [Wishlist Additions],
        COALESCE(CAST(ROUND(AVG(CAST(r.Rating AS FLOAT)), 2) AS VARCHAR), '-') AS [Average Rating]
    FROM 
        Wishlist w
    JOIN 
        Games g ON w.GameID = g.GameID
    JOIN 
        Categories c ON g.CategoryID = c.CategoryID
    LEFT JOIN 
        Reviews r ON g.GameID = r.GameID
    GROUP BY 
        g.GameID, g.Title, g.Price, c.CategoryName
    ORDER BY 
        [Wishlist Additions] DESC, [Game Price] DESC;
END
GO

-- Get customer purchase and review patterns
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetCustomerPurchaseAndReviewPatterns')
BEGIN
    DROP PROCEDURE GetCustomerPurchaseAndReviewPatterns;
END
GO

CREATE PROCEDURE GetCustomerPurchaseAndReviewPatterns
AS
BEGIN
    SELECT 
        c.CustomerID AS [Customer ID],
        c.FirstName AS [First Name],
        c.LastName AS [Last Name],
        COUNT(o.OrderID) AS [Total Orders],
        SUM(o.TotalAmount) AS [Total Spending],
        ROUND(AVG(o.TotalAmount), 2) AS [Average Order Value],
        (SELECT COUNT(r.ReviewID) FROM Reviews r WHERE r.CustomerID = c.CustomerID) AS [Total Reviews],
        (SELECT COALESCE(CAST(ROUND(AVG(CAST(r.Rating AS FLOAT)), 2) AS VARCHAR), '-') FROM Reviews r WHERE r.CustomerID = c.CustomerID) AS [Average Rating Given]
    FROM 
        Customers c
    JOIN 
        Orders o ON c.CustomerID = o.CustomerID
    GROUP BY 
        c.CustomerID, c.FirstName, c.LastName
    ORDER BY 
        [Total Spending] DESC, [Total Orders] DESC;
END
GO
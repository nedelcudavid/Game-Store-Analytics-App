-- Create the GameStore database if it does not already exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'GameStore')
BEGIN
    CREATE DATABASE GameStore;
END
GO

USE GameStore;
GO

-- Drop the tables if they exist
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OrderDetails')
BEGIN
    DROP TABLE OrderDetails;
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Orders')
BEGIN
    DROP TABLE Orders;
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Reviews')
BEGIN
    DROP TABLE Reviews;
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Wishlist')
BEGIN
    DROP TABLE Wishlist;
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Games')
BEGIN
    DROP TABLE Games;
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Customers')
BEGIN
    DROP TABLE Customers;
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Categories')
BEGIN
    DROP TABLE Categories;
END
GO

-- Create the Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(255) NOT NULL
);

-- Create the Games table
CREATE TABLE Games (
    GameID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    CategoryID INT,
    Price DECIMAL(10, 2),
    ReleaseDate DATE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create the Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    UserName VARCHAR(255) NOT NULL UNIQUE,
    Email VARCHAR(255) NOT NULL UNIQUE,
    CHECK (UserName LIKE '%[A-Za-z0-9]%'),
    CHECK (FirstName LIKE '%[A-Za-z]%'),
    CHECK (LastName LIKE '%[A-Za-z]%')
);

-- Create the Reviews table
CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    GameID INT,
    CustomerID INT,
    Rating DECIMAL(10,2) CHECK (Rating >= 1 AND Rating <= 5),
    FOREIGN KEY (GameID) REFERENCES Games(GameID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create the Wishlist table
CREATE TABLE Wishlist (
    WishlistID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    GameID INT,
    DateAdded DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID)
);

-- Create the Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create the OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    GameID INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID),
    CONSTRAINT UC_CustomerGame UNIQUE (OrderID, GameID)
);
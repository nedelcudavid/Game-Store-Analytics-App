-- Create a trigger to remove a game from the wishlist when a customer purchases it
use GameStore;
GO

CREATE TRIGGER trg_RemoveFromWishlist
ON OrderDetails
AFTER INSERT
AS
BEGIN
    DELETE FROM Wishlist
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Orders o ON i.OrderID = o.OrderID
        WHERE Wishlist.CustomerID = o.CustomerID
          AND Wishlist.GameID = i.GameID
    );
END
GO
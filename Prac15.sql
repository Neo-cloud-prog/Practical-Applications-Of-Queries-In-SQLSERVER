-- #1
CREATE TABLE Products (
    ProductId INT PRIMARY KEY,
    Name VARCHAR(50),
    Stock INT
);

CREATE TABLE Orders (
    OrderId INT IDENTITY PRIMARY KEY,
    ProductId INT,
    Quantity INT,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE OrderLogs (
    LogId INT IDENTITY PRIMARY KEY,
    OrderId INT,
    Message VARCHAR(200),
    CreatedAt DATETIME DEFAULT GETDATE()
);

INSERT INTO Products VALUES (1, 'Laptop', 5);

CREATE PROC usp_CreateOrder
(
    @ProductId INT,
    @Quantity INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @Stock INT;

        SELECT @Stock = Stock
        FROM Products WITH (UPDLOCK, HOLDLOCK)
        WHERE ProductId = @ProductId;

        IF @Stock IS NULL
            THROW 50001, 'Product not found', 1;

        IF @Stock < @Quantity
            THROW 50002, 'Not enough stock', 1;

        UPDATE Products
        SET Stock = Stock - @Quantity
        WHERE ProductId = @ProductId;

        DECLARE @OrderId INT;

        INSERT INTO Orders(ProductId, Quantity)
        VALUES (@ProductId, @Quantity);

        SET @OrderId = SCOPE_IDENTITY();

        INSERT INTO OrderLogs(OrderId, Message)
        VALUES(@OrderId, 'Order created');

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END


EXEC usp_CreatOrder 1, 2
SELECT * FROM Products
SELECT * FROM Orders
SELECT * FROM OrderLogs

-- #2
CREATE TABLE Accounts(
    AccountId INT PRIMARY KEY,
    Balance DECIMAL(10,2)
);

CREATE TABLE Transfers(
    TransferId INT IDENTITY PRIMARY KEY,
    FromAcc INT,
    ToAcc INT,
    Amount DECIMAL(10,2),
    CreatedAt DATETIME DEFAULT GETDATE()
);

INSERT INTO Accounts VALUES (1, 10), (2, 5);

CREATE PROC usp_CreateTransfer
(
    @FromAcc INT,
    @ToAcc INT,
    @Amount DECIMAL(10,2)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Amount <= 0
        THROW 50000, 'Amount must be positive.', 1;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @BalanceFrom DECIMAL(10,2);
        DECLARE @BalanceTo DECIMAL(10,2);

        IF @FromAcc < @ToAcc
        BEGIN
            SELECT @BalanceFrom = Balance
            FROM Accounts WITH (UPDLOCK, HOLDLOCK)
            WHERE AccountId = @FromAcc;

            SELECT @BalanceTo = Balance
            FROM Accounts WITH (UPDLOCK, HOLDLOCK)
            WHERE AccountId = @ToAcc;
        END
        ELSE
        BEGIN
            SELECT @BalanceTo = Balance
            FROM Accounts WITH (UPDLOCK, HOLDLOCK)
            WHERE AccountId = @ToAcc;

            SELECT @BalanceFrom = Balance
            FROM Accounts WITH (UPDLOCK, HOLDLOCK)
            WHERE AccountId = @FromAcc;
        END

        IF @BalanceFrom IS NULL OR @BalanceTo IS NULL
            THROW 50001, 'One or both accounts do not exist.', 1;

        IF @BalanceFrom < @Amount
            THROW 50002, 'Insufficient funds.', 1;

        UPDATE Accounts
        SET Balance = Balance - @Amount
        WHERE AccountId = @FromAcc;

        UPDATE Accounts
        SET Balance = Balance + @Amount
        WHERE AccountId = @ToAcc;

        INSERT INTO Transfers(FromAcc, ToAcc, Amount)
        VALUES (@FromAcc, @ToAcc, @Amount);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END


EXEC usp_CreatTransfer  1, 2, 5
SELECT * FROM Accounts
SELECT * FROM Transfers

-- #3
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE() ON DELETE CASCADE
);

CREATE TABLE Posts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Posts_Users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE Comments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Comments_Posts FOREIGN KEY (post_id) REFERENCES Posts(id) ON DELETE CASCADE
);

ALTER TABLE Comments ADD CONSTRAINT FK_Comments_Users FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE;


INSERT INTO Users (username, email) VALUES
('nigga', 'nigga@example.com'),
('usa polic', 'usa@example.com'),
('charlie7', 'charlie7@example.com');

INSERT INTO Posts (user_id, title, content) VALUES
(1, 'nigga''s First Post', 'This is the first rob by nigga.'),
(2, 'usa polic''s Thoughts', 'I we should achieve deniggnazation.'),
(1, 'nigga Again', 'nigga will run from the jail.');

INSERT INTO Comments (post_id, user_id, comment) VALUES
(1, 2, 'Nice rob, nigga'),
(1, 3, 'Thank u for sharing'),
(2, 1, 'Interesting ideas, usa police'),
(3, 2, 'I hope, nigga');

CREATE PROC usp_DeleteUser
(
    @UserId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        SELECT 1
        FROM Users WITH (UPDLOCK, HOLDLOCK)
        WHERE Id = @UserId;

        IF @@ROWCOUNT = 0
            THROW 50010, 'User does not exist.', 1;

        SELECT 1
        FROM Posts WITH (UPDLOCK, HOLDLOCK)
        WHERE User_Id = @UserId;

        SELECT 1
        FROM Comments WITH (UPDLOCK, HOLDLOCK)
        WHERE User_Id = @UserId;

        DELETE FROM Comments
        WHERE User_Id = @UserId;

        DELETE FROM Posts
        WHERE User_Id = @UserId;

        DELETE FROM Users
        WHERE Id = @UserId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END

EXEC usp_DeleteUser 2
SELECT * FROM Users
SELECT * FROM Posts
SELECT * FROM Comments
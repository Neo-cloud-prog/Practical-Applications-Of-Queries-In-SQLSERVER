CREATE TABLE Peaple (
   PersonID INT IDENTITY(1,1) PRIMARY KEY,
   Name        NVARCHAR(100) NOT NULL,
   Phone       NVARCHAR(20),
   Email       NVARCHAR(100)
)

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    PersonID INT NOT NULL UNIQUE,
	CONSTRAINT FK_Customer_Person
        FOREIGN KEY (PersonID) REFERENCES Peaple(PersonID)
);

CREATE TABLE Shifts (
    ShiftID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

CREATE TABLE Users (
    UserID INT IDENTITY PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE Roles (
    RoleID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE UserRoles (
    UserID INT NOT NULL,
    RoleID INT NOT NULL,

    CONSTRAINT PK_UserRoles PRIMARY KEY (UserID, RoleID),

    CONSTRAINT FK_UserRoles_User
        FOREIGN KEY (UserID) REFERENCES Users(UserID),

    CONSTRAINT FK_UserRoles_Role
        FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
	ShiftID INT NOT NULL,
	UserID INT NULL UNIQUE,
	PersonID INT NOT NULL UNIQUE,
	Salary DECIMAL(10, 2) NOT NULL,
	CONSTRAINT FK_Employee_Person
        FOREIGN KEY (PersonID) REFERENCES Peaple(PersonID),
	CONSTRAINT FK_Employee_Shift
        FOREIGN KEY (ShiftID) REFERENCES Shifts(ShiftID),
	CONSTRAINT FK_Employee_User
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE TableStatuses (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

CREATE TABLE RestaurantTables (
    TableID     INT IDENTITY(1,1) PRIMARY KEY,
    TableNumber INT NOT NULL UNIQUE,
    Capacity    INT NOT NULL,
    StatusID    INT NOT NULL,
	CONSTRAINT FK_RestaurantTable_TableStatus
        FOREIGN KEY (StatusID) REFERENCES TableStatuses(StatusID)
);

CREATE TABLE Categories (
    CategoryID  INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(50) NOT NULL
);

CREATE TABLE MenuItems (
    MenuItemID  INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Price       DECIMAL(10,2) NOT NULL,
    CategoryID    INT NOT NULL,
	CONSTRAINT FK_MenuItem_Category
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
);

CREATE TABLE OrderStatuses (
    OrderStatusID  INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
    OrderID        INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID     INT NULL,
    TableID        INT NOT NULL,
    EmployeeID     INT NOT NULL,
    OrderDateTime  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    StatusID       INT NOT NULL,

    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Order_Table
        FOREIGN KEY (TableID) REFERENCES RestaurantTables(TableID),

    CONSTRAINT FK_Order_Employee
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_Order_Status
        FOREIGN KEY (StatusID) REFERENCES OrderStatuses(OrderStatusID)
);

CREATE TABLE OrderItem (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT NOT NULL,
    MenuItemID  INT NOT NULL,
    Quantity    INT NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItem_Order
        FOREIGN KEY (OrderID) REFERENCES [Orders](OrderID),

    CONSTRAINT FK_OrderItem_MenuItem
        FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID),

    CONSTRAINT UQ_Order_MenuItem
        UNIQUE (OrderID, MenuItemID)
);

CREATE TABLE PaymentMethods (
    PaymentMethodID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

CREATE TABLE Invoices (
    InvoiceID     INT IDENTITY(1,1) PRIMARY KEY,
    OrderID       INT NOT NULL UNIQUE,
    TotalAmount   DECIMAL(10,2) NOT NULL,
    PaymentMethodID INT NOT NULL,
    InvoiceDate   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	CONSTRAINT FK_Invoice_PaymentMethod
        FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID),

    CONSTRAINT FK_Invoice_Order
        FOREIGN KEY (OrderID) REFERENCES [Orders](OrderID)
);


-- PEOPLE
INSERT INTO Peaple (Name, Phone, Email) VALUES
(N'Marko Petrović',  N'+38160123456', N'marko.petrovic@mail.rs'),
(N'Jovan Nikolić',   N'+38160123457', N'jovan.nikolic@mail.rs'),
(N'Ivana Jović',     N'+38160123458', N'ivana.jovic@mail.rs'),
(N'Ana Marković',    N'+38160123459', N'ana.markovic@mail.rs'),
(N'Milan Stojanović',N'+38160123460', N'milan.stojanovic@mail.rs'),
(N'Nikola Ilić',     N'+38160123461', N'nikola.ilic@mail.rs'),
(N'Tamara Popović',  N'+38160123462', N'tamara.popovic@mail.rs');

-- CUSTOMERS
INSERT INTO Customers (PersonID) VALUES
(4), -- Ana Marković
(7); -- Tamara Popović

-- SHIFTS
INSERT INTO Shifts (Name) VALUES
(N'Morning'),
(N'Afternoon'),
(N'Night');

-- USERS
INSERT INTO Users (Username, PasswordHash) VALUES
(N'admin',   N'HASHED_ADMIN_PASSWORD'),
(N'waiter1', N'HASHED_WAITER_PASSWORD'),
(N'waiter2', N'HASHED_WAITER2_PASSWORD');

-- ROLES
INSERT INTO Roles (Name) VALUES
(N'Admin'),
(N'Waiter');

-- USER ROLES
INSERT INTO UserRoles (UserID, RoleID) VALUES
(1, 1), -- admin -> Admin
(2, 2), -- waiter1 -> Waiter
(3, 2); -- waiter2 -> Waiter

-- EMPLOYEES
INSERT INTO Employees (ShiftID, UserID, PersonID, Salary) VALUES
(1, 1, 1, 4000), -- Marko Petrović (Admin)
(2, 2, 2, 2000), -- Jovan Nikolić (Waiter)
(2, 3, 3, 5096); -- Ivana Jović (Waiter)

-- TABLE STATUSES
INSERT INTO TableStatuses (Name) VALUES
(N'Available'),
(N'Occupied'),
(N'Reserved');

-- RESTAURANT TABLES
INSERT INTO RestaurantTables (TableNumber, Capacity, StatusID) VALUES
(1, 2, 1),
(2, 4, 2),
(3, 4, 1),
(4, 6, 3),
(5, 2, 1);

-- CATEGORIES
INSERT INTO Categories (Name) VALUES
(N'Pizza'),
(N'Drinks'),
(N'Desserts');

-- MENU ITEMS
INSERT INTO MenuItems (Name, Description, Price, CategoryID) VALUES
(N'Margherita', N'Classic pizza with tomato and mozzarella', 6.50, 1),
(N'Pepperoni',  N'Pizza with pepperoni and cheese',          8.00, 1),
(N'Cola',       N'Cold soft drink',                           2.50, 2),
(N'Mineral Water', N'Sparkling water',                        2.00, 2),
(N'Cheesecake', N'Creamy cheesecake',                         4.00, 3);

-- ORDERS

-- PAYMENT METHODS
INSERT INTO PaymentMethods (Name) VALUES
(N'Cash'),
(N'Credit Card');

-- INVOICES

-- Drop the database if it exists to start fresh.  Useful for development.
DROP DATABASE IF EXISTS car_service_garage;

-- Create the database.
CREATE DATABASE car_service_garage;

-- Use the database.  All subsequent commands will apply to this database.
USE car_service_garage;

-- Create the Customers table.
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(255) UNIQUE NOT NULL,
    Address VARCHAR(255),
    --  Added a password field.  IMPORTANT:  Never store passwords in plain text!
    Password VARCHAR(255) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the Vehicles table.
CREATE TABLE Vehicles (
    VehicleID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Make VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    VIN VARCHAR(17) UNIQUE NOT NULL, -- Added VIN for uniqueness
    LicensePlate VARCHAR(20),
    Color VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create the Employees table.
CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    JobTitle VARCHAR(100),
    HireDate DATE,
    TerminationDate DATE, -- Added for tracking past employees
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the Services table.  This table lists the *types* of services offered.
CREATE TABLE Services (
    ServiceID INT AUTO_INCREMENT PRIMARY KEY,
    ServiceName VARCHAR(255) NOT NULL,
    Description TEXT,
    StandardPrice DECIMAL(10, 2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the ServiceRecords table.  This table tracks *actual* services performed on specific vehicles.
CREATE TABLE ServiceRecords (
    ServiceRecordID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleID INT,
    ServiceID INT,
    EmployeeID INT,
    ServiceDate DATETIME NOT NULL,
    Notes TEXT,
    Cost DECIMAL(10, 2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Create the Parts table.  This table lists the *types* of parts.
CREATE TABLE Parts (
    PartID INT AUTO_INCREMENT PRIMARY KEY,
    PartName VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the ServiceParts table.  This is a *junction* table to link ServiceRecords and Parts,
--  allowing us to track which parts were used in which service.
CREATE TABLE ServiceParts (
    ServicePartID INT AUTO_INCREMENT PRIMARY KEY,
    ServiceRecordID INT,
    PartID INT,
    Quantity INT NOT NULL,  -- How many of this part were used?
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ServiceRecordID) REFERENCES ServiceRecords(ServiceRecordID),
    FOREIGN KEY (PartID) REFERENCES Parts(PartID)
);

-- Create the  Statuses table.  This table lists the possible statuses of a service.
CREATE TABLE Statuses (
    StatusID INT AUTO_INCREMENT PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add a StatusID column to the ServiceRecords table to track the status of a service.
ALTER TABLE ServiceRecords
ADD COLUMN StatusID INT AFTER EmployeeID, -- Add the column *after* EmployeeID
ADD FOREIGN KEY (StatusID) REFERENCES Statuses(StatusID);

--  Populate the Statuses table with some default values.
INSERT INTO Statuses (StatusName) VALUES
('Pending'),  -- Initial state when a service is scheduled.
('In Progress'), -- When the service is being performed.
('Completed'),  -- When the service is finished.
('Cancelled'),  -- If the service was cancelled.
('On Hold');    -- If the service is temporarily on hold.

--  Set the default value for StatusID in ServiceRecords to 1 (Pending)
ALTER TABLE ServiceRecords
ALTER COLUMN StatusID SET DEFAULT 1;

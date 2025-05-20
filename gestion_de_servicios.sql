-- Drop the database if it exists to start fresh.  Useful for development.
DROP DATABASE IF EXISTS gestion_de_servicios;

-- Creacion de una base de datos.
-- Para la gestion de servicios.
-- Es decir, solucion de una problematica.
-- Mediante conocimientos especificos.
-- Brindados por un profesional o especialistas.
-- Pricipalmente de forma intangible.
-- Pudiendo involucrar bienes tangibles.
-- Productos asociados a la solucion.
CREATE DATABASE gestion_de_servicios;

-- Uso de la base de datos.  
-- Todos los suguientes comandos se aplicaran a esta base de datos.
USE gestion_de_servicios;

-- /// Creacion de Tablas Principales. \\\ --

-- Creacion de la tabla de Contactos. 
-- Esta tabla incluye a todas las personas.
-- Fisicas o juridicas sujetas a gestion por esta aplicacion.
CREATE TABLE Contactos (
    ContactoID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Apellido VARCHAR(255) NOT NULL,
    Telefono VARCHAR(20),
    Email VARCHAR(255) UNIQUE NOT NULL,
    Direccion VARCHAR(255),
    --  Added a password field.  IMPORTANT:  Never store passwords in plain text!
    Password VARCHAR(255) NOT NULL,
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creacion de la tabla de Servicios.
-- Lista todos los *tipos* de servicios.
-- Ofrecidos por entidad gestionada. 
CREATE TABLE Servicios (
    ServicioID INT AUTO_INCREMENT PRIMARY KEY,
    ServiceName VARCHAR(255) NOT NULL,
    Description TEXT,
    StandardPrice DECIMAL(10, 2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creacion de la tabla Sujeto de Servicio.
-- Esta tabla es particular / personalizada.
-- Para la tematica de la entidad gestionada.
-- Ya sea Veterinaria, Taller Mecanico, Centro Educativo, etc.
-- En este caso, Taller Mecanico.
-- Y el Sujeto de Servicio es un Vehiculo.
CREATE TABLE SujetosDeServicios (
    SujetoID INT AUTO_INCREMENT PRIMARY KEY,
    ContactoID INT,
    Make VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    VIN VARCHAR(17) UNIQUE NOT NULL, -- Added VIN for uniqueness
    LicensePlate VARCHAR(20),
    Color VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Creacion de la tabla de Registro de Servicios.
-- Esta tabla es una extension de los Servicios. 
-- Y registra cada instancia de la prestacion de Servicios.
-- cords table.  This table tracks *actual* services performed on specific vehicles.
CREATE TABLE ServiciosXtRegistros (
    ServicioXtRegistroID INT AUTO_INCREMENT PRIMARY KEY,
    SujetosIDs INT,
    ServicioID INT,
    EmpleadosIDs INT,
    FechaServicio DATETIME NOT NULL,
    Descripcion TEXT,
    Precio DECIMAL(10, 2) NOT NULL,
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    FOREIGN KEY (ServicioID) REFERENCES Servicios(ServicioID)
);

CREATE TABLE SujetosRegistrados (
    ServiciosXtRegistrosID INT,
    SujetoID INT,
    FOREIGN KEY (ServiciosXtRegistrosID) REFERENCES ServiciosXtRegistros(ServicioXtRegistroID),
    FOREIGN KEY (SujetoID) REFERENCES SujetosDeServicios(SujetoID),
    PRIMARY KEY (ServiciosXtRegistrosID, SujetoID),
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Notas TEXT,
);


-- Creacion de la tabla de Facturacion.
-- Esta aplicacion hara un registro simple.
-- Contabilizando el movimiento tanto de ingreso y egreso.
-- Servicio Facturado, contactos involucrados y monto.
CREATE TABLE Facturacion (
    FacturaID INT AUTO_INCREMENT PRIMARY KEY,
    PrestadorID INT,
    ContratanteID INT,
    SujetoID INT,
    ServicioID INT,
    TipoFactura ENUM('Factura A', 'Factura B', 'Factura C', 'Recibo X') NOT NULL,
    TipoMovimiento ENUM('Ingreso', 'Egreso') NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PrestadorID) REFERENCES Contactos(ContactoID),
    FOREIGN KEY (ContratanteID) REFERENCES Contactos(ContactoID),
    FOREIGN KEY (SujetoID) REFERENCES SujetosDeServicios(SujetoID),
    FOREIGN KEY (ServiceID) REFERENCES Servicios(ServiceID),
    -- Sumo una restriccion para asegurar por chequeo.
    -- Que el PrestadorID y el ContratanteID sean diferentes.
    CONSTRAINT CHK_PrestadorContratanteDiferentes CHECK (PrestadorID <> ContratanteID),
);


-- /// Creacion de Tablas de Extension. \\\ --

-- Create the Employees table.
CREATE TABLE ContactosXtEmpleados (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    JobTitle VARCHAR(100),
    HireDate DATE,
    TerminationDate DATE, -- Added for tracking past employees
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the Employees table.
CREATE TABLE ContactosXtClientes (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    JobTitle VARCHAR(100),
    HireDate DATE,
    TerminationDate DATE, -- Added for tracking past employees
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Create the Parts table.  This table lists the *types* of parts.
CREATE TABLE ProductosXtPartes (
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

-- Registro relacional entre Contacto y Servicio.


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

-- Eliminacion DROP de la BD database si existe.
-- Para tener un inicio fresco/ acero.
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

-- /// Creacion de Tablas Principales/PRIMARIAS. \\\ --

-- Creacion de la tabla de Contactos. 
-- Esta tabla incluye a todas las personas.
-- Fisicas o juridicas sujetas a gestion por esta aplicacion.
CREATE TABLE Contactos (
    ContactoID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Apellido VARCHAR(255) NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Direccion VARCHAR(255),
    EmergenciasID INT, -- Agregar un contacto de emergencias.
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (EmergenciasID) REFERENCES Contactos(ContactoID)
);

-- Creacion de la tabla de Servicios.
-- Lista todos los *tipos* de servicios.
-- Ofrecidos por entidad gestionada. 
CREATE TABLE Servicios (
    ServicioID INT AUTO_INCREMENT PRIMARY KEY,
    NombreServicio VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    PrecioEstandard DECIMAL(10, 2) NOT NULL,
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creacion de la tabla Sujeto de Servicio.
-- Esta tabla es general (extension hace particular / personalizada)
-- Para la tematica de la entidad gestionada usar Extension.
-- El Sujeto de Servicio es unico de un propietario (Contacto).
CREATE TABLE SujetosDeServicios (
    SujetoID INT AUTO_INCREMENT PRIMARY KEY,
    ContactoID INT NOT NULL,
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ContactoID) REFERENCES Contactos(ContactoID)
);

-- Creacion de la tabla de Productos 
-- Partes o bienes fisicos que complementan. 
-- La Prestacion de Servicios.
CREATE TABLE Productos (
    ProductoID INT AUTO_INCREMENT PRIMARY KEY,
    ParteNombre VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    Precio DECIMAL(10, 2) NOT NULL,
    StockCantidad INT,
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- /// Creacion de Tablas de PRODUCCION/TRABAJO. \\\ --

-- Creacion de la tabla de Prestacion de Servicios.
-- Esta tabla da inicio a la contratacion de un Servicio.
-- Fija Fecha de turno y cliente propietario.
CREATE TABLE PrestacionServicios (
    PrestacionServicioID INT AUTO_INCREMENT PRIMARY KEY,
    ContactoID INT NOT NULL, -- Propietario titular de los sujetos de servicio.
    FechaContratacion DATETIME NOT NULL,
    Estado ENUM(
        'Facturado', 
        'En Proceso', 
        'Contratado',
        'Turno reservado', 
        'Cancelado') NOT NULL,
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Notas TEXT,
    FOREIGN KEY (ContactoID) REFERENCES Contactos(ContactoID)
);

-- Creacion de la tabla de Registro de Servicios.
-- Esta tabla es una RELACIONAL de los Servicios. 
-- Y registra cada instancia del Servicios.
-- Es decir, esta tabla guarda cada servicio prestado.
-- Incluye el Sujeto de Servicio y a que Contratacion pertenece.
-- Incluye la fecha de inicio y fin del servicio. Duracion.
-- Incluye el precio del servicio y su estado.
-- Pero principalmente indica a Prestacion Servicio corresponde.	
CREATE TABLE ServiciosXtRegistros (
    ServicioXtRegistroID INT AUTO_INCREMENT PRIMARY KEY,
    SujetoID INT NOT NULL,
    ServicioID INT NOT NULL,
    PrestacionServicioID INT NOT NULL,
    FechaInicioServ DATETIME NOT NULL,
    FechaFinalServ DATETIME NOT NULL,
    DuracionHoras INT NOT NULL,
    Descripcion TEXT,
    Precio DECIMAL(10, 2) NOT NULL,
    Estado ENUM('Finalizado', 'En Proceso', 'Pendiente', 'Cancelado') NOT NULL,
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    FOREIGN KEY (SujetoID) REFERENCES SujetosDeServicios(SujetoID),
    FOREIGN KEY (ServicioID) REFERENCES Servicios(ServicioID),
    FOREIGN KEY (PrestacionServicioID) REFERENCES PrestacionServicios(PrestacionServicioID)
);

-- Creacion de la tabla de Facturacion.
-- Esta aplicacion hara un registro simple.
-- Contabilizando el movimiento tanto de ingreso y egreso.
-- Servicio Facturado, contactos involucrados y monto.
CREATE TABLE Facturacion (
    FacturaID INT AUTO_INCREMENT PRIMARY KEY,
    PrestadorID INT NOT NULL,
    ContratanteID INT NOT NULL,
    PrestacionServicioID INT NOT NULL,
    TipoFactura ENUM('Factura A', 'Factura B', 'Factura C', 'Recibo X') NOT NULL,
    TipoMovimiento ENUM('Ingreso', 'Egreso') NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PrestadorID) REFERENCES Contactos(ContactoID),
    FOREIGN KEY (ContratanteID) REFERENCES Contactos(ContactoID),
    FOREIGN KEY (PrestacionServicioID) REFERENCES PrestacionServicios(PrestacionServicioID),
    -- Sumo una restriccion para asegurar por chequeo.
    -- Que el PrestadorID y el ContratanteID sean diferentes.
    CONSTRAINT CHK_PrestadorContratanteDiferentes CHECK (PrestadorID <> ContratanteID)
    -- Agrego la restricción para asegurar que PrestadorID coincida con ContactoID 
    -- de la PrestacionServiciosID
    -- CONSTRAINT CHK_PrestadorContactoId CHECK (PrestadorID = (SELECT ContactoID FROM PrestacionServicios WHERE PrestacionServicioID = Facturacion.PrestacionServicioID))
    -- No me dejo usar esta restriccion porque no se puede hacer subconsulta en la restriccion.
    -- Tengo que usar un Trigger para validar esto.
);


-- /// Creacion de Tablas de EXTENSION. \\\ --

-- Creacion de la Tabla de EXTENSION de CONTACTOS/SERVICIOS.
CREATE TABLE ContactosXtEmpleados (
    EmpleadoID INT PRIMARY KEY,
    Trabajo VARCHAR(100),
    FechaContrato DATE,
    MontoContrato DECIMAL(10, 2) NOT NULL, -- Valor hora / base 8 hs diarias.
    FOREIGN KEY (EmpleadoID) REFERENCES Contactos(ContactoID)
);

-- Creacion de la Tabla de Extension de Clientes.
CREATE TABLE ContactosXtClientes (
    ClienteID INT PRIMARY KEY,
    CompaniaID INT,
    MontoAcumulado DECIMAL(10, 2) NOT NULL, -- Total acumulado de Servicios
    PrimerServicio DATE, -- Fecha del primer servicio contratado
    FOREIGN KEY (ClienteID) REFERENCES Contactos(ContactoID),
    FOREIGN KEY (CompaniaID) REFERENCES Contactos(ContactoID)
);

-- Creacion de la tabla de Extension de Usuarios.
-- Esta registra los Contactos usuarios internos o externos.
CREATE TABLE ContactosXtUsuarios (
    UsuarioID INT PRIMARY KEY,
    NombreUsuario VARCHAR(50) NOT NULL,
    Password VARCHAR(255) NOT NULL, -- Encriptado.
    Rol ENUM('Admin', 'Usuario', 'Portal') NOT NULL,
    FOREIGN KEY (UsuarioID) REFERENCES Contactos(ContactoID)
);

-- Creacion de la tabla de Extension de Servicios.
-- Lista todos los detalles de servicios.
-- Particulares del objeto de la entidad gestionada. 
CREATE TABLE ServiciosXtDetalles (
    ServicioID INT PRIMARY KEY,
    ServicioDetalle1 VARCHAR(255) NOT NULL,
    ServicioDetalle2 VARCHAR(255) NOT NULL,
    ServicioDetalle3 VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    FOREIGN KEY (ServicioID) REFERENCES Servicios(ServicioID)
);

-- Creacion de la tabla Extension Sujeto de Servicio.
-- Esta tabla es particular / personalizada.
-- Para la tematica de la entidad gestionada.
-- Ya sea Veterinaria, Taller Mecanico, Centro Educativo, etc.
-- En este caso, Taller Mecanico.
-- Y el Sujeto de Servicio es un Vehiculo.
CREATE TABLE SujetosXtDetalles (
    SujetoID INT PRIMARY KEY,
    Marca VARCHAR(50) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Anio INT NOT NULL,
    Chasis VARCHAR(17) UNIQUE NOT NULL, -- Reg.Unico.
    Patente VARCHAR(20) UNIQUE NOT NULL,
    Color VARCHAR(50),
    CreadoAl TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SujetoID) REFERENCES SujetosDeServicios(SujetoID)
);


-- Registro RELACIONAL entre Contacto/Servicio/Partes.

-- Creacion de la tabla de EmpleadosXtServicios.
-- Esta tabla registra que Empleados hicieron que Servicio.
CREATE TABLE EmpleadosXtServicios (
    EmpleadoID INT NOT NULL,
    ServicioXtRegistroID INT NOT NULL,
    FOREIGN KEY (EmpleadoID) REFERENCES Contactos(ContactoID),
    FOREIGN KEY (ServicioXtRegistroID) REFERENCES ServiciosXtRegistros(ServicioXtRegistroID),
    PRIMARY KEY (EmpleadoID, ServicioXtRegistroID)
);

-- Creacion de la tabla de Productos para Servicios.
-- Esta tabla es un registro de las Partes utilizadas.
-- En la Prestacion de cual Servicios y en que cantidad.
CREATE TABLE ProductosXtServicios (
    ProductoID INT NOT NULL,
    ServicioXtRegistroID INT NOT NULL,
    Cantidad INT NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
    FOREIGN KEY (ServicioXtRegistroID) REFERENCES ServiciosXtRegistros(ServicioXtRegistroID),
    PRIMARY KEY (ProductoID, ServicioXtRegistroID)
);
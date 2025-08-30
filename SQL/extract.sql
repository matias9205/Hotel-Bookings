--Crear base si no existe
DECLARE @DatabaseName NVARCHAR(128) = 'HotelBookings';

IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = @DatabaseName
)
BEGIN
    EXEC('CREATE DATABASE [' + @DatabaseName + ']');
    PRINT '✅ Base de datos creada: ' + @DatabaseName;
END
ELSE
BEGIN
    PRINT 'ℹ️ La base de datos ya existe: ' + @DatabaseName;
END
GO

USE [HotelBookings];
GO

--Se crea la tabla donde se almacenara el dataset subido sin transformar
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'BookingsRaw' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
    CREATE TABLE [BookingsRaw] (
        id INT NOT NULL PRIMARY KEY IDENTITY,
        hotel NVARCHAR(50),
        is_canceled NVARCHAR(50) NULL,
        lead_time NVARCHAR(50) NULL,
		arrival_date_year NVARCHAR(50) NULL,
		arrival_date_month NVARCHAR(20),
		arrival_date_week_number NVARCHAR(50) NULL,
		arrival_date_day_of_month NVARCHAR(50) NULL,
		stays_in_weekend_nights NVARCHAR(50) NULL,
		stays_in_week_nights NVARCHAR(50) NULL,
		adults NVARCHAR(50) NULL,
		children NVARCHAR(50) NULL,
		babies NVARCHAR(50) NULL,
		meal NVARCHAR(50) NULL,
		country NVARCHAR(MAX),
		market_segment NVARCHAR(50),
		distribution_channel NVARCHAR(50),
		is_repeated_guest NVARCHAR(50) NULL,
		previous_cancellations NVARCHAR(50) NULL,
		previous_bookings_not_canceled NVARCHAR(50) NULL,
		reserved_room_type NVARCHAR(50) NULL,
		assigned_room_type NVARCHAR(50) NULL,
		booking_changes NVARCHAR(50) NULL,
		deposit_type NVARCHAR(50),
		agent NVARCHAR(50) NULL,
		company NVARCHAR(50) NULL,
		days_in_waiting_list NVARCHAR(50) NULL,
		customer_type NVARCHAR(50),
		adr NVARCHAR(50) NULL,
		required_car_parking_spaces NVARCHAR(50) NULL,
		total_of_special_requests NVARCHAR(50) NULL,
		reservation_status NVARCHAR(50) NULL,
		reservation_status_date DATE,
    );
    PRINT '✅ Tabla creada: BookingsRaw';
END
ELSE
BEGIN
    PRINT 'ℹ️ La tabla BookingsRaw ya existe';
END
GO

------Se carga el archivo hotel_bookings.csv de la siguiente forma:
--1) haciendo click derecho sobre la base de datos en Sql Server
--2) Tasks
--2) Import Data
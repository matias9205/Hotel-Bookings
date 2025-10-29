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
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'BookingsRaw' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [dbo].[BookingsRaw];
    CREATE TABLE [BookingsRaw] (
        hotel NVARCHAR(MAX),
        is_canceled NVARCHAR(MAX),
        lead_time NVARCHAR(MAX),
		arrival_date_year NVARCHAR(MAX),
		arrival_date_month NVARCHAR(MAX),
		arrival_date_week_number NVARCHAR(MAX),
		arrival_date_day_of_month NVARCHAR(MAX),
		stays_in_weekend_nights NVARCHAR(MAX),
		stays_in_week_nights NVARCHAR(MAX),
		adults NVARCHAR(MAX),
		children NVARCHAR(MAX),
		babies NVARCHAR(MAX),
		meal NVARCHAR(MAX),
		country NVARCHAR(MAX),
		market_segment NVARCHAR(MAX),
		distribution_channel NVARCHAR(MAX),
		is_repeated_guest NVARCHAR(MAX),
		previous_cancellations NVARCHAR(MAX),
		previous_bookings_not_canceled NVARCHAR(MAX),
		reserved_room_type NVARCHAR(MAX),
		assigned_room_type NVARCHAR(MAX),
		booking_changes NVARCHAR(MAX),
		deposit_type NVARCHAR(MAX),
		agent NVARCHAR(MAX),
		company NVARCHAR(MAX),
		days_in_waiting_list NVARCHAR(MAX),
		customer_type NVARCHAR(MAX),
		adr NVARCHAR(MAX),
		required_car_parking_spaces NVARCHAR(MAX),
		total_of_special_requests NVARCHAR(MAX),
		reservation_status NVARCHAR(MAX),
		reservation_status_date NVARCHAR(MAX)
    );
    PRINT '✅ Tabla creada: BookingsRaw';
END
ELSE
BEGIN
    PRINT 'ℹ️ La tabla BookingsRaw ya existe';
END
GO


IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'BookingsRaw' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [dbo].[CountryCodes];
	CREATE TABLE [CountryCodes] (
		country_name NVARCHAR(MAX),
		country_code_ISO3 NVARCHAR(MAX),
		country_code NVARCHAR(MAX)
	);
	PRINT '✅ Tabla creada: CountryCodes';
END
ELSE
BEGIN
    PRINT 'ℹ️ La tabla CountryCodes ya existe';
END
GO
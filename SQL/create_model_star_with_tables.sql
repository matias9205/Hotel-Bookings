DROP TABLE IF EXISTS [Star].[FactBookings];
DROP TABLE IF EXISTS [Star].[DimHotel];
DROP TABLE IF EXISTS [Star].[DimCountry];
DROP TABLE IF EXISTS [Star].[DimMarket];
DROP TABLE IF EXISTS [Star].[DimCustomer];


--CREACION DE SCHEMA Star PARA ALMACENAR LAS TABLAS DEL MODELO ESTRELLA
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'Star'
)
BEGIN
    EXEC('CREATE SCHEMA Star');
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimHotel' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [Star].[DimHotel] (
		hotel_id INT NOT NULL PRIMARY KEY IDENTITY,
		hotel VARCHAR(50) UNIQUE NOT NULL,
	)
PRINT '✅ Tabla creada: DimHotel';
END ELSE BEGIN 
PRINT '✅ Tabla DimHotel ya existe en la base';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimCountry' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [Star].[DimCountry] (
		country_id INT NOT NULL PRIMARY KEY IDENTITY,
		country_code CHAR(5),
		unique_country_code_region NVARCHAR(10) UNIQUE NOT NULL,
		country_name NVARCHAR(MAX),
		region NVARCHAR(MAX)
	);
	-- Añadir clave única compuesta
    ALTER TABLE [Star].[DimCountry]
    ADD CONSTRAINT UQ_DimCountry_code_name UNIQUE (country_id, country_code);
PRINT '✅ Tabla creada: DimCountry';
END ELSE BEGIN 
	PRINT '✅ Tabla DimCountry ya existe en la base';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimMarket' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [Star].[DimMarket] (
		market_id INT NOT NULL PRIMARY KEY IDENTITY,
		market_segment NVARCHAR(100) UNIQUE NOT NULL
	)
PRINT '✅ Tabla creada: DimMarket';
END ELSE BEGIN
	PRINT '✅ Tabla DimMarket ya existe en la base';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimCustomer' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [Star].[DimCustomer] (
		customer_id INT NOT NULL PRIMARY KEY IDENTITY,
		customer_type NVARCHAR(100) UNIQUE NOT NULL
	);
PRINT '✅ Tabla creada: DimCustomer';
END ELSE BEGIN
	PRINT '✅ Tabla DimCustomer ya existe en la base';
END


IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'FactBookings' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [Star].[FactBookings] (
		booking_id INT NOT NULL PRIMARY KEY IDENTITY,
		--booking_key NVARCHAR(250) UNIQUE NOT NULL,
		is_canceled BIT,
		lead_time INT,
		arrival_date_year INT,
		arrival_date_month NVARCHAR(20),
		arrival_date_week_number INT,
		arrival_date_day_of_month INT,
		stays_in_weekend_nights INT,
		stays_in_week_nights INT,
		adults INT,
		children INT,
		babies INT,
		meal CHAR(8),
		distribution_channel NVARCHAR(50),
		is_repeated_guest BIT,
		previous_cancellations INT,
		previous_bookings_not_canceled INT,
		reserved_room_type NVARCHAR(5),
		assigned_room_type NVARCHAR(5),
		booking_changes INT,
		deposit_type NVARCHAR(50),
		agent INT,
		company INT,
		days_in_waiting_list INT,
		adr DECIMAL(10,2),
		required_car_parking_spaces INT,
		total_of_special_requests INT,
		reservation_status NVARCHAR(50),
		reservation_status_date DATE,
		total_nights INT,
		total_guests INT,
		lead_time_groups NVARCHAR(10),
		arrival_date DATE,
		hotel_id INT FOREIGN KEY REFERENCES [Star].[DimHotel](hotel_id),
		country_id INT FOREIGN KEY REFERENCES [Star].[DimCountry](country_id),
		market_id INT FOREIGN KEY REFERENCES [Star].[DimMarket](market_id),
		customer_id INT FOREIGN KEY REFERENCES [Star].[DimCustomer](customer_id),
	)
PRINT '✅ Tabla creada: FactBookings';
END ELSE BEGIN
	PRINT '✅ Tabla FactBookings ya existe en la base';
END
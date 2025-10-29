--CREACION DE SCHEMA PARA ALMACENAR TABLAS CON DATA SIN PROCESAR
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'Stage'
)
BEGIN
    EXEC('CREATE SCHEMA Stage');
END




--Se crea la tabla donde se almacenara el dataset transformado antes de ser modelado
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'BookingsClean' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [Stage].[BookingsClean];
	CREATE TABLE [Stage].[BookingsClean] (
		hotel NVARCHAR(50),
		is_canceled BIT,
		lead_time INT,
		arrival_date_year INT,
		arrival_date_month NVARCHAR(20),
		arrival_date_week_number INT,
		arrival_date_day_of_month INT,
		--is_weekend BIT, --se normaliza para validar si es fin de semana o es dia de semana
		stays_in_weekend_nights INT,
		stays_in_week_nights INT,
		adults INT,
		children INT,
		babies INT,
		meal NVARCHAR(10),
		country NVARCHAR(10),
		market_segment NVARCHAR(50),
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
		customer_type NVARCHAR(50),
		adr DECIMAL(10,2),
		required_car_parking_spaces INT,
		total_of_special_requests INT,
		reservation_status NVARCHAR(50),
		reservation_status_date DATE,
        country_normalized NVARCHAR(250),
		region NVARCHAR(250),
		total_nights INT,
		total_guests INT,
		lead_time_groups NVARCHAR(10),
		arrival_date DATE --se unen las columnas arrival_date_day_of_month, arrival_date_month y arrival_date_year
	);
;
PRINT '✅ Tabla creada: BookingsClean';
END ELSE BEGIN PRINT 'ℹ️ La tabla BookingsClean ya existe';
END



INSERT INTO [Stage].[BookingsClean]
(
	hotel, 
	is_canceled, 
	lead_time, 
	arrival_date_year, 
	arrival_date_month, 
	arrival_date_week_number,
	arrival_date_day_of_month,
	stays_in_weekend_nights,
	stays_in_week_nights,
	adults,
	children,
	babies,
	meal,
	country,
	market_segment,
	distribution_channel,
	is_repeated_guest,
	previous_cancellations,
	previous_bookings_not_canceled,
	reserved_room_type,
	assigned_room_type,
	booking_changes,
	deposit_type,
	agent,
	company,
	days_in_waiting_list,
	customer_type,
	adr,
	required_car_parking_spaces,
	total_of_special_requests,
	reservation_status,
	reservation_status_date,
	country_normalized,
	region,
	total_nights,
	total_guests,
	lead_time_groups,
	arrival_date
)
SELECT
	hotel,
	is_canceled,
	lead_time,
	arrival_date_year,
	arrival_date_month,
	arrival_date_week_number,
	arrival_date_day_of_month,
	stays_in_weekend_nights,
	stays_in_week_nights,
	adults,
	TRY_CAST(
		CASE 
			WHEN children = 'NA' THEN 0
			ELSE children 
		END AS INT
	) AS children,
	babies,
	CASE
		WHEN meal = 'Undefined' THEN 'Other'
		ELSE meal
	END AS meal,
	CASE
		WHEN country = 'NULL' THEN 'Other'
		ELSE country
	END AS country,
	market_segment,
	distribution_channel,
	is_repeated_guest,
	previous_cancellations,
	previous_bookings_not_canceled,
	reserved_room_type,
	assigned_room_type,
	booking_changes,
	deposit_type,
	COALESCE(
	  TRY_CAST(IIF(agent IN ('NULL', 'NA', ''), '0', agent) AS INT),
	  0
	) AS agent,
	COALESCE(
	  TRY_CAST(IIF(company IN ('NULL', 'NA', ''), '0', company) AS INT),
	  0
	) AS company,
	days_in_waiting_list,
	customer_type,
	TRY_CAST(REPLACE(adr, '.', ',') AS DECIMAL(8,2)) AS adr,
	required_car_parking_spaces,
	total_of_special_requests,
	reservation_status,
	reservation_status_date,
	CASE
		WHEN country_codes.country_name IS NULL THEN 'Other'
		ELSE country_codes.country_name
	END AS country_normalized,
	CASE 
		WHEN country_codes.country_name IN (
			'Portugal', 'España', 'Francia', 'Italia', 'Alemania', 'Bélgica', 'Países Bajos',
			'Suiza', 'Austria', 'Grecia', 'Irlanda', 'Reino Unido', 'Andorra', 'San Marino',
			'Luxemburgo', 'Mónaco'
		) THEN 'Europa Occidental'
		WHEN country_codes.country_name IN (
			'Suecia', 'Noruega', 'Finlandia', 'Islandia', 'Dinamarca'
		) THEN 'Europa del Norte'
		WHEN country_codes.country_name IN (
			'Polonia', 'Rumania', 'Hungría', 'República Checa', 'Eslovaquia', 'Bulgaria',
			'Croacia', 'Eslovenia', 'Estonia', 'Letonia', 'Lituania', 'Ucrania', 'Bielorrusia',
			'Serbia', 'Bosnia y Herzegovina', 'Albania', 'Macedonia', 'Montenegro'
		) THEN 'Europa del Este'
		WHEN country_codes.country_name IN (
			'Estados Unidos', 'Canadá', 'México'
		) THEN 'América del Norte'
		WHEN country_codes.country_name IN (
			'Argentina', 'Brasil', 'Chile', 'Uruguay', 'Paraguay', 'Bolivia', 'Perú',
			'Colombia', 'Venezuela', 'Ecuador', 'Guayana', 'Surinam'
		) THEN 'América del Sur'
		WHEN country_codes.country_name IN (
			'Cuba', 'República Dominicana', 'Puerto Rico', 'Jamaica', 'Barbados',
			'Santa Lucía', 'Bahamas', 'Trinidad y Tobago'
		) THEN 'Caribe'
		WHEN country_codes.country_name IN (
			'China', 'Japón', 'Corea del Sur', 'India', 'Tailandia', 'Indonesia', 'Vietnam',
			'Filipinas', 'Malasia', 'Bangladesh', 'Kazajistán', 'Uzbekistán', 'Nepal',
			'Sri Lanka', 'Taiwán'
		) THEN 'Asia'
		WHEN country_codes.country_name IN (
			'Australia', 'Nueva Zelandia', 'Fiji', 'Polinesia Francesa', 'Islas Feroe',
			'Nueva Caledonia'
		) THEN 'Oceanía'
		WHEN country_codes.country_name IN (
			'Sudáfrica', 'Nigeria', 'Egipto', 'Kenia', 'Marruecos', 'Argelia', 'Etiopía',
			'Ghana', 'Túnez', 'Mozambique', 'Zimbabue', 'Angola', 'Senegal', 'Uganda',
			'Botsuana', 'Malaui', 'Namibia', 'Ruanda', 'Tanzania'
		) THEN 'África'
		WHEN country_codes.country_name IN (
			'Arabia Saudita', 'Israel', 'Irán', 'Irak', 'Emiratos Árabes', 'Qatar',
			'Jordania', 'Líbano', 'Siria', 'Turquía', 'Kuwait'
		) THEN 'Medio Oriente'
		ELSE 'Unknown'
	END AS region,
	TRY_CAST(stays_in_week_nights AS INT) + TRY_CAST(stays_in_weekend_nights AS INT) AS total_nights,
	TRY_CAST(adults AS INT) + TRY_CAST(children AS INT) + TRY_CAST(babies AS INT) AS total_guests,
	CASE
		WHEN lead_time <= 7 THEN 'Corto'
		WHEN lead_time > 7 AND lead_time < 30 THEN 'Medio'
		WHEN lead_time >= 30 THEN 'Largo'
		ELSE 'Other'
	END AS lead_time_groups,
	TRY_CAST(CONCAT(arrival_date_year, '/', arrival_date_month, '/', arrival_date_day_of_month) AS DATE) AS arrival_date
FROM
	[dbo].[BookingsRaw] AS bookings
LEFT JOIN
	[dbo].[CountryCodes] country_codes ON bookings.country = country_codes.country_code_ISO3
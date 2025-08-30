USE [HotelBookings];

----------------------------------------------------------------------------------------------------------

--Se crea la tabla donde se almacenara el dataset transformado antes de ser modelado
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'BookingsClean' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [BookingsClean] (
		id INT NOT NULL PRIMARY KEY IDENTITY,
		hotel NVARCHAR(50),
		is_canceled NVARCHAR(10),
		lead_time INT,
		arrival_date DATE, --se unen las columnas arrival_date_day_of_month, arrival_date_month y arrival_date_year
		arrival_day_of_week NVARCHAR(10), --se normaliza para contener el dia de la semana
		season NVARCHAR(10), --se normaliza para contener el nombre de la estacion
		is_weekend BIT, --se normaliza para validar si es fin de semana o es dia de semana
		stays_in_weekend_nights INT,
		stays_in_week_nights INT,
		adults INT,
		children INT,
		babies INT,
		meal NVARCHAR(50),
		country NVARCHAR(10),
        country_normalized NVARCHAR(100),
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
	);
;
PRINT '✅ Tabla creada: BookingsClean';

END ELSE BEGIN PRINT 'ℹ️ La tabla BookingsClean ya existe';

END

----------------------------------------------------------------------------------------------------------

--Se realiza la insercion de los datos de la tabla base BookingsRaw en cada campo de la tabla transformada BookingsClean
WITH
    FechaTransformada AS (
        SELECT
            hotel,
            is_canceled,
            lead_time,
            CONCAT(
                CAST(
                    arrival_date_year AS VARCHAR(4)
                ),
                '-',
                RIGHT(
                    '00' + CAST(
                        CASE
                            WHEN arrival_date_month LIKE '%January%' THEN '01'
                            WHEN arrival_date_month LIKE '%February%' THEN '02'
                            WHEN arrival_date_month LIKE '%March%' THEN '03'
                            WHEN arrival_date_month LIKE '%April%' THEN '04'
                            WHEN arrival_date_month LIKE '%May%' THEN '05'
                            WHEN arrival_date_month LIKE '%June%' THEN '06'
                            WHEN arrival_date_month LIKE '%July%' THEN '07'
                            WHEN arrival_date_month LIKE '%August%' THEN '08'
                            WHEN arrival_date_month LIKE '%September%' THEN '09'
                            WHEN arrival_date_month LIKE '%October%' THEN '10'
                            WHEN arrival_date_month LIKE '%November%' THEN '11'
                            WHEN arrival_date_month LIKE '%December%' THEN '12'
                        END AS VARCHAR(2)
                    ),
                    2
                ),
                '-',
                RIGHT(
                    '00' + CAST(
                        arrival_date_day_of_month AS VARCHAR(2)
                    ),
                    2
                )
            ) AS arrival_date,
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
            reservation_status_date
        FROM BookingsRaw
    )
INSERT INTO
    BookingsClean (
        hotel, --LISTO!!
        is_canceled, --LISTO!!
        lead_time, --LISTO!!
        arrival_date, --LISTO!! 
        arrival_day_of_week, --LISTO!!  
        season, --LISTO!!  
        is_weekend, --LISTO!!  
        stays_in_weekend_nights, --LISTO!! 
        stays_in_week_nights, --LISTO!! 
        adults, --LISTO!!  
        children, --LISTO!!  
        babies, --LISTO!! 
        meal, --LISTO!! 
        country, --LISTO!! 
        country_normalized, --LISTO!! 
        market_segment, --LISTO!! 
        distribution_channel, --LISTO!! 
        is_repeated_guest, --LISTO!! 
        previous_cancellations, --LISTO!! 
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
        reservation_status_date
    )
SELECT
    hotel,
    CASE
		WHEN is_canceled = 0 THEN 'False'
		WHEN is_canceled = 1 THEN 'True'
		ELSE 'Unknown'
	END AS is_canceled,
    lead_time,
    arrival_date,
    DATENAME (
        WEEKDAY,
        CAST(arrival_date AS DATE)
    ) AS arrival_day_of_week,
    CASE
        WHEN MONTH(arrival_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(arrival_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(arrival_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(arrival_date) IN (9, 10, 11) THEN 'Autumn'
    END AS season,
    CASE
        WHEN DATENAME (WEEKDAY, arrival_date) IN ('Saturday', 'Sunday') THEN 1
        ELSE 0
    END AS is_weekend,
    stays_in_weekend_nights,
    stays_in_week_nights,
    CASE
        WHEN adults = 'NA' THEN 0
        ELSE adults
    END AS adults,
    CASE
        WHEN children = 'NA' THEN 0
        ELSE children
    END AS children,
    CASE
        WHEN babies = 'NA' THEN 0
        ELSE babies
    END AS babies,
    CASE
        WHEN meal = 'Undefined' THEN 'Unknown'
        ELSE meal
    END AS meal,
    country,
    CASE
        WHEN country = 'PRT' THEN 'Portugal'
        WHEN country = 'GBR' THEN 'United Kingdom'
        WHEN country = 'USA' THEN 'United States'
        WHEN country = 'ESP' THEN 'Spain'
        WHEN country = 'IRL' THEN 'Ireland'
        WHEN country = 'FRA' THEN 'France'
        WHEN country IS NULL THEN 'Unknown'
        WHEN country = 'ROU' THEN 'Romania'
        WHEN country = 'NOR' THEN 'Norway'
        WHEN country = 'OMN' THEN 'Oman'
        WHEN country = 'ARG' THEN 'Argentina'
        WHEN country = 'POL' THEN 'Poland'
        WHEN country = 'DEU' THEN 'Germany'
        WHEN country = 'BEL' THEN 'Belgium'
        WHEN country = 'CHE' THEN 'Switzerland'
        WHEN country = 'CN' THEN 'China_'
        WHEN country = 'GRC' THEN 'Greece'
        WHEN country = 'ITA' THEN 'Italy'
        WHEN country = 'NLD' THEN 'Netherlands'
        WHEN country = 'DNK' THEN 'Denmark'
        WHEN country = 'RUS' THEN 'Russia'
        WHEN country = 'SWE' THEN 'Sweden'
        WHEN country = 'AUS' THEN 'Australia'
        WHEN country = 'EST' THEN 'Estonia'
        WHEN country = 'CZE' THEN 'Czech Republic'
        WHEN country = 'BRA' THEN 'Brazil'
        WHEN country = 'FIN' THEN 'Finland'
        WHEN country = 'MOZ' THEN 'Mozambique'
        WHEN country = 'BWA' THEN 'Botswana'
        WHEN country = 'LUX' THEN 'Luxembourg'
        WHEN country = 'SVN' THEN 'Slovenia'
        WHEN country = 'ALB' THEN 'Albania'
        WHEN country = 'IND' THEN 'India'
        WHEN country = 'CHN' THEN 'China'
        WHEN country = 'MEX' THEN 'Mexico'
        WHEN country = 'MAR' THEN 'Morocco'
        WHEN country = 'UKR' THEN 'Ukraine'
        WHEN country = 'SMR' THEN 'San Marino'
        WHEN country = 'LVA' THEN 'Latvia'
        WHEN country = 'PRI' THEN 'Puerto Rico'
        WHEN country = 'SRB' THEN 'Serbia'
        WHEN country = 'CHL' THEN 'Chile'
        WHEN country = 'AUT' THEN 'Austria'
        WHEN country = 'BLR' THEN 'Belarus'
        WHEN country = 'LTU' THEN 'Lithuania'
        WHEN country = 'TUR' THEN 'Turkey'
        WHEN country = 'ZAF' THEN 'South Africa'
        WHEN country = 'AGO' THEN 'Angola'
        WHEN country = 'ISR' THEN 'Israel'
        WHEN country = 'CYM' THEN 'Cayman Islands'
        WHEN country = 'ZMB' THEN 'Zambia'
        WHEN country = 'CPV' THEN 'Cape Verde'
        WHEN country = 'ZWE' THEN 'Zimbabwe'
        WHEN country = 'DZA' THEN 'Algeria'
        WHEN country = 'KOR' THEN 'South Korea'
        WHEN country = 'CRI' THEN 'Costa Rica'
        WHEN country = 'HUN' THEN 'Hungary'
        WHEN country = 'ARE' THEN 'United Arab Emirates'
        WHEN country = 'TUN' THEN 'Tunisia'
        WHEN country = 'JAM' THEN 'Jamaica'
        WHEN country = 'HRV' THEN 'Croatia'
        WHEN country = 'HKG' THEN 'Hong Kong'
        WHEN country = 'IRN' THEN 'Iran'
        WHEN country = 'GEO' THEN 'Georgia'
        WHEN country = 'AND' THEN 'Andorra'
        WHEN country = 'GIB' THEN 'Gibraltar'
        WHEN country = 'URY' THEN 'Uruguay'
        WHEN country = 'JEY' THEN 'Jersey'
        WHEN country = 'CAF' THEN 'Central African Republic'
        WHEN country = 'CYP' THEN 'Cyprus'
        WHEN country = 'COL' THEN 'Colombia'
        WHEN country = 'GGY' THEN 'Guernsey'
        WHEN country = 'KWT' THEN 'Kuwait'
        WHEN country = 'NGA' THEN 'Nigeria'
        WHEN country = 'MDV' THEN 'Maldives'
        WHEN country = 'VEN' THEN 'Venezuela'
        WHEN country = 'SVK' THEN 'Slovakia'
        WHEN country = 'FJI' THEN 'Fiji'
        WHEN country = 'KAZ' THEN 'Kazakhstan'
        WHEN country = 'PAK' THEN 'Pakistan'
        WHEN country = 'IDN' THEN 'Indonesia'
        WHEN country = 'LBN' THEN 'Lebanon'
        WHEN country = 'PHL' THEN 'Philippines'
        WHEN country = 'SEN' THEN 'Senegal'
        WHEN country = 'SYC' THEN 'Seychelles'
        WHEN country = 'AZE' THEN 'Azerbaijan'
        WHEN country = 'BHR' THEN 'Bahrain'
        WHEN country = 'NZL' THEN 'New Zealand'
        WHEN country = 'THA' THEN 'Thailand'
        WHEN country = 'DOM' THEN 'Dominican Republic'
        WHEN country = 'MKD' THEN 'North Macedonia'
        WHEN country = 'MYS' THEN 'Malaysia'
        WHEN country = 'ARM' THEN 'Armenia'
        WHEN country = 'JPN' THEN 'Japan'
        WHEN country = 'LKA' THEN 'Sri Lanka'
        WHEN country = 'CUB' THEN 'Cuba'
        WHEN country = 'CMR' THEN 'Cameroon'
        WHEN country = 'BIH' THEN 'Bosnia and Herzegovina'
        WHEN country = 'MUS' THEN 'Mauritius'
        WHEN country = 'COM' THEN 'Comoros'
        WHEN country = 'SUR' THEN 'Suriname'
        WHEN country = 'UGA' THEN 'Uganda'
        WHEN country = 'BGR' THEN 'Bulgaria'
        WHEN country = 'CIV' THEN 'Ivory Coast'
        WHEN country = 'JOR' THEN 'Jordan'
        WHEN country = 'SYR' THEN 'Syria'
        WHEN country = 'SGP' THEN 'Singapore'
        WHEN country = 'BDI' THEN 'Burundi'
        WHEN country = 'SAU' THEN 'Saudi Arabia'
        WHEN country = 'VNM' THEN 'Vietnam'
        WHEN country = 'PLW' THEN 'Palau'
        WHEN country = 'QAT' THEN 'Qatar'
        WHEN country = 'EGY' THEN 'Egypt'
        WHEN country = 'PER' THEN 'Peru'
        WHEN country = 'MLT' THEN 'Malta'
        WHEN country = 'MWI' THEN 'Malawi'
        WHEN country = 'ECU' THEN 'Ecuador'
        WHEN country = 'MDG' THEN 'Madagascar'
        WHEN country = 'ISL' THEN 'Iceland'
        WHEN country = 'UZB' THEN 'Uzbekistan'
        WHEN country = 'NPL' THEN 'Nepal'
        WHEN country = 'BHS' THEN 'Bahamas'
        WHEN country = 'MAC' THEN 'Macau'
        WHEN country = 'TGO' THEN 'Togo'
        WHEN country = 'TWN' THEN 'Taiwan'
        WHEN country = 'DJI' THEN 'Djibouti'
        WHEN country = 'STP' THEN 'São Tomé and Príncipe'
        WHEN country = 'KNA' THEN 'Saint Kitts and Nevis'
        WHEN country = 'ETH' THEN 'Ethiopia'
        WHEN country = 'IRQ' THEN 'Iraq'
        WHEN country = 'HND' THEN 'Honduras'
        WHEN country = 'RWA' THEN 'Rwanda'
        WHEN country = 'KHM' THEN 'Cambodia'
        WHEN country = 'MCO' THEN 'Monaco'
        WHEN country = 'BGD' THEN 'Bangladesh'
        WHEN country = 'IMN' THEN 'Isle of Man'
        WHEN country = 'TJK' THEN 'Tajikistan'
        WHEN country = 'NIC' THEN 'Nicaragua'
        WHEN country = 'BEN' THEN 'Benin'
        WHEN country = 'VGB' THEN 'British Virgin Islands'
        WHEN country = 'TZA' THEN 'Tanzania'
        WHEN country = 'GAB' THEN 'Gabon'
        WHEN country = 'GHA' THEN 'Ghana'
        WHEN country = 'TMP' THEN 'Timor-Leste'
        WHEN country = 'GLP' THEN 'Guadeloupe'
        WHEN country = 'KEN' THEN 'Kenya'
        WHEN country = 'LIE' THEN 'Liechtenstein'
        WHEN country = 'GNB' THEN 'Guinea-Bissau'
        WHEN country = 'MNE' THEN 'Montenegro'
        WHEN country = 'UMI' THEN 'U.S. Minor Outlying Islands'
        WHEN country = 'MYT' THEN 'Mayotte'
        WHEN country = 'FRO' THEN 'Faroe'
        ELSE country
    END AS country_normalized,
    CASE
        WHEN market_segment = 'Undefined' THEN 'Unknown'
        ELSE market_segment
    END AS market_segment,
    CASE
        WHEN distribution_channel = 'Undefined' THEN 'Unknown'
        ELSE distribution_channel
    END AS distribution_channel,
    is_repeated_guest,
    previous_cancellations,
    previous_bookings_not_canceled,
    reserved_room_type,
    assigned_room_type,
    booking_changes,
    deposit_type,
    CASE
        WHEN agent = 'NULL' THEN 0
        ELSE agent
    END AS agent,
    CASE
        WHEN company = 'NULL' THEN 0
        ELSE company
    END AS company,
    days_in_waiting_list,
    customer_type,
    adr,
    required_car_parking_spaces,
    total_of_special_requests,
    reservation_status,
    reservation_status_date
FROM FechaTransformada;

----------------------------------------------------------------------------------------------------------

-- Creacion del modelo estrella
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimCountry' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [DimCountry] (
		country_id INT NOT NULL PRIMARY KEY IDENTITY,
		initials VARCHAR(8),
		name NVARCHAR(100) NOT NULL UNIQUE,
		region NVARCHAR(100),
        CONSTRAINT UQ_DimCountry UNIQUE (initials, name, region)
	)
PRINT '✅ Tabla creada: DimCountry';
END ELSE BEGIN PRINT 'ℹ️ La tabla DimCountry ya existe';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimHotel' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [DimHotel] (
		hotel_id INT NOT NULL PRIMARY KEY IDENTITY,
		type NVARCHAR(50) NOT NULL UNIQUE
	)
PRINT '✅ Tabla creada: DimHotel';
END ELSE BEGIN PRINT 'ℹ️ La tabla DimHotel ya existe';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimGuest' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [DimGuest] (
		guest_id INT NOT NULL PRIMARY KEY IDENTITY,
		customer_type NVARCHAR(50) NOT NULL,
		market_segment NVARCHAR(50) NOT NULL,
		distribution_channel NVARCHAR(50) NOT NULL,
		is_repeated_guest BIT,
		CONSTRAINT UQ_DimGuest UNIQUE (customer_type, market_segment, distribution_channel, is_repeated_guest)
	)
PRINT '✅ Tabla creada: DimGuest';
END ELSE BEGIN PRINT 'ℹ️ La tabla DimGuest ya existe';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimDepositType' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [DimDepositType] (
		deposit_type_id INT NOT NULL PRIMARY KEY IDENTITY,
		type NVARCHAR(50) NOT NULL UNIQUE,
	)
PRINT '✅ Tabla creada: DimDepositType';
END ELSE BEGIN PRINT 'ℹ️ La tabla DimDepositType ya existe';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimRoom' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [DimRoom] (
		room_id INT NOT NULL PRIMARY KEY IDENTITY,
		type NVARCHAR(5) NOT NULL,
		description NVARCHAR(50) NOT NULL,
		category NVARCHAR(50) NOT NULL,
        CONSTRAINT UQ_DimRoom UNIQUE (type, description, category)
	)
PRINT '✅ Tabla creada: DimRoom';
END ELSE BEGIN PRINT 'ℹ️ La tabla DimRoom ya existe';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'DimMeal' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [DimMeal] (
		meal_id INT NOT NULL PRIMARY KEY IDENTITY,
		initials NVARCHAR(50) NOT NULL,
		name NVARCHAR(50) NOT NULL,
        CONSTRAINT UQ_DimMeal UNIQUE (initials, name)
	)
PRINT '✅ Tabla creada: DimMeal';
END ELSE BEGIN PRINT 'ℹ️ La tabla DimMeal ya existe';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'FactBookings' AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	CREATE TABLE [FactBookings] (
		booking_id INT NOT NULL PRIMARY KEY IDENTITY,
		hotel_id INT FOREIGN KEY REFERENCES DimHotel(hotel_id),
		is_canceled NVARCHAR(10),
		lead_time INT,
		arrival_date DATE,
		arrival_day_of_week NVARCHAR(10),
		season NVARCHAR(10),
		is_weekend BIT,
		stays_in_weekend_nights INT,
		stays_in_week_nights INT,
		adults INT,
		children INT,
		babies INT,
		meal_id INT FOREIGN KEY REFERENCES DimMeal(meal_id),
		country_id INT FOREIGN KEY REFERENCES DimCountry(country_id),
		guest_id INT FOREIGN KEY REFERENCES DimGuest(guest_id),
		previous_cancellations INT,
		previous_bookings_not_canceled INT,
		reserved_room_id INT FOREIGN KEY REFERENCES DimRoom(room_id),
		assigned_room_id INT FOREIGN KEY REFERENCES DimRoom(room_id),
		booking_changes INT,
		deposit_type_id INT FOREIGN KEY REFERENCES DimDepositType(deposit_type_id),
		agent INT,
		company INT,
		days_in_waiting_list INT,
		customer_type NVARCHAR(50),
		adr DECIMAL(10,2),
		required_car_parking_spaces INT,
		total_of_special_requests INT,
		reservation_status NVARCHAR(50),
		reservation_status_date DATE
	)
PRINT '✅ Tabla creada: FactBookings';
END ELSE BEGIN PRINT 'ℹ️ La tabla FactBookings ya existe';
END

----------------------------------------------------------------------------------------------------------

--Insercion de los datos en cada tabla del modelo
WITH country_data AS (
	SELECT 
		DISTINCT
			country,
			country_normalized
	FROM
		BookingsClean
)
INSERT INTO DimCountry(initials,name,region)
SELECT
	DISTINCT
	country,
	country_normalized,
	CASE
		-- EUROPA
		WHEN country_normalized IN ('Portugal','United Kingdom','Spain','Ireland','France','Romania','Norway',
						 'Poland','Germany','Belgium','Switzerland','Greece','Italy','Netherlands',
						 'Denmark','Russia','Sweden','Estonia','Czech Republic','Luxembourg','Slovenia',
						 'Albania','San Marino','Latvia','Serbia','Austria','Belarus','Lithuania','Turkey',
						 'Andorra','Gibraltar','North Macedonia','Monaco','Isle of Man','Liechtenstein') 
			THEN 'Europe'

		-- AMÉRICA
		WHEN country_normalized IN (
			'United States',
			'Argentina',
			'Puerto Rico',
			'Brazil',
			'Mexico',
			'Costa Rica',
			'Jamaica',
			'Uruguay',
			'Colombia',
			'Venezuela',
			'Chile',
			'Peru',
			'Dominican Republic',
			'Nicaragua',
			'Bahamas',
			'British Virgin Islands',
			'Panama',
			'Guadeloupe',
			'Barbados',
			'Saint Kitts and Nevis',
			'Guyana',
			'Suriname',
			'El Salvador',
			'GTM',
			'PYF',
			'DMA',
			'ATA'
		) THEN 'America'

		-- ÁFRICA
		WHEN country_normalized IN (
			'South Africa',
			'Mozambique',
			'Botswana',
			'Angola',
			'Zambia',
			'Cape Verde',
			'Zimbabwe',
			'Algeria',
			'Morocco',
			'Tunisia',
			'Nigeria',
			'Senegal',
			'Seychelles',
			'Ivory Coast',
			'Cameroon',
			'Burundi',
			'Egypt',
			'Malawi',
			'Madagascar',
			'Ethiopia',
			'Rwanda',
			'Uganda',
			'Comoros',
			'Mauritius',
			'Central African Republic',
			'Benin',
			'Gabon',
			'Ghana',
			'Togo',
			'Guinea-Bissau',
			'Mayotte',
			'SDN'
		) THEN 'Africa'

		-- ASIA & MEDIO ORIENTE
		WHEN country_normalized IN (
			'China',
			'India',
			'Japan',
			'South Korea',
			'Hong Kong',
			'Iran',
			'Georgia',
			'Israel',
			'Kazakhstan',
			'Pakistan',
			'Indonesia',
			'Lebanon',
			'Philippines',
			'Azerbaijan',
			'Bahrain',
			'Thailand',
			'Malaysia',
			'Armenia',
			'Sri Lanka',
			'Singapore',
			'Vietnam',
			'Palau',
			'Qatar',
			'United Arab Emirates',
			'Saudi Arabia',
			'Cambodia',
			'Timor-Leste',
			'Bangladesh',
			'Nepal',
			'Taiwan',
			'Macau',
			'Iraq',
			'Syria',
			'Jordan',
			'Lebanon',
			'Maldives',
			'Uzbekistan',
			'Tajikistan'
		) THEN 'Asia / Middle East'

		-- OCEANÍA
		WHEN country_normalized IN (
			'Australia',
			'New Zealand',
			'Fiji',
			'Kiribati',
			'NCL',
			'ASM',
			'MRT',
			'PYF',
			'KIR',
			'Fiji',
			'ATA'
		) THEN 'Oceania'

		-- CÓDIGOS ESPECIALES O NULOS
		WHEN country_normalized IS NULL THEN 'Unknown' 
		ELSE 'Unknown' 
	END AS region
FROM country_data

INSERT INTO DimHotel(type)
SELECT
	DISTINCT
		hotel
FROM
	BookingsClean

INSERT INTO DimGuest(customer_type,market_segment,distribution_channel,is_repeated_guest)
SELECT
	DISTINCT
		customer_type,
		market_segment,
		distribution_channel,
		is_repeated_guest
FROM
	BookingsClean

INSERT INTO DimDepositType(type)
SELECT
	DISTINCT
		deposit_type
FROM
	BookingsClean

WITH rooms_data AS (
	SELECT
		DISTINCT
			assigned_room_type
	FROM
		BookingsClean
)
INSERT INTO DimRoom(type, description, category)
SELECT
	assigned_room_type,
	CONCAT('Room Type ', assigned_room_type) AS description,
	CASE
		WHEN assigned_room_type IN ('A', 'C', 'D') THEN 'Economic'
		WHEN assigned_room_type IN ('B', 'H', 'L', 'P') THEN 'Premium'
		WHEN assigned_room_type IN ('E', 'F', 'G') THEN 'Standard'
		ELSE 'Unknown'
	END AS category
FROM
	rooms_data

WITH meals_data AS (
	SELECT
		DISTINCT
			meal
	FROM
		BookingsClean
)
INSERT INTO DimMeal(initials, name)
SELECT
	meal,
	CASE
		WHEN meal = 'BB' THEN 'Bed & Breakfast'
		WHEN meal = 'FB' THEN 'Full Board'
		WHEN meal = 'HB' THEN 'Half Board'
		WHEN meal = 'SC' THEN 'Self Catering'
		ELSE 'Unknown'
	END AS meal_name
FROM
	meals_data


INSERT INTO FactBookings(
	hotel_id, 
	is_canceled,
	lead_time,
	arrival_date,
	arrival_day_of_week,
	season,
	is_weekend,
	stays_in_weekend_nights,
	stays_in_week_nights,
	adults,
	children,
	babies,
	meal_id,
	country_id,
	guest_id,
	previous_cancellations,
	previous_bookings_not_canceled,
	reserved_room_id,
	assigned_room_id,
	booking_changes,
	deposit_type_id,
	agent,
	company,
	days_in_waiting_list,
	customer_type,
	adr,
	required_car_parking_spaces,
	total_of_special_requests,
	reservation_status,
	reservation_status_date
)
SELECT
	htl.hotel_id AS hotel_id,
	book.is_canceled,
	book.lead_time,
	book.arrival_date,
	book.arrival_day_of_week,
	book.season,
	book.is_weekend,
	book.stays_in_weekend_nights,
	book.stays_in_week_nights,
	book.adults,
	book.children,
	book.babies,
	ml.meal_id,
	ctry.country_id,
	gst.guest_id,
	previous_cancellations,
	previous_bookings_not_canceled,
	reserv_roo.room_id AS reserved_room_id,
    assig_roo.room_id AS assigned_room_id,
	booking_changes,
	depos.deposit_type_id,
	book.agent,
	book.company,
	book.days_in_waiting_list,
	book.customer_type,
	book.adr,
	book.required_car_parking_spaces,
	book.total_of_special_requests,
	book.reservation_status,
	book.reservation_status_date
FROM
	BookingsClean AS book
INNER JOIN DimHotel AS htl ON book.hotel = htl.type
INNER JOIN DimMeal AS ml ON book.meal = ml.initials
INNER JOIN DimCountry AS ctry ON book.country = ctry.initials
INNER JOIN DimGuest AS gst ON book.customer_type = gst.customer_type 
						AND book.market_segment = gst.market_segment 
						AND book.distribution_channel = gst.distribution_channel 
						AND book.is_repeated_guest = gst.is_repeated_guest
INNER JOIN DimRoom AS reserv_roo ON book.reserved_room_type = reserv_roo.type
INNER JOIN DimRoom AS assig_roo ON book.assigned_room_type = assig_roo.type
INNER JOIN DimDepositType AS depos ON book.deposit_type = depos.type
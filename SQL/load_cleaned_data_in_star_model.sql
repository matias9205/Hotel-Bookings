INSERT INTO [Star].[DimHotel]
(hotel)
SELECT
	DISTINCT hotel
FROM [Stage].[BookingsClean]

INSERT INTO [Star].[DimCountry]
(country_code, unique_country_code_region, country_name, region)
SELECT
	DISTINCT country, CONCAT(country, '_', SUBSTRING(region, 1, 3)), country_normalized, region
FROM [Stage].[BookingsClean]

INSERT INTO [Star].[DimMarket]
(market_segment)
SELECT
	DISTINCT market_segment
FROM [Stage].[BookingsClean]

INSERT INTO [Star].[DimCustomer]
(customer_type)
SELECT
	DISTINCT customer_type
FROM [Stage].[BookingsClean]



INSERT INTO [Star].[FactBookings]
(
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
	adr,
	required_car_parking_spaces,
	total_of_special_requests,
	reservation_status,
	reservation_status_date,
	total_nights,
	total_guests,
	lead_time_groups,
	arrival_date,
	hotel_id,
	country_id,
	market_id,
	customer_id
)
SELECT
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
	adr,
	required_car_parking_spaces,
	total_of_special_requests,
	reservation_status,
	reservation_status_date,
	total_nights,
	total_guests,
	lead_time_groups,
	arrival_date,
	hotel.hotel_id,
	coun.country_id,
	mark.market_id,
	cust.customer_id
FROM [Stage].[BookingsClean] AS clean_book
JOIN [Star].[DimHotel] AS hotel ON clean_book.hotel = hotel.hotel
JOIN [Star].[DimCountry] AS coun ON clean_book.country = coun.country_code
JOIN [Star].[DimCustomer] AS cust ON clean_book.customer_type = cust.customer_type
JOIN [Star].[DimMarket] AS mark ON clean_book.market_segment = mark.market_segment;

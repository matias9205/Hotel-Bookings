USE [HotelBookings];

------------------------------------------------------------------------------------------------------------------------
--------------------------------------PANORAMA GENERAL DE LAS RESERVAS HOTELERAS----------------------------------------
------------------------------------------------------------------------------------------------------------------------

--1. Nivel general (visión macro)

--Tiempo: año, mes, semana, día → evolución temporal de reservas, estacionalidad.

--Hotel: cadena hotelera, tipo de hotel (resort, city hotel).

--Ubicación: país de origen de los clientes, región/país donde está el hotel.

--¿Cual hotel tiene mayor cantidad de reservas?
SELECT
	htl.type AS hotel,
	is_canceled,
	COUNT(*) AS total_bookings
FROM
	FactBookings
JOIN DimHotel htl ON htl.hotel_id = FactBookings.hotel_id
--WHERE
--	is_canceled = 'False'
GROUP BY
	htl.type,
	is_canceled
ORDER BY
	total_bookings DESC

SELECT
	htl.type AS hotel,
	--is_canceled,
	COUNT(*) AS total_bookings,
    SUM(
		CASE 
			WHEN is_canceled = 'True' THEN 1 
			ELSE 0 
		END
	) AS canceled_bookings,
    SUM(
		CASE 
			WHEN is_canceled = 'False' THEN 1 
			ELSE 0 
		END
	) AS confirmed_bookings,
	SUM(
		CASE
			WHEN is_canceled = 'False' THEN stays_in_weekend_nights + stays_in_week_nights
			ELSE 0
		END
	) AS total_nights,
	SUM(
		CASE
			WHEN is_canceled = 'False' THEN adr * (stays_in_weekend_nights + stays_in_week_nights)
			ELSE 0
		END
	) AS revenue
	--FORMAT(arrival_date, 'yyyy-MM') AS period
FROM
	FactBookings
JOIN DimHotel htl ON htl.hotel_id = FactBookings.hotel_id
GROUP BY
	htl.type
	--is_canceled,
	--FORMAT(arrival_date, 'yyyy-MM')
ORDER BY
	total_bookings DESC

-----------------------------------CONCLUSION:--------------------------------- 
--Se observa que la mayor cantidad de cancelaciones se produce en los hoteles de ciudad

--¿En que periodo se registra la mayor cantidad de reservas y cual es el revenue?
SELECT
	htl.type AS hotel,
	--is_canceled,
	COUNT(*) AS total_bookings,
    SUM(
		CASE 
			WHEN is_canceled = 'True' THEN 1 
			ELSE 0 
		END
	) AS canceled_bookings,
    SUM(
		CASE 
			WHEN is_canceled = 'False' THEN 1 
			ELSE 0 
		END
	) AS confirmed_bookings,
	SUM(
		CASE
			WHEN is_canceled = 'False' THEN stays_in_weekend_nights + stays_in_week_nights
			ELSE 0
		END
	) AS total_nights,
	SUM(
		CASE
			WHEN is_canceled = 'False' THEN adr * (stays_in_weekend_nights + stays_in_week_nights)
			ELSE 0
		END
	) AS revenue,
	FORMAT(arrival_date, 'yyyy-MM') AS period
FROM
	FactBookings
JOIN DimHotel htl ON htl.hotel_id = FactBookings.hotel_id
GROUP BY
	htl.type,
	--is_canceled,
	FORMAT(arrival_date, 'yyyy-MM')
ORDER BY
	total_bookings DESC

-----------------------------------CONCLUSION:---------------------------------
--Los hoteles de ciudad poseen mas volumen de reservas en relacion a los de tipo Resort
--La mayor cantidad de reservas confirmadas, se produce desde abril hasta septiembre, 2016 y 2027, ya que en 2015 no hay tanto volumen de reservas, lo que indica temporadas altas urbanas
--En cuanto a las cancelaciones, City Hotel tiene meses con cancelaciones muy altas, a veces cercanas al volumen de reservas confirmadas, por ende City Hotel sufre una tasa de cancelación más alta y volátil



------------------------------------------------------------------------------------------------------------------------
--------------------------------------COMPORTAMIENTO Y PERFIL DEL HUESPED----------------------------------------
------------------------------------------------------------------------------------------------------------------------

SELECT
	cli.customer_type,
	SUM(
		CASE 
			WHEN is_canceled = 'False' THEN 1 
			ELSE 0 
		END
	) AS confirmed_bookings
FROM
	FactBookings
JOIN DimGuest cli ON cli.guest_id = FactBookings.guest_id
GROUP BY
	cli.customer_type
ORDER BY
	confirmed_bookings DESC


SELECT
	cli.customer_type,
	htl.type AS hotel,
	SUM(
		CASE 
			WHEN is_canceled = 'False' THEN 1 
			ELSE 0 
		END
	) AS confirmed_bookings
FROM
	FactBookings
JOIN DimGuest cli ON cli.guest_id = FactBookings.guest_id
JOIN DimHotel htl ON htl.hotel_id = FactBookings.hotel_id
GROUP BY
	cli.customer_type,
	htl.type
ORDER BY
	confirmed_bookings DESC


SELECT
	cli.market_segment,
	SUM(
		CASE 
			WHEN is_canceled = 'True' THEN 1 
			ELSE 0 
		END
	) AS canceled_bookings
FROM
	FactBookings
JOIN DimGuest cli ON cli.guest_id = FactBookings.guest_id
GROUP BY
	cli.market_segment
ORDER BY
	canceled_bookings DESC


SELECT
	cli.distribution_channel,
	SUM(
		CASE 
			WHEN is_canceled = 'True' THEN 1 
			ELSE 0 
		END
	) AS canceled_bookings
FROM
	FactBookings
JOIN DimGuest cli ON cli.guest_id = FactBookings.guest_id
GROUP BY
	cli.distribution_channel
ORDER BY
	canceled_bookings DESC






SELECT * FROM DimGuest
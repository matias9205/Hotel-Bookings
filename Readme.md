# 📊 Hotel Bookings BI Project

Este proyecto implementa un pipeline completo de ETL, modelado dimensional y visualización de datos para analizar reservas hoteleras a partir de un dataset público extraído de Kaggle. El objetivo es construir un modelo reproducible, escalable y accionable que permita entender el comportamiento de los huéspedes, identificar patrones de cancelación y optimizar decisiones comerciales.

---

## 🧠 Dataset

Fuente: [Hotel Bookings Dataset - Kaggle](https://www.kaggle.com/datasets/mathsian/hotel-bookings?select=hotel_bookings.csv)

Columnas originales:
`hotel`, `is_canceled`, `lead_time`, `arrival_date_year`, `arrival_date_month`, `arrival_date_week_number`, `arrival_date_day_of_month`, `stays_in_weekend_nights`, `stays_in_week_nights`, `adults`, `children`, `babies`, `meal`, `country`, `market_segment`, `distribution_channel`, `is_repeated_guest`, `previous_cancellations`, `previous_bookings_not_canceled`, `reserved_room_type`, `assigned_room_type`, `booking_changes`, `deposit_type`, `agent`, `company`, `days_in_waiting_list`, `customer_type`, `adr`, `required_car_parking_spaces`, `total_of_special_requests`, `reservation_status`, `reservation_status_date`

---

## ⚙️ Proceso ETL

1. **Carga inicial**  
   Se importa el archivo CSV a SQL Server mediante el asistente de importación (`Tasks > Import Flat File`) en la tabla `BookingsRaw`.

2. **Limpieza y normalización**  
   Se crea la tabla `BookingsClean` con columnas transformadas:
   - `arrival_date`: combinación de día, mes y año.
   - `arrival_day_of_week`: día de la semana.
   - `season`: estación del año.
   - `is_weekend`: flag para fines de semana.
   - `country_normalized`: nombre del país a partir del código.

3. **Modelo estrella**  
   Se diseñan las siguientes dimensiones y tabla de hechos:

   | Tabla           | Descripción |
   |----------------|-------------|
   | `DimHotel`     | Tipo de hotel |
   | `DimCountry`   | País y región |
   | `DimGuest`     | Tipo de cliente y canal |
   | `DimDepositType` | Tipo de depósito |
   | `DimRoom`      | Tipo y categoría de habitación |
   | `DimMeal`      | Tipo de comida |
   | `FactBookings` | Hechos de reservas con claves foráneas a las dimensiones |

4. **Carga de datos**  
   Se insertan los valores únicos en cada dimensión y luego se pobla `FactBookings` con las relaciones correspondientes.

---

## 🧾 Documentación de scripts SQL

Ubicados en la carpeta `/SQL`:

- `extract.sql`:  
  - Carga el archivo CSV en la tabla `BookingsRaw`.
  - Define estructura base y tipos de datos.

- `transform.sql`:  
  - Crea la tabla `BookingsClean` con columnas normalizadas.
  - Aplica transformaciones como fechas, estaciones, países y flags.
  - Crea el modelo estrella con dimensiones y tabla de hechos.
  - Define claves primarias, foráneas y restricciones de unicidad.

- `analytics.sql`:  
  - Realiza las queries necesarias para extraer los insights para presentar en el analisis

---

## 📐 Medidas DAX en Power BI

```DAX
Total Bookings = COUNT(FactBookings[booking_id])

Total Canceled Bookings = 
CALCULATE([Total Bookings], FactBookings[is_canceled] = TRUE)

Total Confirmed Bookings = 
CALCULATE([Total Bookings], FactBookings[is_canceled] = FALSE)

avg_revenue = 
SUMX(
  FILTER(FactBookings, FactBookings[is_canceled] = FALSE),
  FactBookings[adr] * (FactBookings[stays_in_week_nights] + FactBookings[stays_in_weekend_nights])
)

Avg Stay Length = 
AVERAGEX(FactBookings, FactBookings[stays_in_week_nights] + FactBookings[stays_in_weekend_nights])

Avg Lead Time = AVERAGE(FactBookings[lead_time])

ADR = 
AVERAGEX(
  FILTER(FactBookings, FactBookings[is_canceled] = FALSE),
  FactBookings[adr]
)

% Repeated Guests = 
DIVIDE(
  CALCULATE([Total Confirmed Bookings], DimGuest[is_repeated_guest] = TRUE),
  [Total Confirmed Bookings],
  0
)

% Canceled Bookings = 
DIVIDE([Total Canceled Bookings], [Total Bookings])
```

# 🏨 Hotel Bookings BI Dashboard

Este proyecto de Business Intelligence analiza reservas hoteleras a partir de un dataset público, aplicando técnicas de modelado dimensional, transformación de datos y visualización estratégica. El objetivo es construir un dashboard ejecutivo que facilite decisiones comerciales basadas en KPIs claros, narrativa visual y segmentación de clientes.

---

## 📁 Estructura del Proyecto

- `data/`: contiene el dataset original y el dataset transformado.
- `SQL/`: scripts para extracción, transformación y modelado estrella.
- `dashboard/`: archivo de Power BI con visualizaciones y KPIs.
- `README.md`: documentación del proyecto.

---

## 📊 Secciones del Dashboard

### 1. Panorama General

- KPIs clave: Total de reservas, % cancelaciones, ADR, revenue estimado.
- Evolución mensual de reservas confirmadas.
- Comparativa por tipo de hotel y segmento de mercado.

### 2. Segmentación de Clientes

- Distribución por tipo de cliente, canal de distribución y país.
- % de huéspedes repetidos.
- ADR por segmento y canal.

---

## 👤 Autor

**Matías Mazparrote Feliu**  
Backend & Data Engineer especializado en BI, modelado dimensional, automatización de pipelines y diseño de dashboards ejecutivos.  
🔗 [LinkedIn](https://www.linkedin.com/in/matias-mazparrote-feliu/)


---


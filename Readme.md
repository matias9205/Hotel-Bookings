# 📊 Hotel Bookings BI Project

Este proyecto implementa un pipeline completo de ETL, modelado dimensional y visualización de datos para analizar reservas hoteleras a partir de un dataset público. El objetivo es construir un modelo reproducible, escalable y accionable que permita entender el comportamiento de los huéspedes, identificar patrones de cancelación y optimizar decisiones comerciales.

---

## 🧠 Dataset

Fuente: [Hotel Bookings Dataset - Kaggle](https://www.kaggle.com/datasets/mathsian/hotel-bookings)

---

## ⚙️ Proceso ETL

1. **Carga inicial**  
   Importación del archivo CSV a SQL Server mediante el asistente de importación.

2. **Transformación y limpieza**  
   - Normalización de fechas (`arrival_date`)
   - Categorización por estación del año (`season`)
   - Flags como `is_weekend`, `is_repeated_guest`
   - Traducción de códigos de país a nombres

3. **Modelo estrella**  
   Se diseñan las siguientes tablas:

   - `DimHotel`
   - `DimGuest`
   - `DimCountry`
   - `DimRoom`
   - `DimMeal`
   - `DimDepositType`
   - `FactBookings`

   Cada dimensión contiene claves únicas y atributos descriptivos. La tabla de hechos consolida métricas y claves foráneas.

4. **Carga final**  
   Inserción de datos en dimensiones y hechos con validaciones de unicidad y trazabilidad.

---

## 📐 Medidas DAX en Power BI

```DAX
Total Bookings = COUNT(FactBookings[booking_id])

Total Canceled Bookings = 
CALCULATE([Total Bookings], FactBookings[is_canceled] = TRUE)

Total Confirmed Bookings = 
CALCULATE([Total Bookings], FactBookings[is_canceled] = FALSE)

ADR = 
AVERAGEX(
  FILTER(FactBookings, FactBookings[is_canceled] = FALSE),
  FactBookings[adr]
)

avg_revenue = 
SUMX(
  FILTER(FactBookings, FactBookings[is_canceled] = FALSE),
  FactBookings[adr] * (FactBookings[stays_in_week_nights] + FactBookings[stays_in_weekend_nights])
)

Avg Stay Length = 
AVERAGEX(FactBookings, FactBookings[stays_in_week_nights] + FactBookings[stays_in_weekend_nights])

Avg Lead Time = AVERAGE(FactBookings[lead_time])

% Repeated Guests = 
DIVIDE(
  CALCULATE([Total Confirmed Bookings], DimGuest[is_repeated_guest] = TRUE),
  [Total Confirmed Bookings],
  0
)

% Canceled Bookings = 
DIVIDE([Total Canceled Bookings], [Total Bookings])

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
# 🛒 Análisis E-Commerce · Olist Brasil

> *"Health & Beauty lidera en facturación pero no en satisfacción. La tarjeta de crédito concentra el 79% del revenue con un promedio de 3.65 cuotas."*

Proyecto de análisis de datos end-to-end sobre el marketplace de e-commerce más grande de Brasil, sobre un dataset de **107.819 órdenes** (2016–2018). El objetivo: identificar qué categorías, regiones y métodos de pago impulsan el revenue, y cómo se relacionan con la satisfacción del cliente.

---

## 📁 Estructura del proyecto

```
olist-ecommerce-analysis/
│
├── 01_EDA/
│   └── Olist_eda.ipynb         # Análisis exploratorio en Python
├── 02_ETL/
│   └── Olist_etl.sql           # Limpieza, transformación y carga en MySQL
├── 03_Dashboard/
│   └── capturas/               # Screenshots del dashboard en Power BI
└── data/
    └── README.md               # Descripción de los datasets utilizados
```

---

## 🔄 Etapas del proyecto

### Etapa 1 — Análisis Exploratorio (EDA)
**Herramientas:** Python · Pandas · Matplotlib · Seaborn · Jupyter

- Exploración de 9 datasets con 107.819 órdenes del marketplace Olist
- Análisis de revenue por categoría, estado y método de pago
- Estudio de evolución temporal de ventas (2016–2018)
- Análisis de satisfacción del cliente por categoría (review score)
- Identificación de patrones en métodos de pago y cuotas

### Etapa 2 — ETL & Data Warehouse
**Herramientas:** MySQL · SQL

- Carga de dataset consolidado en tabla staging `stg_olist_full`
- Construcción de **star schema** con `fact_orders` como tabla central
- 5 tablas dimensionales: `dim_cliente`, `dim_producto`, `dim_geo`, `dim_pago`, `dim_fecha`
- Población de dimensiones con `INSERT INTO ... SELECT` desde staging

### Etapa 3 — Dashboard en Power BI
**Herramientas:** Power BI · DAX

4 páginas interactivas con filtros por año y categoría/estado/método de pago:

| Página | Descripción |
|---|---|
| Resumen General | KPIs globales, métodos de pago, top 10 categorías y evolución de ventas |
| Análisis de Categorías | Tabla comparativa, rating promedio y relación Revenue vs Rating |
| Análisis Geográfico | Revenue por estado y ciudad · concentración geográfica |
| Análisis de Pagos | Dominancia por método, distribución y promedio de cuotas |

---

## 📊 Hallazgos principales

- **Health & Beauty** lidera en revenue ($1.22M) pero no aparece en el top de satisfacción
- **São Paulo** concentra el 38% de la facturación total ($4.97M)
- **Credit card** representa el 79% del revenue con un promedio de **3.65 cuotas**
- **Pico de ventas** en Noviembre 2017 — impacto de Black Friday
- **Books** y **Food & Drink** lideran en satisfacción del cliente (rating promedio > 4.4)
- Las categorías con mayor volumen no son necesariamente las mejor valoradas

---

## 🛠️ Stack técnico

![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=flat-square&logo=pandas&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=flat-square&logo=powerbi&logoColor=black)

---

## 📂 Datos

El dataset proviene de **Kaggle — Brazilian E-Commerce Public Dataset by Olist** (4.173 votos):
🔗 [kaggle.com/datasets/olistbr/brazilian-ecommerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

El dataset contiene 9 archivos CSV con información de órdenes, productos, vendedores, clientes, pagos y reviews del marketplace Olist (2016–2018).

> Los archivos CSV no están incluidos en el repositorio por su tamaño. El dataset original está disponible en el link de Kaggle.

---

## 👤 Autor

**Nicolás Acevedo**  
Data Analyst · E-commerce & Digital

[![LinkedIn](https://img.shields.io/badge/LinkedIn-nicolas--acevedo-0077B5?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/nicolas-acevedo-)
[![Portfolio](https://img.shields.io/badge/Portfolio-nacevedo--data.github.io-00c8ff?style=flat-square&logo=github&logoColor=white)](https://nacevedo-data.github.io)
[![Email](https://img.shields.io/badge/Email-acevedonicolas83@gmail.com-D14836?style=flat-square&logo=gmail&logoColor=white)](mailto:acevedonicolas83@gmail.com)

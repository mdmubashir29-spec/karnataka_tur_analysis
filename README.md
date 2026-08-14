# Karnataka Pigeon Pea (Tur) Agroclimatology and Yield Analysis (1997-2022)

An end-to-end econometric and agricultural data pipeline in R examining the relationship between precipitation dynamics and Pigeon Pea (Cajanus cajan) productivity across Karnataka, India.

---

## Project Overview
Pigeon Pea (Tur) is Karnataka's primary rainfed pulse crop, concentrated largely in the semi-arid northern districts. This project parses district-level crop statistics, programmatically retrieves gridded monthly rainfall data via the NASA POWER API, and evaluates climate sensitivity using multiple regression, panel fixed-effects models (plm), out-of-sample validation, and localized district sensitivity analysis.

---

## Tech Stack and Methodology
- Data Extraction and Scraping: rvest (parsed unstructured government HTML/XLS tables)[cite: 1]
- Meteorological Ingestion: nasapower (dynamic coordinate-based API harvesting across 31 districts)[cite: 1]
- Statistical Modeling: Multiple Linear Regression (lm), Panel Data Fixed Effects (plm), ANOVA[cite: 1]
- Visualization: Base R graphics, ggplot2[cite: 1]

---

## Visualizations and Key Findings

### 1. Yield Distribution and District Disparities
Statewide yields are right-skewed, clustering between 0.4 and 0.6 Tonne/ha, with select districts showing sharp production peaks.

![Yield Distribution]
<img width="900" height="450" alt="01_yield_distribution" src="https://github.com/user-attachments/assets/04d96a2d-69a4-4ed6-b886-6233406db5bc" />
<img width="1000" height="450" alt="01_yield_distribution_and_box" src="https://github.com/user-attachments/assets/838ac8dd-97df-41a4-8999-24186dd6a5a4" />



---

### 2. Statewide Long-Term Yield Trajectory
Average productivity displays a steady upward trend over the 25-year panel, reflecting advancements in crop management and seed varieties.

![State Average Yield Trend]
<img width="800" height="450" alt="02_state_yield_trend" src="https://github.com/user-attachments/assets/c708689d-78d2-4c8f-a0f9-5a364b0188a3" />


---

### 3. District-Level Rainfall Sensitivity
Pearson correlation coefficients between Kharif monsoon precipitation (June to September) and crop yield vary significantly across agro-ecological zones:

![District Rainfall Correlation]
<img width="850" height="650" alt="03_district_correlation" src="https://github.com/user-attachments/assets/60a0dbfd-d7d3-4e13-a567-8190ad655608" />


---
<img width="850" height="650" alt="04_district_correlation" src="https://github.com/user-attachments/assets/f589a6a3-44e3-408b-9880-90bbe2bd7012" />
<img width="850" height="700" alt="03_model_diagnostics" src="https://github.com/user-attachments/assets/d5f3d0ce-4914-466f-b5ca-d9af505b2df2" />

### 4. Out-of-Sample Model Validation (2019-2022)
Evaluating model performance on unseen historical years:
- Linear Model RMSE: 0.238 Tonne/ha
- Naive Average Baseline RMSE: 0.243 Tonne/ha
<img width="800" height="450" alt="04_model_validation" src="https://github.com/user-attachments/assets/afc3e9c0-ace0-4af0-8e42-d32466703aaf" />
<img width="850" height="650" alt="04_district_correlation" src="https://github.com/user-attachments/assets/aca6d89e-9ff4-49cd-8962-52f41764cf9f" />
<img width="850" height="700" alt="03_model_diagnostics" src="https://github.com/user-attachments/assets/7268caea-5cdd-4826-9827-6a62669005cd" />

The marginal improvement over the naive baseline indicates that total seasonal rainfall volume alone does not dictate yields. Growth-stage timing, extreme weather events, and soil conditions play critical roles.

![Actual vs Predicted Yields]
<img width="800" height="450" alt="05_actual_vs_predicted" src="https://github.com/user-attachments/assets/58db8ca5-fa99-413a-bbbc-1b9e6631e5ec" />


---

### 5. District Spotlight: Kalaburagi Pulse Bowl
A deep dive into Kalaburagi demonstrates high co-movement and annual volatility between Kharif monsoon totals and harvested yields.

![Kalaburagi Dynamics]
<img width="850" height="450" alt="05_kalaburagi_dynamics" src="https://github.com/user-attachments/assets/d58b645c-062f-49ff-be1e-7bc162ed1fb0" />

---

## Project Structure

```text
trial/
│
├── 1.R                                            # Complete R analysis script
├── horizontal_crop_vertical_year_report(2).xls   # Raw government data source
├── README.md                                     # Project documentation
│
├── plots/                                        # Generated visualizations
│   ├── 01_yield_distribution_and_box.png
│   ├── 02_state_yield_trend.png
│   ├── 03_model_diagnostics.png
│   ├── 04_district_correlation.png
│   ├── 05_actual_vs_predicted.png
│   └── 06_kalaburagi_dynamics.png
│
└── data/ (generated CSV outputs)
    ├── kalaburagi_pigeon_pea_clean.csv
    ├── kalaburagi_rain.csv
    ├── karnataka_tur.csv
    ├── karnataka_district_coordinates.csv
    └── district_rainfall_sensitivity.csv
```

---

## How to Run

1. Clone or download this repository.
2. Open 1.R in R or RStudio[cite: 1].
3. Run the script to execute the data pipeline, fit statistical models, and generate all output plots and CSV datasets[cite: 1].



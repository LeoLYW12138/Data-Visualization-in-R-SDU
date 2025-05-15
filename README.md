# Data Visualization in R (SDU)

**Group 16 Project**

A Shiny dashboard exploring global socio-economic and demographic trends using data from the United States Census Bureau, Numbeo, and the World Bank.

---

## Table of Contents

1. [Features](#features)
2. [Repository Structure](#repository-structure)
3. [Data Sources](#data-sources)
4. [Prerequisites](#prerequisites)
5. [Installation](#installation)
6. [Usage](#usage)
7. [Live Demo](#live-demo)
8. [Team Members](#team-members)
9. [Acknowledgements](#acknowledgements)

---

## Features

* **Fertility & Infant Mortality**
* **Gender Imbalance**
* **Cost of Living vs. Migration**
* **Groceries & Rent Index by Income & Continent**
* **Income-Group Shifts & Variable Changes**
* **Population Density vs. Life Expectancy**
* **Birth-Rate Trends by Continent & Income Class**
* **Animated Scatter Plots** with `gganimate`

---

## Repository Structure

```
.
├── DV_16.Rproj                    # RStudio project file
├── .gitignore
├── ui.R                           # Shiny UI definition
├── server.R                       # Shiny server logic
├── preprocess.R                  # Data cleaning & merging
├── birth_rate.R                  # Birth-rate visualization module
├── cost_of_living.R              # Cost-of-living & migration module
├── gender_imbalance_plot.R       # Gender imbalance module
├── living_cost_migration_plot.R  # Combined cost & migration plot
├── population_density.R          # Population density vs. life expectancy
├── shifts_income.R               # Income-group shift analysis
├── www/                           # Static assets (CSS, images)
│   └── ...
└── data/
    ├── IDB.csv
    ├── IDB_combined.csv
    ├── combined_new.csv
    └── cost_of_living_data.csv
```

---

## Data Sources

* **United Nations & World Bank** via `IDB.csv` & `IDB_combined.csv`
* **Numbeo** cost-of-living data (`cost_of_living_data.csv`)
* **Custom merged datasets** (`combined_new.csv`)

---

## Prerequisites

* **R** (version ≥ 4.0)
* **Packages**:

  ```r
  install.packages(
    c(
      "shiny", "tidyverse", "ggplot2", "plotly", "gganimate", "lubridate"
    )
  )
  ```

---

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/LeoLYW12138/Data-Visualization-in-R-SDU.git
   cd Data-Visualization-in-R-SDU
   ```
2. Open the RStudio project `DV_16.Rproj` (or run from R):

   ```r
   library(shiny)
   runApp()
   ```

---

## Usage

* Launch the app via `runApp()` or by clicking **Run App** in RStudio.
* Navigate through tabs for each analysis:

  * Fertility & Mortality
  * Gender Imbalance
  * Living Costs & Migration
  * Income Dynamics
  * Population Density
  * Birth-Rate Trends

---

## Live Demo

View the deployed app here: [Shinyapps.io](https://leolyw12138.shinyapps.io/DV_16/)

---

## Team Members

* **Leo Wong**
* **Sirintra Kunakornpaiboonsiri**
* **Narit Chatchawanchokchai**
* **Kasim Emre Sahin**

---

## Acknowledgements

* Data provided by the United Nations, World Bank, and Numbeo.
* See full project report: `Report-1.pdf`.

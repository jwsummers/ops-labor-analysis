# 🔧 Operational Labor Overcharge Analysis  
### **A Data Analytics Project by Jason Summers**

This project analyzes labor inconsistencies, overcharges, and operational inefficiencies in an automotive reconditioning workflow.  
It simulates the type of analysis performed in Service Operations, Technician Management, and Cost Reduction roles—similar to the real work I’ve done in my stretch analyst role at CarMax.

This repository demonstrates my ability to work across the **full data analytics stack**:

- **Excel** (cleaning, formulas, pivot tables, dashboards)
- **SQL (PostgreSQL)** (table design, views, window functions, KPIs)
- **Python** (Pandas, exploratory analysis, visualizations)
- **Power BI** (interactive dashboard with slicers & visuals)

It is intentionally designed as a **flagship portfolio project** showing end-to-end analytical thinking, data cleaning, operational insights, and visualization skills.

---

## 📁 Repository Structure

ops-labor-analysis/
│
├── data/
│ ├── ro_issues_raw.csv
│ ├── ro_issues_clean.csv
│ └── ro_issues_clean_for_bi.csv
│
├── excel/
│ └── Ops_Dashboard_Final.pdf # exported Excel dashboard
│
├── powerbi/
│ └── Ops_Analysis_Dashboard.pbix # interactive BI dashboard
│
├── python/
│ ├── analysis.ipynb # full Jupyter notebook workflow
│ └── visuals/ # saved charts
│
├── sql/
│ └── analysis_queries.sql # full SQL script with documentation
│
└── README.md


---

## 🎯 Project Overview

This project explores patterns behind:

- **Incorrect labor times**
- **Overlapping labor**
- **Unnecessary repairs**
- **High-cost repair actions**
- **Labor rate misuse or overcharging**
- **Technician-level performance differences**
- **Category-level operational risks**

It mirrors real operational problems in automotive reconditioning: technician efficiency, cost control, and repair order quality.

---

## 🧹 Data Cleaning & Preparation

### **Excel**

- Created structured tables  
- Added calculated fields:
  - `LaborCost_Billed`
  - `LaborCost_Correct`
  - `CostOvercharge`
  - `IssueSeverity`
- Standardized categorical fields  
- Applied data validation  
- Built an **Excel dashboard** with:
  - KPI cards  
  - Pivot tables  
  - Technician trends  
  - Category-level breakdown  

### **SQL**

Built a full PostgreSQL environment:

- Created table schema  
- Imported CSV data  
- Added a `ro_issues_clean` view  
- Added derived fields:
  - `action_quality`
  - `severity_score`
  - `op_risk_bucket`

SQL was then used for:

- Weekly trends  
- Category rollups  
- Technician-level benchmarking  
- Severity scoring  
- Operational risk analysis  
- Window functions  
- KPI calculations  

---

## 🐍 Python Analysis

Inside the included Jupyter Notebook:

### **Exploratory Data Analysis (EDA)**

- Summary statistics  
- Category distributions  
- Technician performance variance  
- Boxplots & histograms of cost overcharge  
- Multi-index pivot tables  
- Heatmaps (category × technician)  

### **Advanced Insights**

- Severity-weighted risk scoring  
- Technician Performance Index (TPI)  
- Operation Group hot-spot identification  
- Outlier detection  

---

## 📊 Power BI Dashboard

The interactive dashboard includes:

- **KPI Cards**
  - Total Cost Overcharge
  - % High-Severity Issues
  - Avg Cost Overcharge per RO
  - High-Risk Trend Index

- **Visuals**
  - Bar chart: Cost Overcharge by Technician (Top N)
  - Stacked column chart: Category distribution
  - Line chart: Weekly CO trend
  - Matrix heatmap: Category × Technician

- **Slicers**
  - Technician
  - Category
  - Severity
  - Operation Group
  - Week

The dashboard enables real-world operational decision-making and coaching strategies.

---

## 🚀 Key Insights

> The project consistently found that **incorrect labor and overlapping labor** contribute the majority of overcharges.

- RL, AD, FF, and KG showed abnormally high overcharge patterns.
- RL was the highest overall contributor but disproportionately high in *Unnecessary Repairs*.
- FF showed extreme spikes in *Incorrect Labor Time*.
- KG had unusually high *High Cost Repair* inflation.
- Overcharges were consistent week-to-week → indicating systemic operational issues, not isolated incidents.

---

## 🧠 Skills Demonstrated

### **Core Analytics Skills**
- Data cleaning & preprocessing  
- Calculated fields & KPI definitions  
- SQL joins, aggregations, window functions  
- EDA using Python/Pandas  
- Feature engineering  
- Dashboard development in Power BI  
- Operational cost analysis & root-cause investigation  

### **Business/Operations Skills**
- Technician efficiency analysis  
- Labor time validation  
- Overcharge detection  
- High-cost trend identification  
- Operational risk assessment  
- Process improvement insights  
- Performance coaching support  

---

## 📌 About This Project

This project reflects my real-world experience performing operational analysis in the automotive industry, where I’ve done:
- Repair Order Auditing
- Technician performance coaching
- Cost reduction investigations
- Operational process oversight
- Root-cause analysis

I built this repository as part of my transition into professional Data Analyst / Operations Analyst roles.

---

## 👋 About Me

I’m Jason Summers, a diagnostics expert, operations analyst, and aspiring data analyst.

After 20+ years solving complex automotive and operational problems, I now apply the same analytical mindset to data, turning noise into insights and insights into action.

---

## 📬 Contact

If you'd like to discuss this project or opportunities:
- LinkedIn: https://www.linkedin.com/in/jason-w-summers/
- GitHub: https://github.com/jwsummers
- Portfolio: https://jasonwsummers.com/
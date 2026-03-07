# RVA Specialist Coding Assessment — Roche PD Data Science & Analytics

R Shiny clinical data assessment using the ADSL and ADAE datasets from the `pharmaverseadam` package.

## Setup

**R Version:** 4.2.0 and above

**Install required packages:**
```r
install.packages(c("pharmaverseadam", "tidyverse", "gtsummary", "gt", "ggplot2", "shiny"))
```

## Repository Structure

```
├── question_1/
│   ├── question_1.R          # TEAE summary table script
│   └── teae_summary.html     # Output: regulatory-compliant HTML table
├── question_2/
│   ├── question_2.R          # AE severity visualization script
│   └── ae_severity_chart.png # Output: horizontal stacked bar chart
├── question_3/
│   └── question_3.R          # Interactive Shiny app (run with "Run App" in RStudio)
└── README.md
```

## Questions

### Question 1: TEAE Summary Table
Creates a regulatory-compliant summary table of Treatment-Emergent Adverse Events using `{gtsummary}`. The table displays System Organ Class and Preferred Term rows, structured by treatment arm, with subject counts and percentages using ADSL as the denominator.

**Output:** `teae_summary.html`

### Question 2: AE Severity Visualization
Produces a horizontal stacked bar chart showing unique subjects per System Organ Class, colored by severity (MILD, MODERATE, SEVERE) using `{ggplot2}`. Bars are ordered by increasing frequency of total subjects.

**Output:** `ae_severity_chart.png`

### Question 3: Interactive R Shiny Application
Integrates the Question 2 visualization into a Shiny dashboard with a `checkboxGroupInput` filter for treatment arm. The chart updates reactively based on the selected arms.

**Run:** Open `question_3.R` in RStudio → Click "Run App"

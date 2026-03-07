# Question 1: TEAE Summary Table
# Regulatory-compliant summary of Treatment-Emergent Adverse Events
#   ACTARM   — Treatment arm (e.g., "Placebo", "Xanomeline High Dose")
#   AESOC    — Body system category (e.g., "CARDIAC DISORDERS", "NERVOUS SYSTEM DISORDERS")
#   AEDECOD  — Specific event name (e.g., "ATRIAL FIBRILLATION", "HEADACHE")
#   TRTEMFL  — Flag marking whether an event is treatment-emergent ("Y" or not)
#   USUBJID  — Unique patient ID (exists in both ADSL and ADAE, links them together)

library(pharmaverseadam)
library(tidyverse)
library(gtsummary)

# Load pharmaverseadam data
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# 1. DATA EXPLORATION -------------------------------------------------
# Explore each data set ADSL and ADAE

cat("\nADSL Dataset:\n")
cat("Rows:", nrow(adsl), "| Columns:", ncol(adsl), "\n")
glimpse(adsl)

cat("\nADAE Dataset: \n")
cat("Rows:", nrow(adae), "| Columns:", ncol(adae), "\n")
glimpse(adae)

# The rows: how do AESOC and AEDECOD relate to each other?
# AESOC (parent) --> AEDECOD (child)
cat("\nAESOC → AEDECOD relationship\n")
adae %>%
  distinct(USUBJID, AESOC, AEDECOD) %>%
  head(20) %>%
  print()

# 2. DISTRIBUTIONS -------------------------------------------------
# Check the two fields ACTARM & TRTEMFL we filter before transforming

# ACTARM: We split the table columns by treatment arm. Explore what arms exists and how patients belong to each arm
cat("\n ACTARM in ADSL \n")
print(count(adsl, ACTARM))

# TRTEMFL: We filter ADAE to TRTEMFL == "Y", need to remove NA for later
cat("\n TRTEMFL in ADAE \n")
print(count(adae, TRTEMFL))

# 3. TRANSFORMATION  -------------------------------------------------
# Apply the requirements from the question

# Step 1: Apply TEAE Filter
# The question says: "Treatment-emergent AE records will have TRTEMFL == 'Y'", removed NA
adae_teae <- adae %>%
  filter(TRTEMFL == "Y")

cat("Records after filter:", nrow(adae_teae), "\n")

# Step 2: Remove duplicates 
# distinct() keeps one row per patient per event, removing the repeats
adae_teae_distinct <- adae_teae %>%
  distinct(USUBJID, ACTARM, AESOC, AEDECOD)

cat("Duplicate rows removed:", nrow(adae_teae) - nrow(adae_teae_distinct), "\n\n")
cat("Rows after distinct:", nrow(adae_teae_distinct), "\n")

# Step 3: Build the TEAE Summary Table 
# tbl_hierarchical() builds a nested table:
# AESOC as parent rows, AEDECOD indented underneath, split by ACTARM,
# with percentages using ADSL as the denominator and an overall row at the top
teae_table <- adae_teae_distinct %>%
  tbl_hierarchical(
    variables = c(AESOC, AEDECOD),
    by = ACTARM,
    denominator = adsl,
    id = USUBJID,
    overall_row = TRUE
  ) %>%
  # Bold the body system rows (AESOC)
  bold_labels() %>%
  # Rename the left column header
  modify_header(label ~ "**System Organ Class / Preferred Term**") %>%
  # Add a spanning header above the treatment arm columns, targets all columns containing statistical data
  modify_spanning_header(
    all_stat_cols() ~ "**Treatment Arm**"
  )

# Step 4: Export to HTML
teae_table %>%
  as_gt() %>%
  gt::gtsave("teae_summary.html")

cat("TEAE summary table saved to teae_summary.html\n")
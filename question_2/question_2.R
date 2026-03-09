# Question 2: AE Severity Visualization
# Horizontal stacked bar chart of adverse events by body system and severity
#   USUBJID  — Unique patient ID (for counting unique subjects)
#   AESOC    — Body system category (e.g., "CARDIAC DISORDERS") — our Y-axis
#   AESEV    — Severity level (e.g., "MILD", "MODERATE", "SEVERE") — our color fill

library(pharmaverseadam)
library(tidyverse)
library(ggplot2)

# Load pharmaverseadam data, only ADAE
adae <- pharmaverseadam::adae

# 1. DATA EXPLORATION -------------------------------------------------
# Explore each data set ADAE

cat("=== ADAE ===\n")
cat("Rows:", nrow(adae), "| Columns:", ncol(adae), "\n")
glimpse(adae)

# 2. DISTRIBUTIONS  -------------------------------------------------

# What severity levels exist?
cat("\n=== AESEV values ===\n")
print(count(adae, AESEV))

# How many body systems (AESOC)?
cat(n_distinct(adae$AESOC), "AESOC body systems\n")

# 3. TRANSFORMATION  -------------------------------------------------
# Prepare data for the chart

# Step 1: Remove duplicates
# Note: a patient can still appear in multiple severity segments for the same body system.
# The question says: "Ensure each subject is counted at most once per severity level within each SOC."
ae_dedup <- adae %>%
  distinct(USUBJID, AESOC, AESEV)

cat("Rows after:", nrow(ae_dedup), "\n")

# Step 2: Count unique subjects per AESOC per AESEV
# After duplication clean up, we count the rows per group.
ae_counts <- ae_dedup %>%
  count(AESOC, AESEV, name = "n_subjects")

cat("Counts per body system per severity \n")
print(head(ae_counts, 10))

# Now we have the raw counts. Before building the chart, we need to:
# Step 3: Order AESOC so the chart Y-axis goes from fewest to most subjects
# Step 4: Order AESEV so the bar segments stack SEVERE → MODERATE → MILD

# Step 3: Order AESOC by total subjects
# The question says: "ordered by increasing frequency of total subjects per SOC"
# We need to sum up n_subjects per body system, then tell ggplot to use that order instead.
# fct_reorder() does this, it reorders AESOC by the sum of n_subjects.
ae_counts$AESOC <- fct_reorder(ae_counts$AESOC, ae_counts$n_subjects, .fun = sum)

cat("\n AESOC factor levels (bottom to top of chart)\n")
print(levels(ae_counts$AESOC))

# Step 4: Set severity order for consistent stacking
# Make AESEV an ordered factor so the bars stack SEVERE → MODERATE → MILD (base)
ae_counts$AESEV <- factor(ae_counts$AESEV, levels = c("SEVERE", "MODERATE", "MILD"))

# Step 5: Build the chart
ae_plot <- ggplot(ae_counts, aes(x = n_subjects, y = AESOC, fill = AESEV)) +
  # stat = "identity" uses our pre-counted n_subjects values instead of counting rows
  geom_bar(stat = "identity") +
  labs(
    title = "Unique Subjects per SOC and Severity Level",
    x = "Number of Unique Subjects",
    y = "System Organ Class",
    fill = "Severity"
  ) +
  scale_fill_manual(values = c(
    "MILD"     = "#FCBBA1",
    "MODERATE" = "#FB6A4A",
    "SEVERE"   = "#CB181D"
  )) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 8),
    plot.title = element_text(hjust = 0.5)
  )

# Step 6: Save as PNG
ggsave("ae_severity_chart.png", ae_plot, width = 12, height = 8, dpi = 300)
cat("Chart saved to ae_severity_chart.png\n")
# Question 3: Interactive R Shiny Application
# Wraps the Q2 bar chart into a Shiny dashboard with treatment arm filtering
#   USUBJID  — Unique patient ID (for counting unique subjects)
#   AESOC    — Body system category (Y-axis)
#   AESEV    — Severity level (color fill)
#   ACTARM   — Treatment arm (NEW — this is the filter input)

# Shiny App 
# The app has two parts:
#   UI — what the user sees (checkbox filter + chart)
#   Server — what happens behind the scenes (filter data, rebuild chart)

library(pharmaverseadam)
library(tidyverse)
library(ggplot2)
library(shiny)

# Load pharmaverseadam AEAE Data
adae <- pharmaverseadam::adae

# 1. DATA EXPLORATION -------------------------------------------------
# Same dataset as Q2, but now we also need ACTARM for the filter.

cat("=== ADAE ===\n")
cat("Rows:", nrow(adae), "| Columns:", ncol(adae), "\n")
glimpse(adae)

# 2. DISTRIBUTIONS  -------------------------------------------------

cat("\n=== ACTARM values (these become the checkbox options) ===\n")
print(count(adae, ACTARM))

cat("\n=== AESEV values ===\n")
print(count(adae, AESEV))

# 3a. UI SECTION -------------------------------------------------

ui <- fluidPage(
  titlePanel("AE Summary Interactive Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      # checkboxGroupInput creates one checkbox per treatment arm.
      # All arms are selected by default so the initial view shows everyone.
      checkboxGroupInput(
        inputId = "selected_arms",
        label = "Select Treatment Arm(s):",
        choices = sort(unique(adae$ACTARM)),
        selected = sort(unique(adae$ACTARM))
      )
    ),
    
    mainPanel(
      width = 9,
      # plotOutput displays the chart that the server generates.
      plotOutput("ae_plot", height = "600px")
    )
  )
)

# 3b. SERVER SECTION -------------------------------------------------

server <- function(input, output) {
  
  # reactive() reruns this code every time input$selected_arms changes.
  # It returns the filtered and transformed data, ready for plotting.
  ae_data <- reactive({
    # If no arms are selected, show a blank chart instead of an error
    req(input$selected_arms)
    
    # Step 1: Filter to selected treatment arms
    adae_filtered <- adae %>%
      filter(ACTARM %in% input$selected_arms)
    
    # ---- Same code logic as Q2 all below ----
    
    # Step 2: Remove duplicates 
    # One row per patient per body system per severity
    ae_dedup <- adae_filtered %>%
      distinct(USUBJID, AESOC, AESEV)
    
    # Step 3: Count unique subjects per body system per severity
    ae_counts <- ae_dedup %>%
      count(AESOC, AESEV, name = "n_subjects")
    
    # Step 4: Order body systems by total subjects (same as Q2)
    ae_counts$AESOC <- fct_reorder(ae_counts$AESOC, ae_counts$n_subjects, .fun = sum)
    
    # Step 5: Set severity stacking order
    ae_counts$AESEV <- factor(ae_counts$AESEV, levels = c("MILD", "MODERATE", "SEVERE"))
    
    ae_counts
  })
  
  # renderPlot() rebuilds the chart every time ae_data() changes.
  output$ae_plot <- renderPlot({
    ae_counts <- ae_data()
    
    ggplot(ae_counts, aes(x = n_subjects, y = AESOC, fill = AESEV)) +
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
        plot.title = element_text(hjust = 0.5),
        # added padding around plot
        plot.margin = margin(10, 10, 10, 10)
      )
  })
}

# Launch the App
shinyApp(ui = ui, server = server)
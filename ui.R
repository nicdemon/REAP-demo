library(shiny)
library(shinyWidgets)
library(plotly)
library(bslib)
library(markdown)
source("functions.R")

# Define UI for application
page_navbar(
  theme = bs_theme(version = 5, bootswatch = "cosmo"),
  nav_panel(
    "Home",
     layout_columns(
       column(2),
       column(
         8,
         includeMarkdown("README.md")
       ),
       column(2),
       col_widths = c(2,8,2)
     )
  ),# Landing
  nav_panel(
    "Molecules query",
    page_sidebar(
      sidebar = sidebar(
        open = "always",
        width = "18%",
        pickerInput(
          inputId = "molecule",
          label = "Molecule",
          choices = names(REAP),
          options = list(`live-search` = TRUE)
        ),
        pickerInput(
          inputId = "patients",
          label = "Patients",
          choices = lst_patients,
          multiple = TRUE
        ),
        radioGroupButtons(
          inputId = "type",
          label = "Chart type",
          choices = c("Expression", "Distribution"),
          justified = TRUE,
        ),
        input_task_button(
          id = "queryBtn",
          label = "Query",
          icon = icon("magnifying-glass", lib = "font-awesome"),
          label_busy = "Querying..."
        )
      ),
      card(
        plotlyOutput(outputId = "query")
      )
    )
  ),# Molecules search
  nav_panel(
    "Pre-rendered heatmaps",
    page_sidebar(
      sidebar = sidebar(
        open = "always",
        width = "18%",
        pickerInput(
          inputId = "precomp",
          choices = c("Whole",
                      "IFN all",
                      "IFN sexes",
                      "IFN PCC categories",
                      "IFN BAFF levels",
                      # "IFN neuro levels",
                      "IL all",
                      "IL sexes",
                      "IL PCC categories",
                      "IL BAFF levels",
                      # "IL neuro levels",
                      "CCL all",
                      "CCL sexes",
                      "CCL PCC categories",
                      "CCL BAFF levels",
                      # "CCL neuro levels",
                      "CCR all",
                      "CCR sexes",
                      "CCR PCC categories",
                      "CCR BAFF levels",
                      # "CCR neuro levels",
                      "CXC all",
                      "CXC sexes",
                      "CXC PCC categories",
                      "CXC BAFF levels",
                      # "CXC neuro levels",
                      "GPR all",
                      "GPR sexes",
                      "GPR PCC categories",
                      "GPR BAFF levels",
                      # "GPR neuro levels",
                      "HSP all",
                      "HSP sexes",
                      "HSP PCC categories",
                      "HSP BAFF levels"
                      # "HSP neuro levels"
          ),
          #direction = "vertical",
          #justified = TRUE
        ),
        input_task_button(
          id = "loadBtn",
          label = "Load heatmap",
          icon = icon("file-import", lib = "font-awesome"),
          label_busy = "Loading heatmap..."
        )
      ),
      card(
        plotlyOutput(outputId = "pre_rendered")
      )
    )
  ),# Pre-rendered heatmaps
  nav_panel(
    "Heatmap builder",
    page_sidebar(
      sidebar = sidebar(
        open = "always",
        width = "18%",
        pickerInput(
          inputId = "molecules",
          label = "Molecules",
          choices = names(REAP),
          multiple = TRUE
        ),
        pickerInput(
          inputId = "patients_choice",
          label = "Patients",
          choices = list(
            "Patients groups" = c("All","Sexes","PCC categories","BAFF levels"),
            "Individual patients" = lst_patients
          ),
          multiple = TRUE
        ),
        input_task_button(
          id = "buildBtn",
          label = "Build heatmap",
          icon = icon("paper-plane", lib = "font-awesome"),
          label_busy = "Building heatmap..."
        ),
        useSweetAlert()
      ),
      card(
        plotlyOutput(outputId = "builder")
      )
    )
  ),# Custom heatmap builder
  title = "REAP data visualization demo",
  id = "page"
)
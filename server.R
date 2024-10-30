library(shiny)
library(shinyWidgets)
library(plotly)
source("functions.R")

# Define server logic
function(input, output, session) {
  output$query = renderPlotly({
    renderBarplot({
      input
    })
  }) |>
    bindEvent(input$queryBtn)
  output$pre_rendered = renderPlotly({
    renderHeatmapPrecomp({
      input
    })
  }) |>
    bindEvent(input$loadBtn)
  output$builder = renderPlotly({
    renderHeatmapCustom(
      input,
      output,
      session
    )
  }) |>
    bindEvent(input$buildBtn)
}
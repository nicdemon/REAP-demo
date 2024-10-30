library(shiny)
library(readr)
library(tidyverse)
library(xml2)
library(plotly)
library(reshape2)
library(plyr)
library(purrr)
library(scales)
library(RColorBrewer)
REAP = readRDS("data/REAP.rds")
metadata = readRDS("data/metadata.rds")
molecules = readRDS("data/molecules.rds")
custom_molecules = readRDS("data/custom_molecules.rds")
lst_patients = readRDS("data/patients.rds")

make_heatmap <- function(df, filt = NULL, name = NULL){
  df <- melt(df)
  colnames(df) <- c("ID", "Protein", "Value") # Error here, probably because of data input
  if (!is.null(filt)) {
    df <- inner_join(data.frame("ID" = filt), df, by = "ID")
  }
  ht <- plot_ly(
    df,
    name = name,
    x = ~Protein,
    y = ~ID,
    z = ~Value
  ) %>%
    add_heatmap(colorscale = "Spectral")
  
  return(ht)
}

renderBarplot <- function(input, output){
  if(!is.null(input$patients)){
    patients = as.vector(input$patients)
    df = REAP[patients, ]
  }else{
    df = REAP
    patients = lst_patients
  }
  
  if(input$type == "Expression"){
    return(
      plot_ly(
        df,
        x = ~patients,
        y = ~get(input$molecule),
        type = "bar"
      ) %>% 
        layout(
          xaxis = list(title = "Patients"),
          yaxis = list(title = "Detection levels"))
    )
  }else if(input$type == "Distribution"){
    df = data.frame(df[,input$molecule])
    colnames(df) = c('x')
    moyenne = as.double(format(round(mean(df$x), 2), nsmall = 2))
    std_dev = sd(df$x)
    moyenne_low = as.double(format(round(moyenne - (2.95*std_dev), 2), nsmall = 2))
    moyenne_high = as.double(format(round(moyenne + (2.95*std_dev), 2), nsmall = 2))
    norm_test = shapiro.test(df$x)$p.value
    if(norm_test > 0.05){
      info = paste("Normal distribution with p-value= ", norm_test, ", extremes can be considered statistically different", sep = "")
    }else{
      info = paste("Non-normal distribution with p-value= ", norm_test, ", extremes cannot be considered statistically different", sep = "")
    }
    
    plt = ggplot(df, aes(x)) +
      geom_histogram(aes(y = ..density..), colour = 1, fill = "grey") +
      xlim(0, 10) +
      geom_vline(xintercept = c(moyenne, moyenne_high, moyenne_low), linetype = "dotted", linewidth = 0.3) +
      ggtitle(info) +
      theme(plot.title = element_text(15))
    
    return(ggplotly(plt))
  }
}

renderHeatmapPrecomp <- function(input, output){
  choice <- input$precomp
  # Extract query from string choice
  choice = str_split_1(choice," ")
  mol = choice[1]
  grp = choice[2]
  # Load the pre-rendered graph
  file = sprintf("%1$s_%2$s.rds",mol,grp)
  print(file)
  ht = readRDS(sprintf("pre-rendered/%1$s",file))
  return(ht)
}

renderHeatmapCustom = function(input, output, session){
  patients = input$patients_choice
  df_ht <- REAP %>% rownames_to_column(var = "IPCO_ID")
  df_ht <- df_ht[, c("IPCO_ID", input$molecules)] # Could be bugging input as not filtered for input for molecules
  ht = NULL
  # Test for group choice vs patients choice
  if (length(patients)>1){
    if (patients[1] %in% c("All","Sexes","PCC categories","BAFF levels")) {
      sendSweetAlert(
        session = session,
        title = "Multiple patients groups selected!",
        text = "Please choose only one patients group or a list of individual patients.",
        type = "warning"
      )
    } else {
      ht = make_heatmap(df_ht, filt = patients)
    }
  } else {
    choice = patients[1]
    if (grepl("All", choice, fixed = T)) {
      ht <- make_heatmap(df_ht)
    } else if (grepl("Sexes", choice, fixed = T)) {
      meta_sexes <- data.frame(metadata$IPCO_ID, metadata$SEX)
      lst_females <- meta_sexes[meta_sexes["metadata.SEX"] == "F", "metadata.IPCO_ID"]
      lst_males <- meta_sexes[meta_sexes["metadata.SEX"] == "H", "metadata.IPCO_ID"]
      ht_f <- make_heatmap(df_ht, filt = lst_females, name = "Females")
      ht_m <- make_heatmap(df_ht, filt = lst_males, name = "Males")
      ht <- subplot(ht_f, ht_m)
    } else if (grepl("PCC", choice, fixed = T)) {
      meta_PCC <- data.frame(metadata$IPCO_ID, metadata$`GSS Class`)
      lst_PCC_negative <- meta_PCC[meta_PCC["metadata..GSS.Class."] == "negative", "metadata.IPCO_ID"]
      lst_PCC_none_mild <- meta_PCC[meta_PCC["metadata..GSS.Class."] == "none/mild", "metadata.IPCO_ID"]
      lst_PCC_moderate <- meta_PCC[meta_PCC["metadata..GSS.Class."] == "moderate", "metadata.IPCO_ID"]
      lst_PCC_severe <- meta_PCC[meta_PCC["metadata..GSS.Class."] == "severe", "metadata.IPCO_ID"]
      ht_neg <- make_heatmap(df_ht, filt = lst_PCC_negative, name = "Negative")
      ht_non <- make_heatmap(df_ht, filt = lst_PCC_none_mild, name = "None/Mild")
      ht_mod <- make_heatmap(df_ht, filt = lst_PCC_moderate, name = "Moderate")
      ht_sev <- make_heatmap(df_ht, filt = lst_PCC_severe, name = "Severe")
      ht <- subplot(ht_neg, ht_non, ht_mod, ht_sev, nrows = 2)
    } else if (grepl("BAFF", choice, fixed = T)) {
      meta_BAFF <- data.frame(metadata$IPCO_ID, metadata$`BAFF status at V1`)
      lst_BAFF_low <- na.omit(meta_BAFF[meta_BAFF["metadata..BAFF.status.at.V1."] == "Low", "metadata.IPCO_ID"])
      lst_BAFF_intermediate <- na.omit(meta_BAFF[meta_BAFF["metadata..BAFF.status.at.V1."] == "Intermediate", "metadata.IPCO_ID"])
      lst_BAFF_high <- na.omit(meta_BAFF[meta_BAFF["metadata..BAFF.status.at.V1."] == "High", "metadata.IPCO_ID"])
      ht_low <- make_heatmap(df_ht, filt = lst_BAFF_low, name = "Low")
      ht_int <- make_heatmap(df_ht, filt = lst_BAFF_intermediate, name = "Intermediate")
      ht_high <- make_heatmap(df_ht, filt = lst_BAFF_high, name = "High")
      ht <- subplot(ht_low, ht_int, ht_high)
    } else {
      ht = NULL
    }
  }
  return(ht)
}
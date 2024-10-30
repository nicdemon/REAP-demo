library(shiny)
library(flexdashboard)
library(readr)
library(tidyverse)
library(xml2)
library(shinyWidgets)
library(plotly)
library(reshape2)
library(plyr)
library(purrr)
library(scales)
library(RColorBrewer)
source("../app/functions.R")
setwd("./pre-rendered/")

# Load data

REAP = readRDS("../data/REAP.rds")
metadata = readRDS("../data/metadata.rds")
molecules = readRDS("../data/molecules.rds")
custom_molecules = readRDS("../data/custom_molecules.rds")
lst_patients = readRDS("../data/patients.rds")

# Make graphs then save them in a loop

for (mol in c("whole","IFN","IL","CCL","CCR","CXC","GPR","HSP")) {
  if (mol == "whole") {
    ht <- make_heatmap(REAP %>% rownames_to_column(var = "IPCO_ID"), filt = NULL)
    plotly_build(ht)
    saveRDS(ht, "whole.rds")
  } else {
    lst_mol = molecules[grepl(mol, molecules, fixed = T)]
    df_ht <- REAP %>% rownames_to_column(var = "IPCO_ID")
    df_ht <- df_ht[, c("IPCO_ID", lst_mol)]
    for (grp in c("all","sexes","PCC","BAFF")) {
      if (grp == "all") {
        ht <- make_heatmap(df_ht)
      } else if (grp == "sexes") {
        meta_sexes <- data.frame(metadata$IPCO_ID, metadata$SEX)
        lst_females <- meta_sexes[meta_sexes["metadata.SEX"] == "F", "metadata.IPCO_ID"]
        lst_males <- meta_sexes[meta_sexes["metadata.SEX"] == "H", "metadata.IPCO_ID"]
        ht_f <- make_heatmap(df_ht, filt = lst_females, name = "Females")
        ht_m <- make_heatmap(df_ht, filt = lst_males, name = "Males")
        ht <- subplot(ht_f, ht_m)
      } else if (grp == "PCC") {
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
      } else if (grp == "BAFF") {
        meta_BAFF <- data.frame(metadata$IPCO_ID, metadata$`BAFF status at V1`)
        lst_BAFF_low <- na.omit(meta_BAFF[meta_BAFF["metadata..BAFF.status.at.V1."] == "Low", "metadata.IPCO_ID"])
        lst_BAFF_intermediate <- na.omit(meta_BAFF[meta_BAFF["metadata..BAFF.status.at.V1."] == "Intermediate", "metadata.IPCO_ID"])
        lst_BAFF_high <- na.omit(meta_BAFF[meta_BAFF["metadata..BAFF.status.at.V1."] == "High", "metadata.IPCO_ID"])
        ht_low <- make_heatmap(df_ht, filt = lst_BAFF_low, name = "Low")
        ht_int <- make_heatmap(df_ht, filt = lst_BAFF_intermediate, name = "Intermediate")
        ht_high <- make_heatmap(df_ht, filt = lst_BAFF_high, name = "High")
        ht <- subplot(ht_low, ht_int, ht_high)
      }
      plotly_build(ht)
      saveRDS(ht, sprintf("%1$s_%2$s.rds",mol,grp))
    }
  }
}

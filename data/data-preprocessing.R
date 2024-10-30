library(readr)
library(tidyverse)
library(xml2)
library(reshape2)
library(plyr)
library(purrr)

# REAP data
REAP = read_csv("data/REAP_transposed.csv")
REAP = REAP %>% column_to_rownames(var = 'IPCO_ID')
saveRDS(REAP, "data/REAP.rds")
# Metadata
metadata <- read_csv("data/metadata_BAFF_levels.csv")
saveRDS(metadata, "data/metadata.rds")
# List of molecules of interest
lst_mol <- names(REAP)
saveRDS(lst_mol, "data/molecules.rds")
custom_molecules <- read_table("data/custom_molecules.txt", col_names = F)
custom_molecules <- as.vector(custom_molecules$X1)
saveRDS(custom_molecules,"data/custom_molecules.rds")
# List of patients of interest
lst_patients <- row.names(REAP)
saveRDS(lst_patients, "data/patients.rds")

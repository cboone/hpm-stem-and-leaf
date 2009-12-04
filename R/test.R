# Assumes that the current working directory is hpm-stem-and-leaf.
# 
source("R/stem.and.leaf.R")

whites <- read.csv("data/whites.csv")

# stem.and.leaf(t(whites[2]))
stem.and.leaf(t(whites[2]), sort = FALSE)
# stem.and.leaf(t(whites[2]), sort = FALSE, trim.outliers = FALSE)

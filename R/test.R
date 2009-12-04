# Assumes that the current working directory is hpm-stem-and-leaf.
# 
source("R/stem.and.leaf.R")

whites <- read.csv("data/whites.csv")

# cat("Default settings:\n")
# stem.and.leaf(t(whites[2]))

# cat("\nNo depths:\n")
# stem.and.leaf(t(whites[2]), depths = FALSE)

cat("\nNo depths, keep outliers:\n")
stem.and.leaf(t(whites[2]), depths = FALSE, trim.outliers = FALSE, unit = 10)

cat("\nNo depths, keep outliers, no sorting:\n")
stem.and.leaf(t(whites[2]), depths = FALSE, trim.outliers = FALSE, unit = 10, sort = FALSE)

cat("\n")

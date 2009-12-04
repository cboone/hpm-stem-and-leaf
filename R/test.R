# Assumes that the current working directory is hpm-stem-and-leaf.
# 
source("R/stem.and.leaf.R")

whites <- read.csv("data/whites.csv")

stem.leaf(t(whites[2]))

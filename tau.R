library(Rfast)
setwd("~/Desktop/")
# import data
rm( list = ls()); gc();
##user input
filename = "tau_test1.csv"
column_range = 42:74
output = "tau_test_tau.csv"
############
raw.data <- read.csv(filename, header = TRUE, sep = ",")
samples <- data.frame(raw.data[,column_range])
calcs <- 1-(samples/apply(samples, 1, max))
Tau <- rowSums(calcs)/(ncol(calcs)-1)
tau_analysis <- cbind(raw.data,Tau)
tau_subset <- subset(tau_analysis, Tau >= 0.9000)
write.csv(tau_subset, output , na = "", row.names = FALSE)
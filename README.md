# Tau analysis of gene expression data

The file tau.R calculates the tissue sepcificity constant (Tau) across a set of tissues for each gene within the analysis. The file tau_test.csv is input test data for tau.R. 

The file tau.sh uses sqlite3 to access a local expression database and selects the desired expression data. The script then passes that data into R to calculate Tau as in tau.R. Then the script uses the python library xlsxwriter to convert the .csv file to an .xlsx file and then formats that expression data as a heatmap for easier visualization. 



# tau

The file tau.R is an R script calculates the tissue sepcificity constant (Tau) across a set of tissues for each genes within the analysis. 

The file tau.sh is a bash script that uses sqlite3 to access and local expression database and selects the desired expression data. The script then passes that data into R to calculate Tau as in tau.R. Then the script uses the python library xlsxwriter to convert the .csv file to an .xlsx file and then formats that expression data as a heatmap for easier visualization. 

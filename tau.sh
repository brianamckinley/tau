filename=/Users/brianmckinley/desktop/sorghum/108_wray_anthesis_LCM/1_wray_LCM_tau
Rstart=32
Rend=35
pystart=${Rstart}-1
pyend=${Rend}-1
cat > /Users/brianmckinley/desktop/sorghum/select.sql << EOF
.mode tabs
.output ${filename}.csv
.headers ON
.separator ","
SELECT DISTINCT
TranscriptIDV3,
geneIDV3,
geneIDV1,
BINCODEmerc4,
NAME,
DESCRIPTION,
TYPE,
Pfam1,
Pfam2,
Pfam3,
Pfam4,
Pfam5,
Pfam6,
Pfam7,
Pfam8,
Functional_category,
GeneFamily,
List_Number,
notes,
misc_annotation,
Best_hit_arabi_name,
arabi_symbol,
arabi_defline,
Best_hit_rice_name,
rice_defline,
Clade,
Rice_Annotation,
Arabidopsis_Annotation,
Annotation_source,
MapmanProcess,
ArabidopsisID_description,
Epidermis_TPMmean,
Phloem_TPMmean,
Pith_TPMmean,
Xylem_TPMmean
FROM
(SELECT * FROM annotation
LEFT JOIN geneorder
ON geneorder.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN AnnotationV3
ON AnnotationV3.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN starchTPM
ON starchTPM.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN SASV3_TPM
ON SASV3_TPM.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN cc100M
ON cc100M.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN ccSM100
ON ccSM100.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN ccBTx623
ON ccBTx623.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN DellaDiurnalCycling
ON DellaDiurnalCycling.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN DellaDevV3
ON DellaDevV3.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN KellerDiurnalCycling
ON KellerDiurnalCycling.TRANScriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN AER
ON AER.TRANScriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN AER_hclust
ON AER_hclust.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN Dw2dw2
ON Dw2dw2.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN nroots
ON nroots.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN RootDepth
ON RootDepth.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN mapman4
ON mapman4.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN V1toV3
ON V1toV3.GeneIDV3 = annotation.GeneIDV3
LEFT JOIN TX08001
ON TX08001.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN temp
ON temp.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN sym2
ON sym2.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN ddym2
ON ddym2.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN pnnl
ON pnnl.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN dleaves
ON dleaves.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN LCM
ON LCM.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN wray_stem_dev
ON wray_stem_dev.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN root_hairs
ON root_hairs.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN tx_sas
ON tx_sas.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN x58M_BSI
ON x58M_BSI.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN x58M_diurnal
ON x58M_diurnal.TranscriptIDV3 = annotation.TranscriptIDV3
LEFT JOIN wray_anthesis_LCM
ON wray_anthesis_LCM.TranscriptIDV3 = annotation.TranscriptIDV3
)
where
Epidermis_TPMmean  >= 4 or
Phloem_TPMmean >= 4 or
Pith_TPMmean >= 4 or
Xylem_TPMmean >= 4
;
.exit
EOF

chmod +x /Users/brianmckinley/desktop/sorghum/select.sql
/Users/brianmckinley/desktop/sorghum/_01_SQLite3/sqlite-autoconf-3250000/SQLite3 /Users/brianmckinley/desktop/sorghum/Sorghum.db < /Users/brianmckinley/desktop/sorghum/select.sql
rm /Users/brianmckinley/desktop/sorghum/select.sql

cat > Tau.R << EOF
library(Rfast)
##user input
input = "${filename}.csv"
column_range = ${Rstart}:${Rend}
############
raw.data <- read.csv(input, header = TRUE, sep = ",")
samples <- data.frame(raw.data[,column_range])
calcs <- 1-(samples/apply(samples, 1, max))
Tau <- rowSums(calcs)/(ncol(calcs)-1)
tau_analysis <- cbind(raw.data,Tau)
tau_subset <- subset(tau_analysis, Tau >= 0.9000)
output = "${filename}.csv"
write.csv(tau_subset, output , na = "", row.names = FALSE)
EOF

Rscript Tau.R
rm Tau.R

cat > /Users/brianmckinley/desktop/sorghum/formatting.py << EOF

import pandas as pd
import numpy as np
from xlsxwriter.utility import xl_rowcol_to_cell
import xlsxwriter
filepath_in = "${filename}.csv"
filepath_out = "${filename}.xlsx"
pd.read_csv(filepath_in, delimiter=",", low_memory=False).to_excel(filepath_out, index=False)

df = pd.read_excel(filepath_out)
writer = pd.ExcelWriter('${filename}.xlsx', engine='xlsxwriter')
df = df.drop_duplicates(subset=[df.columns[0]], keep='first')
df = df.dropna(subset=['Tau'], how='any')
df.to_excel(writer, index=False, sheet_name='Sheet1')
workbook = writer.book
workbook = writer.book
worksheet = writer.sheets['Sheet1']

nrow = len(df.TranscriptIDV3)

cell_format = workbook.add_format(
    {
        'num_format': '0'
    }
)

cell_format.set_align('center')
worksheet.set_column(${pystart}, ${pyend}, 5, cell_format)

#cell_format1 = workbook.add_format()
#cell_format1.set_rotation()
#worksheet.set_row(0,100, cell_format1)

for i in range(nrow+1):
    worksheet.conditional_format(i,${pystart},i,${pyend}, {'type': '2_color_scale', 'min_color': '#d4ffd1', 'max_color': '#32cfff'})

writer.save()
quit()
EOF

python3.9 /Users/brianmckinley/desktop/sorghum/formatting.py
rm /Users/brianmckinley/desktop/sorghum/formatting.py
rm ${filename}.csv

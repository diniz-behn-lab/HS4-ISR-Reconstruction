# HS4-ISR-Reconstruction
Collection of R files that implement the Garrish method for ISR estimation from C-Peptide data along with 95% credible bounds. These scripts have been streamline to take in HS4 data specifically for the LEAD Center.

## Coding workflow
The files that are included in this repository are
1. Dataset Template Preprocessing.R
2. Cohort Parameter estimation script
3. ISR estimation Mixed-Effect at the individual level
4. Complete cohort model execution in a loop file.
5. Preliminary results and analysis file.

Each of these files should be ran in the order in which they are presented. There are a few lines in each scipt that have to be edited to ensure that each file runs correctly and is able to produce the correct output for the next file to use and run correctly.

##Dataset Template Preprocessing.R
This preprocessing script will take a dataset in csv format

# HS4-ISR-Reconstruction
Collection of R files that implement the Garrish method for ISR estimation from C-Peptide data along with 95% credible bounds. These scripts have been streamline to take in HS4 data specifically for the LEAD Center.

## Coding workflow
The files that are included in this repository are
1. Dataset Template Preprocessing.R
2. Cohort Parameter estimation script
3. ISR estimation Mixed-Effect at the individual level
4. Complete cohort model execution in a loop file.
5. Preliminary results and analysis file.

Each of these files should be ran in the order in which they are introduced here. There are a few lines in each scipt that have to be edited to ensure that each file runs correctly and is able to produce the correct output for the next file to use and run correctly.

## Dataset Template Preprocessing.R
### Inputs: 
- Path to HS4 Participant and OGTT Data CSV file
- Path to HS4 Participant Tanner

This preprocessing script will take a raw csv file dataset in the Healthy Start 4 format and clean the raw dataset to a cleaner format with only the necessary data. The script also takes a puberty csv and extracts Tanner stage participant information. These two files serve as the only inputs to this script and the paths to the datafiles that you will use must be updated in the first two lines before running.

Given any form of the data with varying amounts of anthropomorphic variables, the columns which are kept in the cleaned dataset are: Participant ID, Age, Sex, Type 2 Diabetes status, BMI percentile, Insulin at 0 min, C-Peptide (Cpep) at 0 min, Cpep at 15, Cpep at 30, Cpep at 60, Cpep at 60, Cpep at 90, Cpep at 120, and Cpep at 180. Because each participant is scheduled for two visits, some participants have visit 2 information as well marked with a v2 after each variable name. The same columns with v2 are also kept.

Data from visit 2s were in the same row as the data for the participant from their visit 1. Changing the format of this dataset from wide to long, any data from participants with visit 2 information were moved to their own row. Participant ID and a column variable created to denote the visit number of the data help connect rows of participants with both visits. 



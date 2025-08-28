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

### Outputs:
- Dataset CSV file in format to run ISR model
- Dataset XLSX file in format to run ISR model

### Description
This preprocessing script will take a raw csv file dataset in the Healthy Start 4 format and clean the raw dataset to csv or xlsx format with only the necessary data. The script also takes a puberty csv and extracts Tanner stage participant information to include in the final clean dataset.

Given any version of HS4 data as input, the columns which are kept in the cleaned dataset are: Participant ID, Age, Sex, Type 2 Diabetes status, BMI percentile, Insulin at 0 min, C-Peptide (Cpep) at 0 min, Cpep at 15, Cpep at 30, Cpep at 60, Cpep at 60, Cpep at 90, Cpep at 120, and Cpep at 180. Because each participant is scheduled for two visits, some participants have visit 2 information. If the participant has this data, then the same columns listed above are kept from visit 2. Data from visit 2s originally comes in the same row as the participant's visit 1 data. We alter the form of this dataset from a wide to a long format and any data from participants with visit 2 information were copied and moved to be treated as a new row in the dataset. Participant ID and the dataset variable "Visit" are used to keep track of the participants with two visits. 

Using the BMI percentile information, a BMI category is assigned to each participant. The CDC recommends that BMI categories for children and adolescents be done using their BMI percentile which has been standardized by age and sex: https://www.cdc.gov/bmi/child-teen-calculator/bmi-categories.html. 


## Cohort_Likelihood 

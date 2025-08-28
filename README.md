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
- Path to HS4 OGTT Data with Participant Data CSV file
- Path to HS4 Participant Puberty Data
- Path to save clean data set outputs.

### Outputs:
- Dataset CSV file in format to run ISR model (Path to save location needs to be edited)
- Dataset XLSX file in format to run ISR model (Path to save location needs to be edited)

### Description
This preprocessing script will take a raw csv file dataset in the Healthy Start 4 format and clean the raw dataset to csv or xlsx format with only the necessary data. The script also takes a puberty csv and extracts Tanner stage participant information to include in the final clean dataset.

Given any version of HS4 data as input, the columns which are kept in the cleaned dataset are: Participant ID, Age, Sex, Type 2 Diabetes status, BMI percentile, Insulin at 0 min, C-Peptide (Cpep) at 0 min, Cpep at 15, Cpep at 30, Cpep at 60, Cpep at 60, Cpep at 90, Cpep at 120, and Cpep at 180. If the participant has visit 2 information, then we keep the same columns as above from their second visit. We alter the form of this dataset from a wide format to a long format. Meaining that any data from participants with visit 2 information were copied and moved to be treated as a new row in the dataset. Participant ID and the created dataset variable "Visit" can be used to track individuals with two recorded visits. 

#### Important Note
C-Peptide data must be in pico moles per liter (pmol/L) for the model to produce accurate results. This script will convert the incoming data from nanograms/milliliter (ng/mL) to the necessary pmol/L. 

Lastly, a BMI category is assigned to each participant using their BMI percentile information. The CDC recommends that BMI categories for children and adolescents be done using their BMI percentile which has been standardized by age and sex: https://www.cdc.gov/bmi/child-teen-calculator/bmi-categories.html. These values were used in the assignation of the "Group_BMI" variable. For assigning a Tanner staging variable, breast staging and testicular staging variables were used to identify the Tanner stage of the participant.

### Saving Cleaned Datasets
After this preprocessing, both a csv and an xlsx form of the cleaned data should be stored in a local folder. Please update the desired location where you will choose to store these clean datasets.

## Cohort_Likelihood_Parameter_Estimation.R

### Input
- 

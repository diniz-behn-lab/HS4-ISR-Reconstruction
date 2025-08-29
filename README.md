# HS4-ISR-Reconstruction
Collection of R files that implement the Garrish method for estimating and individual's ISR function within a 95% credible bound region from C-Peptide data. These scripts have been streamline to take in HS4 data specifically for the LEAD Center.

# Coding workflow
The files that are included in this repository are
1. Dataset Template Preprocessing.R
2. Cohort Parameter estimation script
3. ISR estimation Mixed-Effect at the individual level
4. Complete cohort model execution in a loop file.
5. Preliminary results and analysis file.

Each of these files should be ran in the order in which they are introduced here. There are a few lines in each scipt that have to be edited to ensure that each file runs correctly and is able to produce the correct output for the next file to use and run correctly.

# Dataset Template Preprocessing.R
## Inputs: 
- Path to HS4 OGTT Data with Participant Data CSV file
- Path to HS4 Participant Puberty Data
- Path to save clean data set outputs.

## Outputs:
- Dataset CSV file in format to run ISR model 
- Dataset XLSX file in format to run ISR model

## Description
This preprocessing script will take a raw csv file dataset in the Healthy Start 4 format and clean the raw dataset to csv or xlsx format with only the necessary data. The script also takes a puberty csv and extracts Tanner stage participant information to include in the final clean dataset.

Given any version of HS4 data as input, the columns which are kept in the cleaned dataset are: Participant ID, Age, Sex, Type 2 Diabetes status, BMI percentile, Insulin at 0 min, C-Peptide (Cpep) at 0 min, Cpep at 15, Cpep at 30, Cpep at 60, Cpep at 60, Cpep at 90, Cpep at 120, and Cpep at 180. If the participant has visit 2 information, then we keep the same columns as above from their second visit. We alter the form of this dataset from a wide format to a long format. Meaning that any data from participants with visit 2 information were copied and moved to be treated as a new row in the dataset. Participant ID and the created dataset variable "Visit" can be used to track individuals with two recorded visits. 

### Important Note
C-Peptide data must be in pico moles per liter (pmol/L) for the model to produce accurate results. This script converts incoming data from nanograms/milliliter (ng/mL) to the necessary pmol/L. 

Lastly, a BMI category is assigned to each participant using their BMI percentile information. The CDC recommends that BMI categories for children and adolescents be done using their BMI percentile which has been standardized by age and sex: https://www.cdc.gov/bmi/child-teen-calculator/bmi-categories.html. These values were used in the assignation of the "Group_BMI" variable. For assigning a Tanner staging variable, breast staging and testicular staging variables were used to identify the Tanner stage of the participant.

## Saving Cleaned Datasets
After this preprocessing, both a csv and an xlsx form of the cleaned data should be stored in a local folder. Please update the desired location where you would like to store these clean datasets.

# Cohort_Likelihood_Parameter_Estimation.R

## Input
- Path to Cleaned Dataset

## Output
- Cohort-specific model parameter value.
- Plotted values of final parameter log likelihood.

## Description
This script calculates the lambda parameter value for the entire cohort of the dataset provided. This parameter value is calculated via maximum likelihood testing and prints the value wth greatest log-likehood given the data. Aside from the numerical value, the script also creates a plot which demonstrates that the value of lambda achieves a maximum log-likelihood on the grid of values it searched on.

# Mixed_Model_Individual_HS4.R
## Inputs
- Path to cleaned dataset XLSX file.
- Path to save plots.
- Lambda parameter value.
- Theta/range parameter value.

## Outputs
- Plot of an individual's reconstructed ISR with 95% credible bounds.
- Plot of an individual's observed vs reconstructed C-Peptide.
- Estimated ISR values during OGTT.
- Area under the curve calculations at each OGTT sampling point.
- Upper and lower bounds at 30 minute and 3 hour mark for AUC values.

## Description
Start by setting your working directly in R studio to the project folder housing all of these scripts. 

Insert the path of your cleaned dataset XLSX file in line 45 where the variable "df" is defined. Next, update the parameter value of lambda found from the previous script (Cohort_Likelihood_Parameter_Estimation.R) on line 50. One may change the value of the "range" parameter found on line 38 if you suspect the time-dependent correlation between sampling points should be increased or decreased in the ISR reconstruction.

The location to save both the ISR reconstructed plots and observed vs reconstructed C-Peptide must be edited in lines 192 and 225 (setwd()).

This script then returns a list of all variable values calculated from an individual's data. This includes the ISR values at each minute of the OGTT, AUC values, and the error between observed and reconstructed C-Peptide values.

## Cohort_Mixed_Effect_Model_Loop.R



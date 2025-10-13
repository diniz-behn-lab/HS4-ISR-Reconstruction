# HS4-ISR-Reconstruction
Collection of R files that implement the Garrish method for estimating an individual's ISR function within a 95% credible bound region from C-Peptide data. These scripts have been streamline to take in HS4 data specifically for the LEAD Center.

# Getting Started
The "Method Functions" folder holds function files which assist in creating the model and help it execute computational related tasks. The files in this folder will not require any editing whatsoever. 

The "Main Scripts" folder holds the scripts which create the model specifically tailored for the dataset provided. These files will require some edits to correctly create the model.

The code scripts within the "Main Scripts" folder are:

1. Dataset Template Preprocessing.R
2. Cohort Parameter estimation script
3. ISR estimation Mixed-Effect at the individual level
4. Complete cohort model execution in a loop file.

You will run the scripts in this order. Once you obtain a cleaned version of the data and the lambda cohort parameter value by running the script once, you can then go back and create the model starting from step 3 and 4.

Again, each of these files in the "Main Scripts" folder require you to edit a few lines to make sure things the code is referencing the correct location/path of the dataset you are building a model for.

# Dataset Template Preprocessing.R
## Inputs: 
- Path to HS4 OGTT Data with Participant Data CSV file
- Path to HS4 Participant Puberty Data
- Path to save clean data set outputs.

## Outputs:
- Dataset XLSX file in format to run ISR model

## Description
This preprocessing script will take a raw csv file dataset in the Healthy Start 4 format and return a cleaned CSV and XLSX version with only the necessary columns of the data. The script also takes a puberty csv and extracts Tanner stage participant information to include in the final clean dataset.

Given any version of HS4 data as input, the columns which are kept in the cleaned dataset are: Participant ID, Age, Sex, Type 2 Diabetes status, BMI percentile, Insulin at 0 min, C-Peptide (Cpep) at 0 min, Cpep at 15, Cpep at 30, Cpep at 60, Cpep at 60, Cpep at 90, Cpep at 120, and Cpep at 180. 

The datasets come in with any visit 2 information as additional columns. Just to simplify the structure of the dataset we change the format from wide to long. Meaning that all instances of visit 2 data was moved to its own row after all of the visit 1 data. "Participant ID" and the "Visit" columns can be used to track all the partipants with two visits. 

This script converts incoming data from nanograms/milliliter (ng/mL) to pmol/L. C-Peptide data must be in pico moles per liter (pmol/L) for the model to produce accurate results.

Lastly, a BMI category is assigned to each participant using their BMI percentile information. The CDC recommends that BMI categories for children and adolescents be done using their BMI percentile which has been standardized by age and sex: https://www.cdc.gov/bmi/child-teen-calculator/bmi-categories.html. These values were used in the assignation of the "Group_BMI" variable. For assigning a Tanner staging variable, breast staging and testicular staging variables were used to identify the Tanner stage of the participant.

## Saving Cleaned Datasets
After this preprocessing, an XLSX file of the cleaned data should be stored in a folder of your choice. Please update the desired location where you would like to store this clean datasets.

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
- Path to "Method Functions" folder.
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
Check that the path to the "Method Functions" folder is correct to import them.

Insert the path of your cleaned dataset XLSX file in line 45 where the variable "df" is defined. Next, update the parameter value of lambda found from the previous script (Cohort_Likelihood_Parameter_Estimation.R) on line 50. One may change the value of the "range" parameter found on line 38 if you suspect the time-dependent correlation between sampling points should be increased or decreased in the ISR reconstruction.

The location to save both the ISR reconstructed plots and observed vs reconstructed C-Peptide must be edited in lines 192 and 225 (setwd()). You should create these empty folders in the desired location prior.

This script then returns a list object with all of the relevant variables calculated from the individual's data. This includes the ISR values at each minute of the OGTT, calculated AUC values, and the error between observed and reconstructed C-Peptide values.

# Cohort_Mixed_Effect_Model_Loop.R
## Inputs
- Path to Mixed_Model_Individual_HS4.R
- Path to cleaned dataset XLSX file

## Outputs
- XLSX file with model outputs for entire cohort.
- XLSX file with estimated ISR values at each time point for the entire cohort.

## Description

This code calls the Mixed_Model_Individual.R in a for loop for all participants in the clean dataset with complete C-Peptide data. It assigns the model derived results (i.e., AUC values, time to peak) to a results dataframe and saves their estimated ISR in patient ISR dataframe. These files are saved in XLSX files containing the results for the entire cohort. Specify the location where you'd like this files to be saved.

library(writexl)
library(xlsx)

setwd("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project")
source("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project/Main Scripts/mixed_mod_individual_HS4.R")


participant_data = pull_complete_cpep_data("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/Derived Datasets/Clean_HS4_Data_For_ISR.xlsx")
Patient_ISR = data.frame(matrix(nrow = nrow(participant_data), ncol = 181))
Mixed_Effect_ISR_results = data.frame(ID = integer(),
                                    Group_BMI = character(),
                                    AUC_15min = double(),
                                    AUC_30min = double(),
                                    AUC_1hr = double(),
                                    AUC_90min = double(),
                                    AUC_2hr = double(),
                                    AUC_3hr = double(),
                                    tmax = double(),
                                    lb30mAUC = double(),
                                    ub30mAUC = double(),
                                    lb3hAUC = double(),
                                    ub3hAUC = double())
n = nrow(participant_data)
partic_range <- c(seq(1,n))

for (p in partic_range){
  print(p)
  model = mixed_mod_individual_HS4(participant = p,save_plots = TRUE)
  
  Mixed_Effect_ISR_results[nrow(Mixed_Effect_ISR_results)+1,] = c(model$partic,model$bmi_cat, model$AUC15, model$AUC30, 
                                                                  model$AUC1hr,model$AUC90,model$AUC2hr,model$AUC3hr,model$peakT)
  Patient_ISR[p,] = c(model$pred_ISR)
  
}
print("Done!")
## Think about also saving upper and lower bound to preserve ##
## Add AUC for each value. Create 
## For preliminary analysis, include 
## Each tanner stage, average plot across all time points. ##

#### SAVE ISR DERIVED METRICS ####
write.xlsx(Mixed_Effect_ISR_results,"Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project/Results/ISR_Derived_Results_HS4.xlsx",
           row.names = FALSE)
write.xlsx(Patient_ISR,"Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project/Results/Participant_Estimated_ISR_HS4.xlsx",
           row.names = FALSE)

#### 

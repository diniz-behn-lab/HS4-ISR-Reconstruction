# ---
#   
# Title: "Preprocessing HS4 Data sets to match template for ISR reconstruction method. "  
# author: "Daniel Ramirez"
# 
# Last updated: August 19, 2025
# ---

#### Import Data sets/Edit Data set paths ####
library(writexl)

raw_data = read.csv("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/Source Files/p0001_DinizBehnC_120034.csv")
puberty_data = read.csv("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/Source Files/p0001_HS4_Tanner_St.csv")


#### SUBSET HS4 DATA with only desired columns. ####

templateColumns = c("pid","hs4_visit_agecalc","hs4_visit2_agecalc","hs4_patinfo_csex",
"hs4_mainq_c3b","hs4_mainq_c3b_v2", "Body_Mass_kg_v1","Body_Mass_kg_v2","insulin_v1","insulin_v2",
"c_peptide_0_v1","c_peptide_15_v1", "c_peptide_30_v1", "c_peptide_60_v1",
"c_peptide_90_v1","c_peptide_120_v1", "c_peptide_180_v1", 
"c_peptide_0_v2","c_peptide_15_v2", "c_peptide_30_v2", "c_peptide_60_v2",
"c_peptide_90_v2","c_peptide_120_v2", "c_peptide_180_v2", "weight_v1",
"height_v1","bmi_v1","bmi_cat_v1", "bmipct_v1",
"weight_v2","height_v2","bmi_v2","bmi_cat_v2", "bmipct_v2")

data_Template_Form = raw_data[ ,names(raw_data) %in% templateColumns]


#### SUBSET PUBERTY DATA with only entries in HS4 data. ####
HS4_participants = data_Template_Form$pid
pubertyColumns = c("pid","HS4_tanner_age_v1", "hs4_fps_breaststage","HS4_tanner_age_v2","hs4_fps_breaststage_v2",
                   "hs4_mps_teststage","hs4_mps_teststage_v2")

study_Puberty_Data = puberty_data[puberty_data$pid %in% HS4_participants, pubertyColumns ]


#### COLLECT VISIT 2 DATA and create new row with visit 2 data. ####
V1Columns = c("pid","hs4_visit_agecalc",
              "hs4_patinfo_csex","height_v1","weight_v1",
              "bmipct_v1", "hs4_mainq_c3b", "insulin_v1",
              "c_peptide_0_v1","c_peptide_15_v1", "c_peptide_30_v1", "c_peptide_60_v1",
              "c_peptide_90_v1","c_peptide_120_v1", "c_peptide_180_v1")

V1_Data = data_Template_Form[,V1Columns]
V1_Data$Visit = rep(1,nrow(V1_Data)) ## Created Visit number variable for each entry.


V2Columns = c("pid","hs4_visit2_agecalc",
              "hs4_patinfo_csex","height_v2","weight_v2",
              "bmipct_v2", "hs4_mainq_c3b_v2","insulin_v2",
              "c_peptide_0_v2","c_peptide_15_v2", "c_peptide_30_v2", "c_peptide_60_v2",
              "c_peptide_90_v2","c_peptide_120_v2", "c_peptide_180_v2")

V2_ID = complete.cases(data_Template_Form$hs4_visit2_agecalc)
V2_Data = data_Template_Form[V2_ID,V2Columns] #subset people with V2 information

V2_Data$Visit = rep(2,nrow(V2_Data)) #add visit number column


#### CHANGE column names and REORDER columns. ####
colnames(V1_Data) <- c("ID","Age","Sex","Height","Weight","BMI_PCT","T2D","Insulin0min","Cpep0min",
                       "Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min",
                       "Cpep180min","Visit")

colnames(V2_Data) <- c("ID","Age","Sex","Height","Weight","BMI_PCT","T2D", "Insulin0min","Cpep0min",
                       "Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min",
                       "Cpep180min","Visit")


V1_Data = V1_Data[,c("ID","Visit","Age","Sex","Height","Weight","BMI_PCT","T2D","Insulin0min","Cpep0min",
                     "Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min",
                     "Cpep180min")]
V2_Data = V2_Data[,c("ID","Visit","Age","Sex","Height","Weight","BMI_PCT","T2D","Insulin0min",
                     "Cpep0min","Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min",
                     "Cpep180min")]


#### COMBINE VISIT 1 AND VISIT 2 DATA INTO SAME DATASET. ####
combined_Data = rbind(V1_Data,V2_Data)


#### CONVERT C-Peptide data from ng/mL to pmol/L ####
CPEP_MOLARMASS = 3020.3
CPEP_COLS = c("Cpep0min","Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min","Cpep180min")
combined_Data[,CPEP_COLS] = combined_Data[,CPEP_COLS]* 10^6*(1/CPEP_MOLARMASS) # Pointing to Cpep Data Column

#### CONVERT Insulin data from micro IU/ml to pmol/L ####
combined_Data[,"Insulin0min"] = 6 * combined_Data[,"Insulin0min"]

#### ASSIGNING BMI CATEGORY BASED OFF BMI PERCENTILE PER CDC GUIDELINES FOR ADOLESCENTS AND KIDS ####
n = nrow(combined_Data)

for(participant in 1:n){

    if(is.na(combined_Data$BMI_PCT[participant])){
    next # we dont want NAs in data mistakenly receiving a BMI category.
  }
  else if (combined_Data$BMI_PCT[participant] < 5){
    combined_Data$Group[participant] = 1
  }
  else if(combined_Data$BMI_PCT[participant] >= 5 & combined_Data$BMI_PCT[participant]< 85){
    combined_Data$Group[participant] = 2
  }
  else if (combined_Data$BMI_PCT[participant] >= 85 & combined_Data$BMI_PCT[participant]< 95){
    combined_Data$Group[participant] = 3
  } 
  else if (combined_Data$BMI_PCT[participant] >= 95){
    combined_Data$Group[participant] = 4
  }
}

#### ADDING TANNER STAGING VARIABLE FROM PUBERTY DATA ####

# HS4_participants == study_Puberty_Data$pid.Participants appear in the same order for both.
for(p in 1:n){
  
  row_index = which(study_Puberty_Data$pid == combined_Data$ID[p])#Need to save the row index
  # in puberty data to refer back for p > 339 (i.e., visit 2 participants).

  if(combined_Data$Sex[p] == 1 & combined_Data$Visit[p] == 1)
    {
      combined_Data$TannerStage[p] = study_Puberty_Data$hs4_mps_teststage[p]
      combined_Data$TannerAge[p] = study_Puberty_Data$HS4_tanner_age_v1[p]
    }
  else if (combined_Data$Sex[p] == 1 & combined_Data$Visit[p] == 2)
    {
    combined_Data$TannerStage[p] = study_Puberty_Data$hs4_mps_teststage_v2[row_index]
    combined_Data$TannerAge[p] = study_Puberty_Data$HS4_tanner_age_v2[row_index]
    }
  else if(combined_Data$Sex[p] == 2 & combined_Data$Visit[p] == 1)
    {
    combined_Data$TannerStage[p] = study_Puberty_Data$hs4_fps_breaststage[p]
    combined_Data$TannerAge[p] = study_Puberty_Data$HS4_tanner_age_v1[p]
    }
  else if (combined_Data$Sex[p] == 2 & combined_Data$Visit[p] == 2)
    {
    combined_Data$TannerStage[p] = study_Puberty_Data$hs4_fps_breaststage_v2[row_index]
    combined_Data$TannerAge[p] = study_Puberty_Data$HS4_tanner_age_v2[row_index]
    }
}




#### FINAL COLUMN REORDING ####
finalColumns <- c("ID","Visit","Age","Sex","Height","Weight","BMI_PCT","Group",
                  "TannerStage","TannerAge","T2D","Insulin0min",
                  "Cpep0min","Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min","Cpep180min")
combined_Data = combined_Data[,finalColumns]
colnames(combined_Data)[8] <- "Group_BMI"

#### SAVE AS OUTPUT FINAL DATASET ####
write.csv(combined_Data,"Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/Derived Datasets/Clean_HS4_Data_For_ISR.csv",
          row.names = FALSE)

write_xlsx(combined_Data,"Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/Derived Datasets/Clean_HS4_Data_For_ISR.xlsx")

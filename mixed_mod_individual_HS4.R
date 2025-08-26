library(fields)
library(readxl)
library(foreach)

mixed_mod_individual_HS4 <- function(participant,save_plots = FALSE){
setwd("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project")

# Set the path to the directory containing your R scripts
script_directory <- "ISR_func_and_data"

# Get a list of all R script files in the directory
script_files <- list.files( path = script_directory,
                            pattern = "\\.R$", full.names = TRUE)

# Source each script file
for ( script_file in script_files) {
  source( script_file, local = TRUE)
}

###########################
### time points / matrices
###########################

# Define evaluation sites
n <- 180  # number of evaluation sites for ISR (post-basal)
e_sites <- seq(0, n, length.out = n + 1) # evaluation sites

# Define data sites
d_sites = c(0, 15, 30, 60, 90, 120, 180) # OGTT sampling schedule
m <- length( d_sites) - 1

# Design matrix
full_X<- cbind( e_sites, e_sites^2)
X<- full_X[-1, ]

# Kernel matrix
full_K<- build_kernel_matrix(e_sites, e_sites, range = 15) #range = theta param
star_K<- build_kernel_matrix(e_sites[-1], e_sites[-1], range = 15) 

###########################
### select participant
###########################

participant<- 1
df <- pull_complete_cpep_data("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/Derived Datasets/Clean_HS4_Data_For_ISR.xlsx")

sample_size<- nrow(df)
cohort<- 1:sample_size

lambda<-40.31747 #Computed with cohort_likelihood_real_data

w15m <- c(1/2, rep(1,14), 1/2)
w30m <- c(1/2, rep(1,29), 1/2)
w1h  <- c(1/2, rep(1,59), 1/2)
w90m <- c(1/2, rep(1,89), 1/2)
w2h  <- c(1/2, rep(1,119), 1/2)
w3h <- c(1/2, rep(1,179), 1/2)

###########################
### pre-processing
###########################

if ( df$Group_BMI[ participant] == "OB") {health <- 1} else {health <- 0}
lin_trans <- build_linear_transformation( age = as.numeric(df$Age[participant]),
                                          as.numeric(health),
                                          data_sites = e_sites,
                                          eval_sites = e_sites)

complete_W<- lin_trans$matrix
ind<- which(e_sites %in% d_sites)
full_W<- complete_W[ind, ]
W <- full_W[-1, -1]
k3 <- lin_trans$k3

## Cpep data must be in pmol/L units. ##
CPEP_COLS = c("Cpep0min","Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min","Cpep180min")
Cpep_data <- as.numeric(df[participant,CPEP_COLS]) #Reference columns w cpep data.
est_C0 <- Cpep_data[1] 
full_Cpep<- c(est_C0,Cpep_data[2: length(Cpep_data)]) #first measurement to last measurement
Cpep <- full_Cpep[-1] 

Sigma_vec<- c( 2000 + 0.001 * full_Cpep^2)
full_Sigma<- diag( Sigma_vec)
est_Sigma <- full_Sigma[-1, -1]

full_invSig <- 1 / diag( Sigma_vec)
invSig <- 1 / diag( Sigma_vec[-1])

cpep <- Cpep - est_C0
est_S0 <- k3 * est_C0
full_Z <- full_Cpep - est_C0 + est_S0 * rowSums(full_W)
Z <- full_Z[-1]

###########################
### estimate ISR
###########################

fit<- fit_nonlinear_model(Z, lambda, est_Sigma, star_K, W, X, est_S0)
hat_f<- fit$gp
hat_S<- c(0,fit$lgp)
A<- fit$A
B<- fit$B
Q<- fit$Q
hat_alpha<- fit$fixed_coeffs
pseudo_data<- c(fit$pseudo)
#pseudo_data<- c(0, fit$pseudo)

hat_s <- (abs( hat_S - est_S0) + hat_S - est_S0) / 2
hat_s2<- fit_linear_model( cpep, e_sites[-1], est_Sigma, W)
hat_S2<- hat_s2 + est_S0
hat_s2<- (abs( hat_s2) + hat_s2) / 2

## AB = Above Baseline. These AUC values are analogous to net insulin secreted from 0 to time t. ##
AUC_15min_Ab<- t(w15m) %*% hat_s[1:16]
AUC_30min_Ab<- t(w30m) %*% hat_s[1:31]
AUC_1hr_Ab<- t(w1h) %*% hat_s[1:61]
AUC_90min_Ab<- t(w90m) %*% hat_s[1:91]
AUC_2hr_Ab<- t(w2h) %*% hat_s[1:121]
AUC_3h_Ab<- t(w3h) %*% hat_s

time_to_peak<- which.max(hat_S) - 1

#Mean absolute Error from observed data to forward model Cpep data.
MAE = mean(abs(full_Cpep - c(est_C0,Z)))/length(full_Cpep)

### Model Estimated C-Peptide Graphs ###
plot(d_sites, full_Cpep,pch=19,cex=1.5,col= 'black',
     xlab = "Time (min)", ylab = 'C-peptide (pmol/L)',
     ylim = c(0,1.05*max(full_Cpep)),
     main = 'C-Peptide during OGTT: Z',
     cex.lab=1.3,cex.main=1.5)
lines(d_sites,full_Cpep,lty= 1,lwd=2,col='black')
points(d_sites,c(est_C0,Z),pch=1,cex=1.2,lwd=2, col='red')
lines(d_sites,c(est_C0,Z),lty= 2,lwd=2, col='red')
legend("topright",legend=c("True C-Pep", "Approx C-pep"),
       lty=1:2,lwd = 2,col=c("black","red"),cex = 1)

p_string = as.character(participant)
### SAVE PLOTS ###
if(save_plots == TRUE){
  setwd("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project/Reconstructed Cpep Plots")
  plot_filename <- paste0("Cpeptide Observed vs Approx ", p_string," Complete Data" ,".png")

  dev.print(
    device = png,
    filename = plot_filename,
    width = 8,
    height = 6,
    units = "in",
    res = 300)
  dev.off()
}

#transformation to change Cpep to ng/ml (*3020.3/10^6)

###########################
### credible bounds
###########################

ensemble_size<- 5000
E<- matrix( rnorm( (m) * ensemble_size ), m, ensemble_size)
p_ensemble<- replicate(ensemble_size, pseudo_data) +
  diag( sqrt( Sigma_vec[-1])) %*% E

system.time(
h_ensemble <- sapply(1:ensemble_size, function(j) {
  find_linear_prediction(data_vals = p_ensemble[, j],
                         noise_variance = Sigma_vec[-1],
                         kernel_matrix = star_K,
                         forward_matrix = B,
                         design_matrix = X,
                         reg_param = lambda)
})
)

S_ensemble<- est_S0 * exp( h_ensemble)
ensemble_AB = (abs(S_ensemble - est_S0) + S_ensemble - est_S0)/2 #Above Baseline

lBoundBF<- apply( S_ensemble, 1, FUN = quantile, probs = .025/8)
uBoundBF<- apply( S_ensemble, 1, FUN = quantile, probs = 1-.025/8)

topLimit = any(hat_S[-1] > uBoundBF[-1])
botLimit = any(hat_S[-1] < lBoundBF[-1])

ensemble30min_AUC = w30m %*% ensemble_AB[1:31]
ensemble3h_AUC = w3h %*% ensemble_AB

lb30m = apply(ensemble30min_AUC, 1, FUN = quantile, probs = .025/8)
ub30m = apply(ensemble30min_AUC, 1, FUN = quantile, probs = 1 -.025/8)

lb3h = apply(ensemble3h_AUC, 1, FUN = quantile, probs = .025/8)
ub3h = apply(ensemble3h_AUC, 1, FUN = quantile, probs = 1 -.025/8)

# withinBoundsCheck = FALSE
# if(withinBoundsCheck == TRUE){
#   if(topLimit == T || botLimit == T){
#     print("Inferred ISR curve not contained within credible bounds.")
#   }else{print("Inferred ISR curve is contained within credible bound.")}
# }

plot(e_sites, hat_S, type="n",xaxt = 'n',
       ylim = c(min( min(0, 0.95 * lBoundBF)), 1.05 * max(uBoundBF)),
       #ylim = c(min( min(0, 0.95 * min(hat_S))),1.05 * max(hat_S)+100),
      main= 'Inferred ISR with 95% credible bounds',
      xlab = "Time (min)",
      ylab = "ISR (pmol/L/min)",
      cex.lab = 1.25,
      cex.axis = 1.25,
      cex.main=1.5)

axis(1,at = d_sites)
abline(v = d_sites, col = '#09396C' ) #minesBlue
envelopePlot( e_sites,  c(est_S0,lBoundBF[-1]), e_sites, c(est_S0,uBoundBF[-1]),
               col = '#CFDCE9' , lineCol = '#879EC3') #minesPale , minesLight
lines( e_sites, c( est_S0, hat_S[-1]), lwd = 2, col = '#21314d')#minesDark
legend("topright",legend=c("95% Credible Bounds", "Estimated ISR"),
       lty=c(1,1),lwd = 2,col=c('#CFDCE9',"#21314d"),cex = 1,pch = c(19,19))

### SAVE PLOT ###
if(save_plots == TRUE){
  setwd("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project/ISR Plots")
  plot_filename <- paste0("Inferred ISR with credible bounds ", p_string," Complete Data" ,".png")
  
  dev.print(
    device = png,
    filename = plot_filename,
    width = 8,
    height = 6,
    units = "in",
    res = 300)
  dev.off()
}

result <- list(partic =df$ID[participant], bmi_cat = df$Group_BMI[participant],insulin0 = df$Insulin0min[participant],
               AUC15 = AUC_15min_Ab, AUC30 = AUC_30min_Ab,AUC1hr = AUC_1hr_Ab, AUC90= AUC_90min_Ab, 
               AUC2hr = AUC_2hr_Ab, AUC3hr = AUC_3h_Ab , peakT = time_to_peak, pred_ISR = hat_S,
               lowbound30 = lb30, upbound30 = ub30, lowbound3h = lb3h, upbound3h = ub3h)

 return(result)
}


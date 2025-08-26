library(fields)
library(readxl)

# Set the path to the directory containing your R scripts
setwd("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/HS4 Project")
script_directory <- "ISR_func_and_data"

# Get a list of all R script files in the directory
script_files <- list.files(path = script_directory,
                           pattern = "\\.R$", full.names = TRUE)

# Source each script file
for (script_file in script_files) {
  source(script_file, local = TRUE)
}

###########################
### time points
###########################

# Define evaluation sites
n <- 180  # number of evaluation sites for ISR (post-basal)
esites <- seq(0, n, length.out = n + 1) # evaluation sites

# Define data sites
sampl_times = c(0, 15,30, 60,90,120,180) # OGTT sampling schedule
dsites <- sampl_times
m <- length(dsites) - 1

# Design matrix
X<- cbind(esites, esites^2)

# Kernel matrix
star_K<- build_kernel_matrix(esites, esites, range = 15)

###########################
### import data
###########################

# Cpeptide data should be coming in units pmol/L. Check with Data Preprocessing R file.
df<- pull_complete_cpep_data("Z:/LEADStudentsTrainees/Ramirez, Daniel/120034/Derived Datasets/Clean_HS4_Data_For_ISR.xlsx")


###########################
### initialize values
###########################
lambda_grid <- 2^seq(  0, 8, length.out = 10)
cohort_ll_profile<- numeric( length( lambda_grid))
error_indices <- c()  # Initialize a vector to store indices of iterations with errors


###########################
### likelihood estimation
###########################
cohort_size<- nrow( df)
cohort<- 1:cohort_size

for ( p in cohort) {
  if ( df$Group_BMI[p] == "OB") {health <- 1} else {health <- 0}
  
  lin_trans <- build_linear_transformation(age = df$Age[p], health, 
                                           data_sites = dsites[-1], 
                                           eval_sites = esites)
  W <- lin_trans$matrix
  k3 <- lin_trans$k3
  Cpep_data <- as.numeric( df[p,12:18]) #Cpeptide data columns 
  C0 <- Cpep_data[1]
  Cpep <- Cpep_data[ 2:length(Cpep_data)]
  est_Sigma <- diag( c( 2000 + 0.001 * Cpep^2))
  invSig <- 1 / diag( est_Sigma)
  cpep <- Cpep - C0
  estS0 <- k3 * C0
  Z <- cpep + estS0 * rowSums( W)
  
  # Wrap the potentially problematic code within tryCatch
  tryCatch({
    ll_profile <- sapply( lambda_grid, function( reg_param)
      estimate_likelihood( reg_param, Z, est_Sigma, star_K, W, X, estS0))
    cohort_ll_profile <- cohort_ll_profile + ll_profile
  }, error = function( e) {
    cat( "Error at p =", p, "Error message:", conditionMessage(e), "\n")
    error_indices <- c( error_indices, p)  # Store the index of the problematic iteration
  })
   plot(lambda_grid, ll_profile, log = "x")
}

# Error indices will contain the p values where an error occurred
cat("Indices with errors:", error_indices, "\n")

###########################
### visualize results
###########################

# Plot the likelihood profile
plot(lambda_grid, cohort_ll_profile,
     log = "x",
     xlab = "Lambda",
     ylab = "Log-likelihood",
     main = "Aug/2025 HS4 Cohort Log-Likelihood Parameter Estimation"
)

# Plot maximimizer and true value
ind_max<- which.max(cohort_ll_profile)
hat_lambda<- lambda_grid[ind_max]
print( hat_lambda)
points( hat_lambda, cohort_ll_profile[ind_max], pch = 16, col = "blue")

# Plot confidence levels
level95 <- cohort_ll_profile[ind_max] - qchisq(0.95, df = 1) / 2 #95% confidence level
level99 <- cohort_ll_profile[ind_max] - qchisq(0.99, df = 1) / 2 #99% confidence level
abline(a = level95, b = 0, col = "magenta4")
abline(a = level99, b = 0, col = "green4")
legend("right", legend = c("95%", "99%"),
        col = c("magenta4", "green4"),
        lty = 1)



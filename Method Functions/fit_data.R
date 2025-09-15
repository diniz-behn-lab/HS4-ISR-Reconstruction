fit_data<- function(pseudo_data, reg_param, init_process_val, design_matrix,
                    forward_matrix, inv_noise_variance) {
  wrapper<- function(coeffs) {
    out<- compute_loss(coeffs, reg_param, pseudo_data, 
                       init_process_val, design_matrix, 
                       forward_matrix, inv_noise_variance
    ) 
    return(out)
  }
  fit<- optim(rep(0, ncol(design_matrix)), fn = wrapper, method = "BFGS")

# Extract the optimized parameters
alphaHat <- fit$par

# Compute estimated ISR values
SHat<- estS0 * exp(X %*% alphaHat)

out<- list(SHat, alphaHat)

return(out)
}

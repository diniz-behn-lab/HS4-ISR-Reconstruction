build_kernel_matrix<- function(eval_sites, centers, smooth=2.5, range=15) {
  # Builds kernel matrix conditioned on f0
  K<- stationary.cov( eval_sites, centers, Covariance="Matern",
                      smoothness=smooth, aRange=range)
  K01<- stationary.cov( 0, centers, Covariance="Matern",
                        smoothness=smooth, aRange=range)
  K10<- stationary.cov( eval_sites, 0, Covariance="Matern",
                        smoothness=smooth, aRange=range)
  
  
  
  star_K<- K - K10 %*% K01
  
  return(star_K)
}


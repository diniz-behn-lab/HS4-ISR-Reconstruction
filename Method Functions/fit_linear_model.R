fit_linear_model <- function( data, eval_sites, noise_matrix, forward_matrix, 
                              range_param = 17, 
                              process_var = 7400) {
  
  design_matrix<- cbind( 1, eval_sites)
  D <- rdist( eval_sites, eval_sites)
  K<- ( 1 + D / range_param) * exp( -D / range_param)
  k0<- cbind( ( 1 + eval_sites / range_param) * exp( -eval_sites / range_param))
  dk0<- cbind( eval_sites * exp( -eval_sites / range_param) / range_param^2)
  K0<- cbind( k0, dk0)
  invK00<- cbind( c( 1, 0), c( 0, range_param^2))
  star_K<- (K - K0 %*% invK00 %*% t( K0))
  chol_K<- chol( star_K)
  star_H<- process_var * crossprod( chol_K %*% 
                                      t( forward_matrix)) + noise_matrix
  V<- forward_matrix %*% design_matrix
  hat_alpha<- solve( t(V) %*% solve( star_H, V, method = "cholesky"),
                     t(V), method = "cholesky") %*% 
              solve( star_H, data, method = "cholesky")
  star_mu<- - K0 %*% hat_alpha
  res<- data - V %*% hat_alpha - forward_matrix %*% star_mu
  hat_s<- process_var * t( forward_matrix %*% star_K) %*% 
    solve( star_H, res, method = "cholesky") + 
    design_matrix %*% hat_alpha + star_mu
  return(hat_s)
}

find_linear_prediction <- function( data_vals, noise_variance, kernel_matrix,
                                    forward_matrix, design_matrix, reg_param){
  
  B<- forward_matrix
  A<- B %*% design_matrix
  inv_K<- chol2inv( chol( kernel_matrix))
  inv_noise_var<- 1 / noise_variance
  M<- rbind( cbind( t(A) %*% (inv_noise_var * A), 
                    t(A) %*% (inv_noise_var * B)), 
             cbind( t(B) %*% (inv_noise_var * A), 
                    t(B) %*% (inv_noise_var * B) + reg_param * inv_K))
  R<- chol(M)
  
  RHS<- rbind( t(A) %*% (inv_noise_var * data_vals), 
               t(B) %*% (inv_noise_var * data_vals))
  block_vec<- solve( R, solve( t(R), RHS))
  alpha<- block_vec[1: ncol( design_matrix)]
  f<- block_vec[(length( alpha) + 1): length( block_vec)]
  h<- c(0, design_matrix %*% alpha + f)
  return(h)
}
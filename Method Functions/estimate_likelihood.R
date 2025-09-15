estimate_likelihood <- function(reg_param, pseudo_data, noise_matrix, 
                                kernel_matrix, forward_matrix, design_matrix,
                                init_process_val) {
  m<- length(pseudo_data)
  fit<- fit_nonlinear_model( pseudo_data, reg_param, noise_matrix,
           kernel_matrix, forward_matrix, design_matrix,
           init_process_val)
  hat_alpha<- fit$fixed_coeffs
  A<- fit$A
  B<- fit$B
  z<- fit$pseudo
  H<- B %*% kernel_matrix %*% t( B) + reg_param * noise_matrix
  svd1<- svd( H)
  U<- svd1$u
  d<- svd1$d
  res<- z - A %*% hat_alpha
  out<- t( res) %*% U %*% ((1 / d) * t( U)) %*% res +
            m * log( 2 * pi) + sum( log( d))
  out<- -out / 2
  return( out)
}

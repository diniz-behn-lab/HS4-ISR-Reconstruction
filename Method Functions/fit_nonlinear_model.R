fit_nonlinear_model <- function( pseudo_data, reg_param, noise_matrix,
                                 kernel_matrix, forward_matrix, design_matrix,
                                 init_process_val, 
                                 init_guess = rep(1, ncol( forward_matrix)),
                                 tol = 1e-9, max_iter = 50) {
  ###########################
  ### starting values
  ###########################
  # old_h<- rep( (log(mean(pseudo_data)) - init_process_val), ncol(forward_matrix) )
  old_h<- init_guess
  
  svd1<- svd( kernel_matrix)
  U1<- svd1$u
  d1<- svd1$d
  inv_K<- U1 %*% ((1 / d1) * t(U1))
  
  inv_noise_vector<- 1 / diag( noise_matrix)
  
  ###########################
  ### estimation loop
  ###########################
  
  testConv<- 1
  count<- 0
  while ( testConv > tol){
    old_S<- c(init_process_val * exp( old_h))
    z<- pseudo_data - forward_matrix %*% ( old_S - old_S * old_h)
    B<- t( old_S * t( forward_matrix))
    A<- B %*% design_matrix
    # approximate model is yS = WS( design_matrix %*%alpha + f) + error
    
    M<- rbind( cbind( t(A) %*% (inv_noise_vector * A), 
                      t(A) %*% (inv_noise_vector * B)), 
               cbind( t(B) %*% (inv_noise_vector * A), 
                      t(B) %*% (inv_noise_vector * B) + reg_param * inv_K))
    # svd2<- svd(M)
    # U2<- svd2$u
    # d2<- svd2$d
    # V2<- svd2$v
    C<- rbind( t(A) %*% (inv_noise_vector * z), 
               t(B) %*% (inv_noise_vector * z))
    R<- chol( M)
    hat_block<- solve( t(R), C)
    hat_block<- solve( R, hat_block)
    # hat_block<- V2 %*% ((1 / d2) * t(U2)) %*% C
    # hat_block<- solve(M, C)
    hat_alpha<- hat_block[1:ncol(design_matrix)]
    hat_f<- hat_block[(length( hat_alpha) + 1):length(hat_block)]
    
    # M<- B %*% solve( t(B) %*% (inv_noise_vector * B) + reg_param * inv_K,
    #                  t( inv_noise_vector * B), method = "svd")
    # m<- nrow( M)
    # ImM<- inv_noise_vector * (diag( 1, m) - M)
    # hat_alpha<- solve( t(A) %*% ImM %*% A, t(A) %*% ImM %*% z,
    #                   method = "svd")
    # 
    # hat_f<- solve( t( B) %*% (inv_noise_vector * B) + reg_param * inv_K,
    #               t( inv_noise_vector * B), method = "svd") %*%
    #               (z - A %*% hat_alpha)
    hat_h<- design_matrix %*% hat_alpha + hat_f
    testConv<- mean( abs(hat_h - old_h))
    # cat( count, testConv, fill=TRUE)
    old_h<- hat_h
    count<- count + 1
    if (count >= max_iter) break
  }
  hat_S<- c(init_process_val * exp( hat_h))
  # star_H<- crossprod( chol_K %*% t( B)) + reg_param * noise_matrix
  # C<- apply( diag( 1, m), MARGIN = 2, function( data) {
  #   t( B %*% kernel_matrix) %*% solve( star_H, data - A %*%
  #                                        hat_alpha, method = "cholesky")
  # })
  # hat_K<- kernel_matrix - C %*% B %*% kernel_matrix -
  #   kernel_matrix %*% t( B) %*% t( C) + C %*%
  #   solve( star_H, t( C))
  # SE<- sqrt( diag ( hat_K))
  
  out<- list( lgp = c(hat_S), # log-Gaussian process
              gp = c(hat_f), # Gaussian process (mean-zero)
              fixed_coeffs = c(hat_alpha), # Fixed-component coefficients
              B = t( hat_S * t( forward_matrix)), # Forward matrix in linear model
              A = B %*% design_matrix, # Forward matrix with design matrix in linear model
              pseudo = c(pseudo_data - forward_matrix %*% ( hat_S - hat_S * hat_h))#, # Pseudo-data for linear model
              # Q = solve( t(A) %*% ImM %*% A, t(A) %*% ImM,
              #            method = "svd") # Combine with new pseudo data
              # to obtain new fixed coeffs
              )
  return( out)
}

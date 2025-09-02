build_linear_transformation <- function(age, health, data_sites, eval_sites) {
  last <- data_sites[length(data_sites)]
  n <- length(eval_sites)
  
  # Calculate FRA and A based on health
  FRA <- if (health == 0) 0.76 else if (health == 1) 0.78 else 0.78
  A <- if (health == 0) 0.140 else if (health == 1) 0.152 else 0.153
  
  # Calculate intermediate variables
  B <- 0.69315 / (0.14 * age + 29.16)
  k2 <- FRA * B + (1 - FRA) * A
  k3 <- A * B / k2
  k1 <- A + B - k2 - k3
  
  # Create the ODE matrix and perform eigen decomposition
  odeMat <- rbind(c(-(k1 + k3), k2), c(k1, -k2))
  spec <- eigen(odeMat, symmetric = FALSE)
  L <- spec$values
  U <- spec$vectors
  
  # Initialize the linear transformation matrix W
  W <- matrix(0, n, n)
  
  # Compute values for W using nested loops
  for (i in 1:n) {
    for (j in 1:i) {
      W[i, j] <- (U[1, 2] * U[2, 1] * exp(L[2] * last * (i - j) / n) -
                    U[1, 1] * U[2, 2] * exp(L[1] * last * (i - j) / n))
    }
  }
  
  # Finalize the linear transformation matrix W
  W <- -last * W / n / det(U)
  diag(W) <- last / 2 / n
  
  # Match data_sites to eval_sites and return the result
  ind <- match(data_sites, eval_sites)
  ind <- ind[!is.na(ind)]
  W <- W[ind,]
  
  return(list( matrix = W, k3 = k3))
}

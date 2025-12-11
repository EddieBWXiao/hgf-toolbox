# script to be called from MATLAB; wraps around dwiener
args <- commandArgs(trailingOnly=TRUE)
alpha <- if (length(args) >= 1) as.numeric(args[1]) else 1
tau   <- if (length(args) >= 2) as.numeric(args[2]) else 0.1
beta  <- if (length(args) >= 3) as.numeric(args[3]) else 0.5
delta <- if (length(args) >= 4) as.numeric(args[4]) else 1
output_file <- if (length(args) >= 5) args[5] else 'check_RWiener_log_p.csv'

library(RWiener)

df <- data.frame(rt = seq(from = (tau + 1e-6), to = 10, length.out = 1000))
df$p_upper <- NA
df$p_lower <- NA
for (i in seq_len(nrow(df))) {
  rt_i <- df$rt[i]
  df$p_upper[i] <- dwiener(rt_i, alpha=alpha, tau=tau, beta=beta, delta=delta, resp="upper")
  df$p_lower[i] <- dwiener(rt_i, alpha=alpha, tau=tau, beta=beta, delta=delta, resp="lower")
}
write.csv(df, output_file, row.names = FALSE)

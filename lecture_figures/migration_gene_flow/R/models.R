# Deterministic gene-flow models used in BB512 Lecture 12 (Neal 2004, Chapter 9).
# All models are deterministic: no drift, no mutation. Generation indices include t = 0.

# Continent–island model (Neal Eqn 9.1 and 9.2).
# q_t = (1 - m) q_{t-1} + m q_m  =>  q_t - q_m = (1 - m)^t (q_0 - q_m)
continent_island <- function(q0, qm, m, generations) {
  t <- 0:generations
  data.frame(generation = t, q = qm + (1 - m)^t * (q0 - qm))
}

# Generations needed to reach q_t (rearranged Eqn 9.2).
generations_to <- function(q0, qm, m, qt) {
  log((qt - qm) / (q0 - qm)) / log(1 - m)
}

# Island model with n equal-sized populations (Neal Appendix 9.1).
# Each population receives a proportion m of immigrants whose allele frequency
# is the mean of the OTHER populations in the previous generation.
island_model <- function(q0, m, generations) {
  n <- length(q0)
  out <- matrix(NA_real_, generations + 1L, n)
  out[1, ] <- q0
  for (t in seq_len(generations)) {
    q <- out[t, ]
    qm <- (sum(q) - q) / (n - 1)
    out[t + 1, ] <- (1 - m) * q + m * qm
  }
  data.frame(generation = rep(0:generations, n),
             population = factor(rep(seq_len(n), each = generations + 1L)),
             q = as.vector(out))
}

# Migration–selection balance on an island (Neal Exp. 9.10–9.11).
# Mainland is fixed for the wing allele (q_m = 1). On the island, winged
# homozygotes (wing allele recessive) have fitness 1 - s; others 1.
# Life cycle: selection, then immigration, census after immigration.
# Allele loss by selection: s p q^2 / (1 - s q^2); gain by immigration:
# m (1 - q'), where q' is the frequency after selection. Because
# 1 - q' = p / (1 - s q^2), the balance reduces exactly to s q^2 = m, so
# q_hat = sqrt(m / s) (Neal Exp. 9.11 is exact for this census point; Neal
# reaches it by approximation, using m(1 - q) instead of m(1 - q')).
# If the census were taken after selection instead, the equilibrium is
# (sqrt(m / s) - m) / (1 - m) (0.59 rather than 0.63 at m = 0.1, s = 0.25).
# sqrt(m / (s (1 + m))) is the root of Neal's unsimplified Exp. 9.10 (0.60 at m = 0.1).
migsel <- function(m, s) sqrt(m / s)
migsel_post_selection <- function(m, s) (sqrt(m / s) - m) / (1 - m)

# Iterate the life cycle (selection, then immigration) as a numerical check.
migsel_iterate <- function(m, s, q0 = 0, generations = 5000) {
  q <- q0
  for (t in seq_len(generations)) {
    q <- q * (1 - s * q) / (1 - s * q^2)  # selection against recessive homozygote
    q <- (1 - m) * q + m * 1              # immigration from mainland (q_m = 1)
  }
  q
}

# Linear stepping-stone model (Neal Exp. 9.13 and Appendix 9.2).
# n populations; end populations held fixed by selection; m_between[i] is the
# symmetric migration rate between populations i and i + 1.
stepping_stone <- function(q_ends = c(0.9, 0.1), n = 9, m_between = rep(0.2, n - 1),
                           q_start = 0.5, generations = 20000) {
  q <- c(q_ends[1], rep(q_start, n - 2), q_ends[2])
  for (t in seq_len(generations)) {
    new <- q
    for (i in 2:(n - 1)) {
      ml <- m_between[i - 1]
      mr <- m_between[i]
      new[i] <- (1 - (ml + mr)) * q[i] + ml * q[i - 1] + mr * q[i + 1]
    }
    q <- new
  }
  q
}

# Wright's island-model approximation at drift–migration equilibrium.
fst_from_nm <- function(Nm) 1 / (4 * Nm + 1)
nm_from_fst <- function(Fst) (1 / Fst - 1) / 4

# Deterministic single-locus selection models used in the BB512 lecture
# "Haploid and zygotic selection" (Neal 2004, Chapter 10).
# Assumptions throughout: infinite population (no drift), no mutation,
# no migration, constant fitnesses, non-overlapping generations,
# random mating (diploid models), selection on viability only.
# q is ALWAYS the frequency of the allele/genotype that is selected against
# (Neal's convention), except in Case E where both homozygotes are selected against.

# Haploid (or clonal) selection: genotypes A (fitness 1) and B (fitness 1 - s).
haploid_step <- function(q, s) q * (1 - s) / (1 - s * q)          # Exp. 10.1
haploid_dq   <- function(q, s) -s * q * (1 - q) / (1 - s * q)      # Eqn 10.1
haploid_qt   <- function(q0, s, t) q0 / (q0 + (1 - q0) * (1 - s)^(-t))  # Eqn 10.2

# Zygotic (diploid) selection with genotype fitnesses wAA (A1A1), wAa (A1A2), waa (A2A2).
# q = frequency of A2. Genotypes enter selection in Hardy-Weinberg proportions.
zygotic_step <- function(q, wAA, wAa, waa) {
  p <- 1 - q
  wbar <- p^2 * wAA + 2 * p * q * wAa + q^2 * waa
  (q^2 * waa + p * q * wAa) / wbar
}

# Neal's four cases of dominance (Table 10.3), selection against A2.
case_fitness <- function(case, s = 0.1, s1 = 0.2, s2 = 0.3) {
  switch(case,
    B = c(1, 1 - s / 2, 1 - s),   # no dominance
    C = c(1, 1, 1 - s),           # complete dominance, selection against recessive
    D = c(1, 1 - s, 1 - s),       # complete dominance, selection against dominant
    E = c(1 - s1, 1, 1 - s2),     # heterozygote superiority
    stop("case must be B, C, D or E"))
}

zygotic_dq <- function(q, case, ...) {
  w <- case_fitness(case, ...)
  zygotic_step(q, w[1], w[2], w[3]) - q
}

iterate <- function(q0, generations, FUN, ...) {
  q <- numeric(generations + 1L); q[1] <- q0
  for (t in seq_len(generations)) q[t + 1L] <- FUN(q[t], ...)
  q
}

# Number of generations needed to go from q0 down to (or below) qt.
generations_to <- function(q0, qt, FUN, ..., max_gen = 1e7) {
  q <- q0; t <- 0
  while (q > qt && t < max_gen) { q <- FUN(q, ...); t <- t + 1 }
  t
}

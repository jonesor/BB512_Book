# Population-genetic simulation helpers. All generation indices include t = 0.

# Wright–Fisher sampling of a diallelic diploid locus.
# wAA = 1+s, wAa = 1+s/2, waa = 1 for an additive favourable A allele.
# If s=0, this is neutral drift. Mutation and migration are absent.
simulate_wf <- function(N, generations, replicates = 1L, p0 = 0.5,
                        s = 0) {
  stopifnot(N >= 2, generations >= 1, replicates >= 1,
            p0 >= 0, p0 <= 1, s >= 0)
  trajectories <- matrix(NA_real_, nrow = generations + 1L,
                         ncol = replicates)
  trajectories[1L, ] <- p0
  for (t in seq_len(generations)) {
    p <- trajectories[t, ]
    if (s > 0) {
      wAA <- 1 + s
      wAa <- 1 + s / 2
      waa <- 1
      wbar <- p^2 * wAA + 2 * p * (1 - p) * wAa + (1 - p)^2 * waa
      p <- (p^2 * wAA + p * (1 - p) * wAa) / wbar
    }
    trajectories[t + 1L, ] <- stats::rbinom(replicates, size = 2L * N, prob = p) / (2 * N)
  }
  data.frame(
    generation = rep(0:generations, times = replicates),
    replicate = factor(rep(seq_len(replicates), each = generations + 1L)),
    frequency = as.vector(trajectories)
  )
}

# Two-allele viability selection. q is the frequency of allele S.
# Genotypes AA, AS, SS have relative fitnesses wAA, wAS, wSS.
viability_step <- function(q, wAA, wAS, wSS) {
  p <- 1 - q
  wbar <- p^2 * wAA + 2 * p * q * wAS + q^2 * wSS
  (q^2 * wSS + p * q * wAS) / wbar
}

# Luria–Delbrück-inspired fluctuation simulation.
# Cultures begin from one sensitive cell and grow by binary fission.
# For division round g there are 2^(g-1) divisions. A rare mutation
# in one daughter lineage leaves 2^(G-g) resistant descendants at round G.
# Mutational events are assumed sufficiently rare that overlapping lineages
# can be ignored. This is a stylised instructional model, not a likelihood
# implementation of the full Luria–Delbrück distribution.
simulate_fluctuation <- function(cultures = 250L, doublings = 16L,
                                 mu = 2e-5) {
  stopifnot(cultures >= 1, doublings >= 2, mu >= 0, mu <= 1)
  counts <- numeric(cultures)
  for (g in seq_len(doublings)) {
    events <- stats::rbinom(cultures, size = 2^(g - 1), prob = mu)
    counts <- counts + events * 2^(doublings - g)
  }
  expected <- doublings * 2^(doublings - 1) * mu
  list(before_exposure = counts, expectation = expected)
}

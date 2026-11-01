# Coevolution models used for the BB512 lecture figures.
# All are deterministic, illustrative models (not fitted to data).

# Matching-alleles model of host-parasite coevolution (haploid, two alleles each).
# Parasite allele Pi can infect only host allele Hi.
#   Host fitness:     W(H1) = 1 - sh * p,      W(H2) = 1 - sh * (1 - p)
#   Parasite fitness: W(P1) = 1 - sp + sp * h, W(P2) = 1 - sp + sp * (1 - h)
# h = frequency of H1, p = frequency of P1. Symmetric mutation (rate mu) after
# selection stops the cycles drifting to fixation. Infinite populations (no
# drift), discrete non-overlapping generations, one generation of each species
# per time step.
sim_matching_alleles <- function(gens = 150, sh = 0.3, sp = 0.6, mu = 0.005,
                                 h0 = 0.7, p0 = 0.5) {
  h <- p <- numeric(gens)
  h[1] <- h0; p[1] <- p0
  for (t in seq_len(gens - 1)) {
    wh1 <- 1 - sh * p[t];        wh2 <- 1 - sh * (1 - p[t])
    wp1 <- 1 - sp + sp * h[t];   wp2 <- 1 - sp + sp * (1 - h[t])
    hn <- h[t] * wh1 / (h[t] * wh1 + (1 - h[t]) * wh2)
    pn <- p[t] * wp1 / (p[t] * wp1 + (1 - p[t]) * wp2)
    h[t + 1] <- hn * (1 - mu) + (1 - hn) * mu
    p[t + 1] <- pn * (1 - mu) + (1 - pn) * mu
  }
  data.frame(generation = seq_len(gens) - 1, host = h, parasite = p)
}

# Escalation (arms race) between a prey defence D and a predator offence A.
# Each trait is selected to exceed the other (by margins lead_prey and
# lead_pred) and pays a small cost proportional to its size:
#   dD = G * ((A + lead_prey - D) - cost * D);  dA = G * ((D + lead_pred - A) - cost * A)
# lead_prey > lead_pred mimics the life-dinner principle (stronger selection on
# prey), so prey stay slightly ahead.
# Arbitrary units; shows the qualitative pattern only.
sim_escalation <- function(gens = 300, G = 0.05, lead_prey = 3, lead_pred = 0, cost = 0.01,
                           D0 = 1, A0 = 0) {
  D <- A <- numeric(gens)
  D[1] <- D0; A[1] <- A0
  for (t in seq_len(gens - 1)) {
    D[t + 1] <- D[t] + G * ((A[t] + lead_prey - D[t]) - cost * D[t])
    A[t + 1] <- A[t] + G * ((D[t] + lead_pred - A[t]) - cost * A[t])
  }
  data.frame(generation = seq_len(gens) - 1, prey = D, predator = A)
}

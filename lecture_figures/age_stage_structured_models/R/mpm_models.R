# Matrices used in the lecture "Age and stage-structured models".
# One place for every matrix, so the figures, the number checks and the slides agree.
# Matrices are column = stage at time t (FROM), row = stage at time t+1 (TO).

# ---- Age-based (Leslie) model, post-breeding census --------------------------
# Life table (Neal 2004 style; same numbers as the previous version of the lecture)
life_table <- data.frame(
  x  = 0:4,                         # age at start of interval
  Sx = c(500, 400, 200, 50, 0),     # females alive at age x
  mx = c(0, 2, 3, 1, 0)             # female offspring per female of age x
)
life_table$lx <- life_table$Sx / life_table$Sx[1]                    # survivorship
life_table$px <- c(life_table$lx[-1] / life_table$lx[-nrow(life_table)], NA)  # p(x) = l(x+1)/l(x)

# Post-breeding census: an individual counted at age x adds offspring to the
# next census only if it survives the year, p(x), and then breeds, m(x+1).
# F(x) = p(x) * m(x+1)   (Neal 2004 Eqn 15.8: F_i = m_i P_i, with class i = ages i-1 to i)
# Notation as in Neal and lecture 05 (Gotelli calls these g(x) and b(x)).
ages <- 0:3
p_x <- life_table$px[1:4]                     # 0.80, 0.50, 0.25, 0.00
Fx <- p_x * life_table$mx[2:5]                # 1.60, 1.50, 0.25, 0.00
A_leslie <- matrix(0, 4, 4, dimnames = list(paste("Age", ages), paste("Age", ages)))
A_leslie[1, ] <- Fx
A_leslie[cbind(2:4, 1:3)] <- p_x[1:3]

# The version in the previous lecture (raw m(x) in the top row): kept only to
# show in the notes how much the mistake changes lambda.
A_leslie_wrong <- A_leslie
A_leslie_wrong[1, ] <- life_table$mx[1:4]     # 0, 2, 3, 1

# ---- Simple stage-based model (juvenile, adult, post-reproductive) -----------
# (Called "senescent" in the previous version; renamed because the practical's
# example has a "senescent" stage that still reproduces.)
A_jas <- matrix(c(0.14, 4.55, 0.00,
                  0.26, 0.32, 0.00,
                  0.00, 0.12, 0.18),
                nrow = 3, byrow = TRUE,
                dimnames = list(c("Juvenile", "Adult", "Post-reproductive"),
                                c("Juvenile", "Adult", "Post-reproductive")))
n0_jas <- c(Juvenile = 100, Adult = 50, "Post-reproductive" = 20)

# ---- Killer whale (Orcinus orca), resident populations, British Columbia & Washington ----
# Brault & Caswell (1993) Ecology 74: 1444-1454, Eqn 2: all pods combined, females only,
# photo-identification data 1973-1987 (Bigg et al. 1990). Also Caswell (2001) Example 5.1
# and popbio::whale. Published lambda = 1.0254.
whale_stages <- c("Yearling", "Juvenile", "Mature", "Post-reproductive")
A_whale <- matrix(c(0,      0.0043, 0.1132, 0,
                    0.9775, 0.9111, 0,      0,
                    0,      0.0736, 0.9534, 0,
                    0,      0,      0.0452, 0.9804),
                  nrow = 4, byrow = TRUE, dimnames = list(whale_stages, whale_stages))
F_whale <- A_whale * 0; F_whale[1, 2:3] <- A_whale[1, 2:3]        # fertility elements

# ---- Red fox (Vulpes vulpes), Bristol, UK ---------------------------------------------
# Devenish-Nelson, Harris, Soulsbury, Richards & Stephens (2013) Oikos 122: 705-716,
# mean matrix for the Bristol population, females, age classes 0+, 1+, 2+, 3+
# (as stored in COMADRE; values to 2 decimal places as published there).
fox_stages <- c("Age 0", "Age 1", "Age 2", "Age 3+")
A_fox <- matrix(c(0.55, 0.77, 0.71, 0.74,
                  0.48, 0,    0,    0,
                  0,    0.54, 0,    0,
                  0,    0,    0.53, 0.51),
                nrow = 4, byrow = TRUE, dimnames = list(fox_stages, fox_stages))
F_fox <- A_fox * 0; F_fox[1, ] <- A_fox[1, ]

# ---- Loggerhead turtle (Caretta caretta): Crouse, Crowder & Caswell (1987) ---
# Ecology 68: 1412-1423, Table 4 (stage-classified model from Frazer's life table).
crouse_stages <- c("Eggs & hatchlings", "Small juveniles", "Large juveniles",
                   "Subadults", "Novice breeders", "1st-yr remigrants", "Mature breeders")
crouse_P <- c(0, 0.7370, 0.6611, 0.6907, 0, 0, 0.8091)          # stay in stage
crouse_G <- c(0.6747, 0.0486, 0.0147, 0.0518, 0.8091, 0.8091)   # grow to next stage
crouse_F <- c(0, 0, 0, 0, 127, 4, 80)                           # eggs per individual
crouse_matrix <- function(P = crouse_P, G = crouse_G, F = crouse_F) {
  k <- length(P)
  A <- diag(P)
  A[cbind(2:k, 1:(k - 1))] <- G
  A[1, ] <- A[1, ] + F
  dimnames(A) <- list(crouse_stages, crouse_stages)
  A
}
A_crouse <- crouse_matrix()

# ---- Analysis helpers (base R; same results as popdemo::eigs / elas) ---------
mpm_lambda <- function(A) max(Re(eigen(A)$values))
mpm_ssd <- function(A) {
  e <- eigen(A); w <- abs(Re(e$vectors[, which.max(Re(e$values))]))
  setNames(w / sum(w), colnames(A))
}
mpm_rv <- function(A) {
  e <- eigen(t(A)); v <- abs(Re(e$vectors[, which.max(Re(e$values))]))
  setNames(v / v[1], colnames(A))
}
mpm_sens <- function(A) {
  w <- mpm_ssd(A); v <- mpm_rv(A)
  S <- outer(v, w) / sum(v * w)
  dimnames(S) <- dimnames(A); S
}
mpm_elas <- function(A) mpm_sens(A) * A / mpm_lambda(A)
mpm_project <- function(A, n0, years) {
  out <- matrix(NA_real_, years + 1, length(n0), dimnames = list(NULL, colnames(A)))
  out[1, ] <- n0
  for (t in seq_len(years)) out[t + 1, ] <- A %*% out[t, ]
  data.frame(year = 0:years, out, check.names = FALSE)
}

# In silico experiments follow Crouse et al. (1987): each stage has an annual
# survival (sigma) and a duration in years (d); stay (P) and grow (G) are
# recalculated from them (Crouse et al. 1987, Eqns 1-2; Caswell 2001):
#   P = sigma (1 - sigma^(d-1)) / (1 - sigma^d),   G = sigma^d (1 - sigma) / (1 - sigma^d)
# One-year stages (d = 1) have P = 0, G = sigma; the final (mature) stage has P = sigma.
# With the published sigma and d this reproduces crouse_P and crouse_G to 4 decimals.
crouse_sigma <- c(0.6747, 0.7857, 0.6758, 0.7425, 0.8091, 0.8091, 0.8091)
crouse_d     <- c(1, 7, 8, 6, 1, 1, 32)
crouse_from_survival <- function(sigma = crouse_sigma, d = crouse_d, F = crouse_F) {
  k <- length(sigma)
  P <- ifelse(d == 1, 0, sigma * (1 - sigma^(d - 1)) / (1 - sigma^d))
  G <- ifelse(d == 1, sigma, sigma^d * (1 - sigma) / (1 - sigma^d))
  P[k] <- sigma[k]                     # mature breeders stay mature
  crouse_matrix(P, G[-k], F)
}

# Halve the annual mortality of one stage: 1 - sigma -> (1 - sigma) / 2
crouse_halve_mortality <- function(stage) {
  sigma <- crouse_sigma
  sigma[stage] <- 1 - (1 - sigma[stage]) / 2
  crouse_from_survival(sigma)
}

# Fertility elements of the loggerhead matrix (for splitting elasticities by type)
F_crouse <- A_crouse * 0; F_crouse[1, ] <- crouse_F

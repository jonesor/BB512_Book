# 00_check_numbers.R
# Arithmetic check for every number used on the slides, in the speaker notes,
# and in the practical "Life tables and survivorship types". Makes no figure.
# Analytical. Life table: the hypothetical cohort used throughout the lecture
# (500 newborn females, maximum age 3); one-year age classes; birth-pulse
# population censused just after breeding (as in Neal's Uinta ground squirrel
# example).

# ---- Hypothetical cohort (slides "Building a cohort life table") ----------
x  <- 0:4
Sx <- c(500, 400, 200, 50, 0)       # number alive at the start of age x
mx <- c(0, 2, 3, 1, 0)              # female offspring per female aged x

Dx <- Sx - c(Sx[-1], NA)            # number dying in interval x to x + 1
lx <- Sx / Sx[1]                    # survivorship: P(survive from birth to x)
dx <- lx - c(lx[-1], NA)            # fraction of the cohort dying in interval
qx <- dx / lx                       # probability of dying in interval
px <- 1 - qx                        # probability of surviving the interval
# Life expectancy: (sum of l from x onwards) / lx, minus half an interval
ex <- sapply(seq_along(x), function(i) sum(lx[i:length(lx)]) / lx[i] - 0.5)
ex[lx == 0] <- NA

tab <- data.frame(x, Sx, Dx, lx, dx, qx, px, ex, mx,
                  lxmx = lx * mx, xlxmx = x * lx * mx)
print(tab, digits = 4)

R0 <- sum(lx * mx)                  # net reproductive rate
T  <- sum(x * lx * mx) / R0         # generation time (cohort)
rc <- log(R0) / T                   # Neal's capacity for increase (approximation)
euler <- function(r) sum(exp(-r * x) * lx * mx) - 1
rm <- uniroot(euler, c(-1, 5), tol = 1e-10)$root  # Euler-Lotka (exact)

cat(sprintf("\nR0 = %.2f\nsum x lx mx = %.2f\nT = %.3f years\n", R0, sum(x * lx * mx), T))
cat(sprintf("r approx = ln(R0)/T = %.3f per year, lambda approx = %.3f\n", rc, exp(rc)))
cat(sprintf("r exact (Euler-Lotka) = %.3f per year, lambda = %.3f\n", rm, exp(rm)))
cat(sprintf("Euler-Lotka sum at r approx: %.3f (should be 1 at the exact r)\n\n", euler(rc) + 1))

# Leslie matrix (post-breeding census) from the same table: next lecture.
# Classes are ages 0, 1, 2 at the census; P_i = l_i / l_(i-1); F_i = m_i P_i (Neal)
P <- lx[2:4] / lx[1:3]              # 0.8, 0.5, 0.25
F <- mx[2:4] * P                    # 1.6, 1.5, 0.25
A <- matrix(c(F[1], F[2], F[3],
              P[1], 0,    0,
              0,    P[2], 0), 3, 3, byrow = TRUE)
cat(sprintf("Leslie matrix lambda (check, next lecture) = %.3f\n\n",
            max(Re(eigen(A)$values))))

# ---- Probability versus rate (slides "Probability is bounded") -------------
mu <- c(0.1, 0.5, 1, 2, 5, 10)
print(data.frame(mu, q = round(1 - exp(-mu), 3)))
cat(sprintf("q = 0.5 -> mu = %.2f; q = 0.9 -> mu = %.2f; q = 0.99 -> mu = %.2f\n\n",
            -log(0.5), -log(0.1), -log(0.01)))

# ---- Same R0, different generation time (slide "R0 is per generation") -----
for (TT in c(1, 2)) cat(sprintf("R0 = 2, T = %g: r = %.3f per year, lambda = %.3f, N(10)/N(0) = %.0f\n",
                                TT, log(2) / TT, exp(log(2) / TT), 2^(10 / TT)))
# Mouse versus elephant (speaker notes): same R0 = 2
for (TT in c(0.5, 25)) cat(sprintf("R0 = 2, T = %g years: r = %.3f per year, lambda = %.3f\n",
                                   TT, log(2) / TT, exp(log(2) / TT)))

# ---- Dall sheep (Neal's life table from Deevey 1947; Murie's 608 skulls) ----
Dx_dall <- c(121, 7, 8, 7, 18, 28, 29, 42, 80, 114, 95, 55, 2, 2)
Sx_dall <- rev(cumsum(rev(Dx_dall)))
lx_dall <- Sx_dall / Sx_dall[1]
qx_dall <- Dx_dall / Sx_dall
cat("\nDall sheep: Sx =", Sx_dall, "\n")
cat("lx =", round(lx_dall, 3), "\n")
cat("qx =", round(qx_dall, 3), "\n")
cat(sprintf("Minimum qx = %.3f at age %d\n", min(qx_dall), which.min(qx_dall) - 1))

# ---- Uinta ground squirrel (Neal's table from Slade & Balph 1974) -----------
uinta <- list(
  before = data.frame(x = c(0, 0.75, 1.75, 2.75, 3.75), lx = c(1, 0.292, 0.128, 0.041, 0.013),
                      mx = c(0, 1.96, 2.73, 2.73, 2.73)),
  after  = data.frame(x = c(0, 0.75, 1.75, 2.75, 3.75, 4.75, 5.75),
                      lx = c(1, 0.359, 0.190, 0.089, 0.041, 0.019, 0.009),
                      mx = c(0, 1.75, 2.76, 2.76, 2.76, 2.76, 2.76)))
for (k in names(uinta)) with(uinta[[k]], {
  R0 <- sum(lx * mx); T <- sum(x * lx * mx) / R0; rc <- log(R0) / T
  cat(sprintf("Uinta %s: R0 = %.3f, T = %.3f, r_c = %.3f, lambda = %.3f\n", k, R0, T, rc, exp(rc)))
})

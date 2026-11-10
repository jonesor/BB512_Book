# Prints every number used on the slides and in the speaker notes.
source("R/theme_bb512.R"); source("R/pp_model.R")
cat("Equilibrium H* = d/c =", 0.1 / 0.00008, " P* = r/a =", 0.25 / 0.01, "\n")
cat("Small-cycle period 2*pi/sqrt(rd) =", round(2 * pi / sqrt(0.25 * 0.1), 1), "\n")
cat("Growth factor per step near equilibrium, dt = 1:", round(sqrt(1 + 0.25 * 0.1), 4), "\n")
s <- pp_sim(dt = 1, total = 300)
cat("dt = 1: t = 1", s$H[2], s$P[2], "; t = 2", s$H[3], round(s$P[3], 3), "; prey zero at", pp_first_zero(s), "\n")
pk <- function(x, t) t[which(diff(sign(diff(x))) == -2) + 1]
cat("dt = 1 prey peaks", head(pk(s$H, s$t), 4), " predator peaks", head(pk(s$P, s$t), 4), "\n")
for (dt in c(0.5, 0.1)) {
  s <- pp_sim(dt = dt, total = 300)
  cat("dt =", dt, ": prey zero at", pp_first_zero(s), "; prey range", round(range(s$H)), "\n")
}
s <- pp_sim(dt = 0.1, total = 300)
cat("dt = 0.1 prey peaks", round(head(pk(s$H, s$t), 4), 1), " predator peaks", round(head(pk(s$P, s$t), 4), 1), "\n")
for (K in c(1000, 2000, 5000, 10000)) {
  s <- pp_sim(K = K, dt = 1, total = 300)
  cat("K =", K, ": end", round(tail(s$H, 1), 1), round(tail(s$P, 1), 3),
      " P* =", if (K > 1250) (0.25 / 0.01) * (1 - 1250 / K) else 0, "\n")
}
for (Hr in c(0, 50, 100, 200, 400)) {
  s <- pp_sim(Hr = Hr, dt = 1, total = 300)
  last <- s[s$t >= 200, ]
  cat("Hr =", Hr, ": prey zero at", pp_first_zero(s), "; last 100: H", round(range(last$H)),
      " P", round(range(last$P), 1), "; equilibrium H* =", Hr + 1250,
      " P* =", round(0.25 * (Hr + 1250) / (0.01 * 1250), 2), "\n")
}
cat("Volterra (r = 0.2, d = 0.12): H* =", 0.12 / 0.00008, " P* =", 0.2 / 0.01, "\n")

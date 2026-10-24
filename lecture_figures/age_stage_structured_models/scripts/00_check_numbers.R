# Prints every number used on the slides and in the speaker notes. Makes no figure.
# Analytical: eigen-analysis of the lecture's matrices (base R; same as popdemo).
source("R/theme_bb512.R"); source("R/mpm_models.R")
r3 <- function(x) round(x, 3)
cat("\n== Life table ==\n"); print(life_table)
cat("\n== Leslie matrix (post-breeding, F = p(x) m(x+1)) ==\n"); print(A_leslie)
cat("lambda (correct)        =", r3(mpm_lambda(A_leslie)), "\n")
cat("lambda (raw m(x), wrong) =", r3(mpm_lambda(A_leslie_wrong)), "\n")
cat("SSD:", r3(mpm_ssd(A_leslie)), "\n")
# Same answer as the Euler-Lotka equation in the life-tables lecture (lecture 05)
x <- life_table$x; lm <- life_table$lx * life_table$mx
r_el <- uniroot(function(r) sum(exp(-r * x) * lm) - 1, c(-1, 5), tol = 1e-10)$root
cat("Euler-Lotka r =", r3(r_el), " exp(r) =", r3(exp(r_el)), "\n")
# Generation time, three definitions (slide "Generation time: three answers for one cohort")
R0 <- sum(lm); lamL <- mpm_lambda(A_leslie)
cat("R0 =", R0, " cohort T =", r3(sum(x * lm) / R0), " ln R0 / ln lambda =", r3(log(R0) / log(lamL)),
    " mean age of mothers (stable) =", r3(sum(x * lamL^-x * lm)), "\n")
gen_T <- function(A, Fm) { N <- solve(diag(nrow(A)) - (A - Fm)); R0 <- max(Re(eigen(Fm %*% N)$values))
  c(R0 = R0, T = log(R0) / log(mpm_lambda(A))) }

cat("\n== Juvenile / adult / post-reproductive ==\n"); print(A_jas)
cat("n0 =", n0_jas, " A n0 =", A_jas %*% n0_jas, "\n")
cat("lambda =", r3(mpm_lambda(A_jas)), " SSD:", r3(mpm_ssd(A_jas)), "\n")
cat("Reproductive value:", r3(mpm_rv(A_jas)), "\n"); print(r3(mpm_elas(A_jas)))
cat("Survival by stage (column sums excluding fertility):",
    colSums(A_jas[-1, , drop = FALSE]) + c(A_jas[1, 1], 0, 0), "\n")

cat("\n== Killer whale (Brault & Caswell 1993) ==\n"); print(A_whale)
cat("Survival by stage:", colSums(A_whale - F_whale), "\n")
cat("lambda =", round(mpm_lambda(A_whale), 4), " (published 1.0254)\n")
ev <- sort(Mod(eigen(A_whale)$values), decreasing = TRUE); cat("damping ratio =", r3(ev[1] / ev[2]), "\n")
cat("SSD (%):", round(100 * mpm_ssd(A_whale), 1), "\n")
cat("Reproductive value:", r3(mpm_rv(A_whale)), "\n")
cat("Elasticities:\n"); print(r3(mpm_elas(A_whale)))
for (n0 in list(c(100, 0, 0, 0), c(25, 25, 25, 25))) {
  pr <- mpm_project(A_whale, n0, 60); tot <- rowSums(pr[, -1]); w <- mpm_ssd(A_whale)
  dist <- apply(pr[, -1], 1, function(n) 0.5 * sum(abs(n / sum(n) - w)))
  cat("start", n0, ": totals", round(tot[c(1, 2, 3, 6, 11, 21, 61)], 1),
      " first year within 5% of SSD =", which(dist < 0.05)[1] - 1, "\n")
}

cat("\n== Red fox, Bristol (Devenish-Nelson et al. 2013) ==\n"); print(A_fox)
cat("lambda =", r3(mpm_lambda(A_fox)), " SSD (%):", round(100 * mpm_ssd(A_fox), 1), "\n")
ev <- sort(Mod(eigen(A_fox)$values), decreasing = TRUE); cat("damping ratio =", r3(ev[1] / ev[2]), "\n")
cat("Elasticities (2 dp, slide):\n"); print(round(unname(mpm_elas(A_fox)), 2))
cat("Fecundity share:", r3(sum(mpm_elas(A_fox)[F_fox > 0])), "\n")
cat("R0 and T = ln R0 / ln lambda: fox", round(gen_T(A_fox, F_fox), 2), "; loggerhead", round(gen_T(A_crouse, F_crouse), 2),
    "; whale", round(gen_T(A_whale, F_whale), 2), "\n")
for (sp in list(list("fox", A_fox, F_fox, 2:4), list("loggerhead", A_crouse, F_crouse, 5:7),
                list("whale", A_whale, F_whale, 3:4))) {
  E <- mpm_elas(sp[[2]]); Es <- E * (sp[[3]] == 0)
  cat(sprintf("%-10s reproduction %.2f  survival before breeding %.2f  survival of breeders %.2f\n",
              sp[[1]], sum(E[sp[[3]] > 0]), sum(Es[, -sp[[4]]]), sum(Es[, sp[[4]]])))
}

cat("\n== Sensitivity / elasticity worked example in the notes (hypothetical) ==\n")
cat("s_juv = 0.005/0.01 =", 0.005 / 0.01, "; s_adult = 0.010/0.01 =", 0.010 / 0.01, "\n")
cat("e = s * a / lambda: juv", 0.5 * 0.20 / 1, " adult", 1.0 * 0.80 / 1, "\n")

cat("\n== Loggerhead, Crouse et al. 1987 ==\n"); print(round(A_crouse, 4))
lam0 <- mpm_lambda(A_crouse); cat("lambda =", round(lam0, 4), " r = ln(lambda) =", round(log(lam0), 4), "\n")
E <- mpm_elas(A_crouse)
cat("Elasticity matrix (2 dp, slide):\n"); print(round(unname(E), 2))
cat("Elements >= 0.10 together:", r3(sum(E[E >= 0.1])), "\n")
cat("Elasticity, stay:", r3(diag(E)), "\n")
cat("Elasticity, grow:", r3(E[cbind(2:7, 1:6)]), "\n")
cat("Elasticity, fecundity:", r3(E[1, ]), "\n")
cat("Summed by stage (column):", r3(colSums(E)), "\n")
for (k in 1:7) cat(sprintf("Halve mortality of %-18s lambda = %.3f\n", crouse_stages[k],
                           mpm_lambda(crouse_halve_mortality(k))))
cat("Rebuilt from survival and stage duration, max difference from published matrix:",
    signif(max(abs(crouse_from_survival() - A_crouse)), 2), "\n")
s1 <- crouse_sigma; s1[1] <- 1
cat("100% egg/hatchling survival: lambda =", r3(mpm_lambda(crouse_from_survival(s1))), "\n")

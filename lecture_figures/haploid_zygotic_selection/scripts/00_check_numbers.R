# Checks every number shown on the slides. Run: Rscript scripts/00_check_numbers.R
source("R/models.R")
cat("--- 1 Defining fitness: lambda 1.05 vs 1.15\n")
cat(sprintf("W_A = %.4f, s_A = %.4f\n", 1.05/1.15, 1 - 1.05/1.15))
cat("--- 2 Neal Table 10.1\n"); n0 <- c(50,60,40); n1 <- c(100,90,40); lam <- n1/n0
print(round(rbind(lambda = lam, W = lam/max(lam), s = 1 - lam/max(lam)), 3))
cat("--- 3 Haploid worked example p0 = 0.01, lambdaA = 1.6, lambdaB = 1.2\n")
s <- 1 - 1.2/1.6; q0 <- 0.99
cat(sprintf("s = %.3f, T = %.4f, p1 = %.4f, q1 = %.4f, dq (Eqn 10.1) = %.5f\n",
  s, 0.01 + q0*(1-s), 0.01/(0.01 + q0*(1-s)), haploid_step(q0, s), haploid_dq(q0, s)))
qq <- iterate(q0, 40, haploid_step, s = s)
cat("p_t at t = 5,10,15,20,30:", round(1 - qq[c(6,11,16,21,31)], 3), "\n")
cat("Eqn 10.2 check at t=20:", round(1 - haploid_qt(q0, s, 20), 4), "\n")
cat("--- 4 Diploid no dominance q = 0.4, s = 0.3\n")
q <- 0.4; p <- 0.6; w <- c(1, 0.85, 0.7); g <- c(p^2, 2*p*q, q^2); cg <- g*w
cat("HW:", g, " contrib:", cg, " total:", sum(cg), "\n")
cat("after selection:", round(cg/sum(cg), 4), "\n")
q1 <- zygotic_step(q, 1, 0.85, 0.7)
cat(sprintf("q' = %.4f ; Eqn 10.4 dq = %.4f ; next HW zygotes: %.4f %.4f %.4f\n", q1,
  -0.5*0.3*p*q/(1-0.3*q), (1-q1)^2, 2*q1*(1-q1), q1^2))
cat("--- 4b haploid filter illustration p = 0.5, W_B = 0.75\n")
cat("after:", round(0.5/0.875, 3), round(0.375/0.875, 3), "\n")
cat("--- 5 Peak |dq| for s = 0.1\n")
qs <- seq(0.001, 0.999, by = 0.001)
for (cs in c("B","C","D")) { d <- abs(zygotic_dq(qs, cs, s = 0.1)); cat(cs, "peak at q =", qs[which.max(d)], " max =", round(max(d),4), "\n") }
d <- abs(haploid_dq(qs, 0.1)); cat("haploid peak at q =", qs[which.max(d)], "\n")
cat("--- 6 Crow / Neal Table 10.5, s = 0.01 (generations for favoured allele p)\n")
pairs <- rbind(c(.001,.01), c(.01,.1), c(.1,.25), c(.25,.5), c(.5,.75), c(.75,.9), c(.9,.99), c(.99,.999))
for (i in 1:nrow(pairs)) {
  q0 <- 1 - pairs[i,1]; qt <- 1 - pairs[i,2]
  r <- sapply(c("B","C","D"), function(cs) { w <- case_fitness(cs, s = 0.01); generations_to(q0, qt, zygotic_step, w[1], w[2], w[3]) })
  cat(pairs[i,1], "->", pairs[i,2], ":", r, "\n")
}
cat("--- 6b Big Fact: 0.1% -> 50%, s = 0.01 (cases D, B, C)\n")
for (cs in c("D", "B", "C")) { w <- case_fitness(cs, s = 0.01)
  cat(cs, ": to 1% =", generations_to(0.999, 0.99, zygotic_step, w[1], w[2], w[3]),
      "; to 50% =", generations_to(0.999, 0.5, zygotic_step, w[1], w[2], w[3]), "\n") }
cat("--- 7 Haldane: typica 0.99 -> 0.01 phenotype in 50 generations (Case C)\n")
q0 <- sqrt(0.99); qt <- sqrt(0.01)
s_approx <- ((q0 - qt)/(q0*qt) + log(q0*(1-qt)/(qt*(1-q0)))) / 50
f <- function(s) iterate(q0, 50, zygotic_step, 1, 1, 1 - s)[51] - qt
s_exact <- uniroot(f, c(0.01, 0.99))$root
cat(sprintf("q0 = %.4f qt = %.4f s(Eqn 10.11) = %.4f  s(exact iteration) = %.4f  W_typ = %.3f  1/W = %.3f\n",
  q0, qt, s_approx, s_exact, 1 - s_approx, 1/(1 - s_approx)))
qq <- iterate(q0, 50, zygotic_step, 1, 1, 1 - s_approx)
cat("carbonaria phenotype after 50 gen with approx s:", round(1 - qq[51]^2, 4), "\n")
cat("--- 8 Problem 2a: carbonaria 10% -> 90%, W_typica = 0.67\n")
q0 <- sqrt(0.9); qt <- sqrt(0.1); s <- 0.33
t_approx <- ((q0 - qt)/(q0*qt) + log(q0*(1-qt)/(qt*(1-q0)))) / s
t_exact <- generations_to(q0, qt, zygotic_step, 1, 1, 1 - s)
cat(sprintf("q0 = %.4f qt = %.4f t(Eqn 10.11) = %.1f  t(iteration) = %d\n", q0, qt, t_approx, t_exact))
cat("--- 9 Kettlewell (Neal Table 11.1)\n")
k <- data.frame(site = c("Birmingham","Birmingham","Dorset","Dorset"), morph = c("carbonaria","typica","carbonaria","typica"),
                rel = c(154,64,473,496), rec = c(82,16,30,62))
k$surv <- k$rec/k$rel; print(k)
cat(sprintf("Birmingham W_typ naive %.4f, log-corrected %.4f\n", 0.25/(82/154), log(82/154)/log(16/64)))
cat(sprintf("Dorset W_carb naive %.4f, log-corrected %.4f\n", (30/473)/(62/496), log(62/496)/log(30/473)))
cat("Bishop Sefton Park: W_typ =", round(log(42/56)/log(39/56), 4), "\n")
cat("--- 10 West Kirby (Neal 11.2.1): carbonaria 0.93, 0.84, 0.33 in 1959, 1976, 1990\n")
p <- sqrt(c(0.07, 0.16, 0.67)); q <- 1 - p; print(round(rbind(p, q), 4))
eq1014 <- function(q0, qt, t) ((q0 - qt)/((1-qt)*(1-q0)) + log(q0*(1-qt)/(qt*(1-q0)))) / t
cat("s 1959-76:", round(eq1014(q[1], q[2], 17), 4), " 1976-90:", round(eq1014(q[2], q[3], 14), 4),
    " 1959-90:", round(eq1014(q[1], q[3], 31), 4), "\n")
fD <- function(s, q0, qt, t) iterate(q0, t, zygotic_step, 1, 1 - s, 1 - s)[t + 1] - qt
cat("exact s 1959-90:", round(uniroot(fD, c(0.001, 0.9), q0 = q[1], qt = q[3], t = 31)$root, 4), "\n")
cat("--- 11 Allison (1956) Tanzania\n")
inf <- c(189, 89, 9); ad <- c(400, 249, 5)
fi <- inf/sum(inf); fa <- ad/sum(ad); lam <- fa/fi; W <- lam/max(lam)
print(round(rbind(fi, fa, lam, W), 4))
qS_inf <- (inf[3] + inf[2]/2)/sum(inf); qS_ad <- (ad[3] + ad[2]/2)/sum(ad)
s1 <- 1 - W[1]; s2 <- 1 - W[3]
cat(sprintf("q(S) infants %.4f adults %.4f; s1 = %.4f s2 = %.4f; q_hat = %.4f\n", qS_inf, qS_ad, s1, s2, s1/(s1+s2)))
cat("HW expected infants from q_inf:", round(c((1-qS_inf)^2, 2*qS_inf*(1-qS_inf), qS_inf^2), 4), "\n")
cat("--- 12 Eugenics\n")
q0 <- sqrt(1e-4); qt <- sqrt(0.5e-4)
cat(sprintf("PKU halve incidence: q0 %.4f qt %.6f t = %.1f gen = %.0f yr at 25 yr/gen\n", q0, qt, 1/qt - 1/q0, 25*(1/qt - 1/q0)))
cat("exact iteration (s=1, Case C):", generations_to(q0, qt, zygotic_step, 1, 1, 0), "\n")
cat("Dictator 1e-4 -> 1e-6:", 1/sqrt(1e-6) - 1/sqrt(1e-4), "gens\n")
q <- 0.01; p <- 0.99
cat(sprintf("carriers 2pq = %.4f (1 in %.0f); affected q^2 = %.4f; fraction of alleles in carriers = %.4f\n",
  2*p*q, 1/(2*p*q), q^2, (p*q)/(p*q + q^2)))
cat("--- 13 Achondroplasia (Morch 1941)\n")
W <- (27/108)/(582/457); s <- 1 - W; H <- 10/94075
cat(sprintf("W = %.4f s = %.4f H = %.6f u(indirect) = %.2e u(direct) = %.2e  H if s=1: %.6f\n",
  W, s, H, H*s/2, 8/(2*94075), 2*(H*s/2)))

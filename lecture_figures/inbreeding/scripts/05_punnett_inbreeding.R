# Punnett square with inbreeding: areas are genotype frequencies.
# Rows: allele from one parent (A1 with prob. p, A2 with prob. q).
# Columns: with prob. F the second allele is IBD with the first (autozygous);
# otherwise (prob. 1 - F) it is drawn independently: A1 with p(1-F), A2 with q(1-F).
# Genotype frequencies: A1A1 = p^2(1-F) + pF, A1A2 = 2pq(1-F), A2A2 = q^2(1-F) + qF.
# Allele frequencies are unchanged: p^2(1-F) + pF + pq(1-F) = p.
# Matched baseline and inbreeding diagrams: p = 0.6 in both.
# Both exports have identical canvas sizes, coordinate limits and square sides.
source("R/theme_bb512.R")
source("R/punnett.R")

# Separate files allow the no-inbreeding case to be revealed first on a slide.
no_inbreeding <- punnett_inbreeding(p_val = 0.6, F_val = 0)
with_inbreeding <- punnett_inbreeding(p_val = 0.6, F_val = 0.25)
save_bb512(no_inbreeding, "05_punnett_no_inbreeding", layout = "square")
save_bb512(with_inbreeding, "05_punnett_inbreeding", layout = "square")

# Slide 19: "Inbreeding reshuffles alleles into more homozygotes" (square figure)
# Same model and values as scripts/05_punnett_inbreeding.R (p = 0.6, F = 0.25; areas are
# genotype frequencies), with a legend naming allozygous homozygotes, heterozygotes and
# autozygous (IBD) homozygotes. Analytical, no random draws.
# R version of the diagram previously pasted into the deck.
source("R/theme_bb512.R")
source("R/punnett.R")

save_bb512(punnett_inbreeding(p_val = 0.6, F_val = 0.25, legend = TRUE),
           "05b_punnett_inbreeding_legend", layout = "square")

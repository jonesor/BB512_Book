# Render all figures for BB512 lecture 01 "Darwin and his theories".
# From this folder: source("render_all.R") or LANG=C.UTF-8 Rscript render_all.R
for (f in sort(list.files("scripts", pattern = "\\.R$", full.names = TRUE))) {
  message("Rendering ", f)
  set.seed(512)
  source(f, local = new.env())
}

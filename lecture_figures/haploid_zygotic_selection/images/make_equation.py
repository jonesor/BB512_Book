"""Render Neal's Eqn 10.11 (Case C, selection against the recessive) as a PNG for the slides.
Run from the lecture folder: python3 images/make_equation.py"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
plt.rcParams["mathtext.fontset"] = "stixsans"
INK = "#1F2623"
eq = (r"$s\,t \;=\; \dfrac{q_0 - q_t}{q_0\,q_t} \;+\; "
      r"\ln\!\left[\dfrac{q_0\,(1 - q_t)}{q_t\,(1 - q_0)}\right]$")
fig = plt.figure(figsize=(8, 1.4))
fig.text(0.0, 0.5, eq, fontsize=30, color=INK, va="center", ha="left")
fig.savefig("images/eqn_10_11.png", dpi=300, transparent=True, bbox_inches="tight", pad_inches=0.05)

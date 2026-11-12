---
title: "Milestone 3: First Look at the Data"
subtitle: "Which used cars lose the least money over 5 years?"
author:
  - "Group 2"
  - "Sirawee Wutinarongtrakul (李意如), Teepawin Mueanpetch (趙偉儒), Warunya Kumpunya (邱品寧)"
geometry: margin=2cm
fontsize: 11pt
CJKmainfont: "PingFang TC"
---

# Initial Analysis

We use 35,394 Craigslist listings (April–May 2021) of 28 popular models in four segments. We keep only cars with normal mileage (8,000–16,000 miles per year of age) and model–age groups with at least 20 listings. Code: `R/03_figures.R`.

## Price by Car Age

![Median asking price by car age (log scale). Grey = one model, color = segment median.](figures/fig1_price_by_age.png)

The y-axis is on a log scale, so a straight line means the car loses the same percent of its price every year. For compact cars, midsize cars and SUVs the lines are almost straight. They lose about 11–12% per year at age 2–4 and also at age 5–8.

In dollars it looks different. A compact car loses about \$2,000 per year at age 2–4 but only about \$550 per year at age 9–15, because the same percent is taken from a smaller price.

Pickups do not follow this pattern. They lose only about 7% a year when they are young (age 2–4), and the drop becomes faster (around 11–12%) after age 9.

So H1 is true in dollars, but not really in percent. We don't see an age where the price stops falling, older cars just lose fewer dollars because they are cheaper. For the main analysis we plan to report both measures, and fit log(price) on age for each model to check if the yearly drop really changes with age.

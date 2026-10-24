# pba-project-group2eieiei

PBA Fall 2026 team project — Group 2

## Team members

- Sirawee Wutinarongtrakul (李意如) - 110006226
- Teepawin Mueanpetch (趙偉儒) - 112006229
- Warunya Kumpunya (邱品寧) - 112006210

## Project

**Question:** Which used cars lose the least money over a 5-year ownership, and at what age is the best time to buy?

**Data:** [Used Cars Dataset](https://www.kaggle.com/datasets/austinreese/craigslist-carstrucks-data) by Austin Reese on Kaggle. It has about 427,000 used car listings from Craigslist in the U.S., posted in April and May 2021 (CC0 license).

- Milestone 2 proposal: [proposal.md](proposal.md)
- Codebook: [data/codebook.md](data/codebook.md)

## How to run

Open `pba-project-group2eieiei.Rproj` in RStudio and run:

```r
source("R/01_clean_data.R")  # downloads the raw data (1.4 GB) and makes data/vehicles_clean.csv.gz
source("R/02_first_look.R")  # 5-year loss by model and by buying age
```

The cleaned file is already in the repo, so you can skip the first step and run `R/02_first_look.R` directly.

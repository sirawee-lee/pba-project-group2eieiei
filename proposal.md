# Milestone 2 Proposal: Which Used Cars Lose the Least Money?

**Group 2:** Sirawee Wutinarongtrakul (李意如), Teepawin Mueanpetch (趙偉儒), Warunya Kumpunya (邱品寧)

## 1. Research question

**Which used cars lose the least money over a 5-year ownership, and at what age is the best time to buy?**

This is a **descriptive** question. We want to show how prices of popular models change with age, and compare models with each other. We do not try to predict the price of one specific car, and we do not claim that a brand *causes* a car to keep its value.

Our idea is simple. Imagine a person who buys a used car, drives it for 5 years, and then sells it. How much money do they lose? Does it depend on the model they pick, and on how old the car is when they buy it?

## 2. Hypotheses

**H1 (age):** Cars lose value fastest in their first few years. So a car bought at around 3 to 5 years old loses less money over 5 years than a car bought at 1 or 2 years old. The reason is that a new car's price includes a "new car premium". After the first owner sells it, a big part of that premium is already gone, and the price drops more slowly after that.

**H2 (model):** Pickup trucks and models with a strong reliability reputation, like the Toyota Tacoma, Toyota RAV4 and Honda Civic, keep a bigger share of their price than other cars in the same segment. Many buyers want cars that will run for a long time without big repairs, so demand for these models stays high even when they get older. Trucks are also used for work, so people still need them at 10 years old.

## 3. Data description

| | |
|:----|:----------------|
| **Source** | *Used Cars Dataset* by Austin Reese on Kaggle ([link](https://www.kaggle.com/datasets/austinreese/craigslist-carstrucks-data)). License: CC0 (public domain). |
| **How it was collected** | The author wrote a web scraper that collected every used car and truck listing on **Craigslist** in the United States. Craigslist is a website where dealers and private owners post cars for sale. These are real listings, not synthetic data. |
| **Unit of observation** | One car listing |
| **Period** | Listings posted between April 4 and May 5, 2021. Model years in our clean data: 2001 to 2021. |
| **Number of observations** | 426,880 listings in the raw file. 230,820 after cleaning. 35,394 listings of the 28 models we compare. |
| **Coverage** | All 50 U.S. states and DC, 39 brands |

The raw file is 1.4 GB, so we do not put it on GitHub. Our script `R/01_clean_data.R` downloads it and creates a smaller file, `data/vehicles_clean.csv.gz` (6.5 MB). In cleaning, we:

- removed listings with fake prices, like \$0 or \$1. We keep prices from \$1,000 to \$150,000.
- removed odometer values that are impossible.
- removed listings that were posted more than once.

**Variables we use** (full list in `data/codebook.md`)

| Name | Meaning | Unit |
|---|---|---|
| `price` | Asking price in the listing | US dollars |
| `year` | Model year | Year |
| `car_age` | 2021 − model year | Years |
| `odometer` | Miles on the car | Miles |
| `manufacturer` | Brand, e.g. Toyota, Honda, Ford | Category |
| `model_base` | Main model name, e.g. civic, camry, f-150 | Category |
| `segment` | Compact car, midsize car, SUV or pickup (we add this) | Category |
| `condition` | Condition stated by the seller (excellent, good, fair, ...) | Category |
| `title_status` | Clean, salvage, rebuilt, ... | Category |
| `seller` | Dealer or private owner (from the listing link) | Category |

## 4. Key variables and how we measure them

- **Outcome:** the **5-year loss** of a model. For each model and each buying age (for example 3 years old), we take the median price at that age and the median price 5 years older (8 years old). The loss is the difference in dollars, and we also show it as the **share of price kept** (price at 8 ÷ price at 3).
- **Main explanatory variables:** the **model** (28 popular models in 4 segments) and the **age when you buy** (1 to 10 years).
- **Mileage:** we only compare cars with normal mileage, which we define as 8,000 to 16,000 miles per year of age. For example, a 5-year-old car needs 40,000 to 80,000 miles. This way, a cheap car is not cheap just because it was driven a lot.
- We only use a model–age group if it has at least 20 listings, so one strange listing cannot change the median much.

Because the data come from one month only, we cannot follow the same car for 5 years. Instead, we use today's 8-year-old cars to show what today's 3-year-old cars will probably be worth in 5 years. This works only if the market stays similar, and we will say this clearly in the report.

## 5. What would count as evidence

**Supports H1:** the price drop per year is much bigger for young cars (1 to 3 years) than for older cars, and the 5-year loss in dollars gets clearly smaller when the buying age goes from 1 to 5 years.

**Against H1:** the price falls by about the same percent every year, so there is no special "best age" and older cars are cheaper to own only because they are cheaper to buy.

**Supports H2:** inside each segment, trucks and Toyota/Honda models keep a clearly bigger share of their price than the other models.

**Against H2:** the share kept is about the same for all models in a segment.

**First look:** we already checked the data in R (`R/02_first_look.R`). If you buy at 3 years old and sell at 8, a Ram 1500 keeps about 71% of its price and a Toyota Tacoma about 65%. A Nissan Rogue keeps about 44% and a Chevrolet Equinox about 48%. In dollars, the average 5-year loss goes from about \$14,600 when buying at 1 year old to about \$11,600 at 3 years and \$9,700 at 5 years. But the share kept stays around 50 to 60% at every age, so H1 may only be true in dollars, not in percent. This is something we want to look at more carefully.

## 6. Limitations and ethics

- These are **asking prices**, not the final selling prices.
- **2021 was not a normal year.** Because of the chip shortage, used car prices in the U.S. went up a lot in 2021, so our dollar numbers may be higher than usual.
- Repair costs, insurance and fuel are not in the data, so "loses the least money" means value loss only.
- About 36% of listings do not report `condition`, and the seller decides what "good" or "excellent" means.
- The data are about cars, not people. We do not use the listing text, links or locations below the region level, and the CC0 license lets us share the cleaned data.

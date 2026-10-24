# Codebook: `data/vehicles_clean.csv.gz`

**Source:** Austin Reese, *Used Cars Dataset* (Craigslist cars and trucks), Kaggle, 2021.
https://www.kaggle.com/datasets/austinreese/craigslist-carstrucks-data
**License:** CC0 (public domain)
**Made by:** `R/01_clean_data.R`. The raw file (`data/raw/vehicles.csv`, 1.4 GB) is not in the repo.
**Rows:** 230,820 listings (one row = one car listing). Listings were posted April 4 to May 5, 2021.

| Variable | Meaning | Unit / values | Missing |
|---|---|---|---|
| `id` | Craigslist listing ID | Number | 0 |
| `state` | U.S. state | Two-letter code | 0 |
| `region` | Craigslist region (city area) | Text | 0 |
| `seller` | Who posted the listing, from the link (`/ctd/` = dealer, `/cto/` = owner) | dealer, owner | 0 |
| `manufacturer` | Brand | Text, lower case (39 brands) | 0 |
| `luxury` | Luxury brand (list in the script) | 1 = yes, 0 = no | 0 |
| `model` | Model as typed by the seller | Text | 2,089 |
| `model_base` | First word of `model`, with a few spellings fixed (e.g. "3-series" → "3", "grand" → "grand cherokee" for Jeep) | Text | 2,089 |
| `year` | Model year | 2001–2021 | 0 |
| `car_age` | 2021 − `year` | Years (0–20) | 0 |
| `odometer` | Miles on the car | Miles (500–400,000) | 0 |
| `price` | Asking price | US dollars (1,000–150,000) | 0 |
| `condition` | Condition stated by seller | new, like new, excellent, good, fair, salvage | 83,602 |
| `title_status` | Legal title status | clean, rebuilt, salvage, lien, missing, parts only | 3,120 |
| `fuel` | Fuel type | gas, diesel, hybrid, electric, other | 1,191 |
| `transmission` | Transmission | automatic, manual, other | 916 |
| `drive` | Drive type | fwd, rwd, 4wd | 65,192 |
| `type` | Body type | sedan, SUV, pickup, truck, ... | 47,854 |
| `posting_date` | Date and time the listing was posted | Date-time | 0 |

**Cleaning rules**
- We keep prices from $1,000 to $150,000. Many listings use $0 or $1 as a placeholder.
- We keep odometer values from 500 to 400,000 miles, and model years 2001–2021.
- We drop listings with no brand, year or odometer, and Harley-Davidson (motorcycles).
- If the same car (brand, model, year, odometer, price, state) is posted more than once, we keep one copy.
- "rover" is merged into "land rover".

**Segments used in the analysis** (added in `R/02_first_look.R`)
- Compact car: Civic, Corolla, Sentra, Elantra, Jetta
- Midsize car: Camry, Accord, Altima, Sonata, Fusion, Malibu
- SUV: RAV4, CR-V, Rogue, Escape, Equinox, Forester, Wrangler, Grand Cherokee, Explorer, Highlander, 4Runner
- Pickup: F-150, Silverado, Ram 1500, Sierra, Tacoma, Tundra

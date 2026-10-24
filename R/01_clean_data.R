# 01_clean_data.R
# Downloads the Craigslist used-vehicle listings (Kaggle, CC0) and builds
# the analysis file data/vehicles_clean.csv.gz.
#
# Source: Austin Reese, "Used Cars Dataset" (Craigslist cars + trucks), 2021
# https://www.kaggle.com/datasets/austinreese/craigslist-carstrucks-data

library(tidyverse)

raw_dir  <- "data/raw"
raw_file <- file.path(raw_dir, "vehicles.csv")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# ---- 1. Download raw data (1.4 GB, kept out of git, see .gitignore) -----------
if (!file.exists(raw_file)) {
  options(timeout = 3600)
  zip_file <- file.path(raw_dir, "vehicles.zip")
  download.file(
    "https://www.kaggle.com/api/v1/datasets/download/austinreese/craigslist-carstrucks-data",
    zip_file, mode = "wb"
  )
  unzip(zip_file, exdir = raw_dir)
  file.remove(zip_file)
}

raw <- read_csv(
  raw_file,
  col_select = c(id, url, region, state, price, year, manufacturer, model,
                 condition, odometer, title_status, fuel, transmission,
                 drive, type, posting_date),
  show_col_types = FALSE
)

# ---- 2. Clean -----------------------------------------------------------------
# Listings were posted April 4 - May 5, 2021, so age = 2021 - model year.
luxury_brands <- c("acura", "alfa-romeo", "aston-martin", "audi", "bmw",
                   "cadillac", "ferrari", "infiniti", "jaguar", "land rover",
                   "lexus", "lincoln", "mercedes-benz", "porsche", "tesla",
                   "volvo")

cars <- raw |>
  mutate(
    manufacturer = if_else(manufacturer == "rover", "land rover", manufacturer),
    model_base   = str_to_lower(word(str_squish(model), 1)),
    # Same model written two ways
    model_base   = case_when(
      manufacturer == "mazda" & model_base == "3" ~ "mazda3",
      manufacturer == "mazda" & model_base == "6" ~ "mazda6",
      manufacturer == "bmw" & model_base == "3-series" ~ "3",
      manufacturer == "bmw" & model_base == "5-series" ~ "5",
      manufacturer == "jeep" & model_base == "grand" ~ "grand cherokee",
      TRUE ~ model_base
    ),
    car_age      = 2021 - year,
    seller       = if_else(str_detect(url, "/ctd/"), "dealer", "owner"),
    luxury       = as.integer(manufacturer %in% luxury_brands)
  ) |>
  filter(
    !is.na(manufacturer), !is.na(year), !is.na(odometer),
    between(price, 1000, 150000),     # drops $0 / $1 placeholders and typos
    between(odometer, 500, 400000),   # drops 0 / 999999-style odometers
    between(car_age, 0, 20),          # model years 2001-2021
    manufacturer != "harley-davidson" # motorcycles
  ) |>
  # Craigslist ads are often reposted: keep one copy of identical listings
  distinct(manufacturer, model, year, odometer, price, state, .keep_all = TRUE) |>
  select(id, state, region, seller, manufacturer, luxury, model, model_base,
         year, car_age, odometer, price, condition, title_status, fuel,
         transmission, drive, type, posting_date)

# ---- 3. Save ------------------------------------------------------------------
write_csv(cars, "data/vehicles_clean.csv.gz")

cat("Raw rows:", nrow(raw), " Clean rows:", nrow(cars),
    " Brands:", n_distinct(cars$manufacturer), "\n")

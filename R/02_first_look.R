# 02_first_look.R
# First look for the proposal: how much money each model loses over
# 5 years of ownership, depending on the age at which it is bought.

library(tidyverse)

cars <- read_csv("data/vehicles_clean.csv.gz", show_col_types = FALSE)

# Popular models we compare, by segment
models <- tribble(
  ~manufacturer,  ~model_base,       ~segment,
  "honda",        "civic",           "Compact car",
  "toyota",       "corolla",         "Compact car",
  "nissan",       "sentra",          "Compact car",
  "hyundai",      "elantra",         "Compact car",
  "volkswagen",   "jetta",           "Compact car",
  "toyota",       "camry",           "Midsize car",
  "honda",        "accord",          "Midsize car",
  "nissan",       "altima",          "Midsize car",
  "hyundai",      "sonata",          "Midsize car",
  "ford",         "fusion",          "Midsize car",
  "chevrolet",    "malibu",          "Midsize car",
  "toyota",       "rav4",            "SUV",
  "honda",        "cr-v",            "SUV",
  "nissan",       "rogue",           "SUV",
  "ford",         "escape",          "SUV",
  "chevrolet",    "equinox",         "SUV",
  "subaru",       "forester",        "SUV",
  "jeep",         "wrangler",        "SUV",
  "jeep",         "grand cherokee",  "SUV",
  "ford",         "explorer",        "SUV",
  "toyota",       "highlander",      "SUV",
  "toyota",       "4runner",         "SUV",
  "ford",         "f-150",           "Pickup",
  "chevrolet",    "silverado",       "Pickup",
  "ram",          "1500",            "Pickup",
  "gmc",          "sierra",          "Pickup",
  "toyota",       "tacoma",          "Pickup",
  "toyota",       "tundra",          "Pickup"
)

# Normal mileage: 8,000-16,000 miles per year of age
sample <- cars |>
  inner_join(models, by = c("manufacturer", "model_base")) |>
  filter(between(car_age, 1, 15),
         between(odometer, 8000 * car_age, 16000 * car_age))

cat("Listings in the model sample:", nrow(sample), "\n\n")

# Median price for each model and age (only cells with 20+ listings)
prices <- sample |>
  group_by(segment, manufacturer, model_base, car_age) |>
  summarise(n = n(), median_price = median(price), .groups = "drop") |>
  filter(n >= 20)

# Buy at age a, sell at age a + 5
ownership <- prices |>
  inner_join(prices |> mutate(car_age = car_age - 5),
             by = c("segment", "manufacturer", "model_base", "car_age"),
             suffix = c("_buy", "_sell")) |>
  rename(buy_age = car_age) |>
  mutate(loss_5yr = median_price_buy - median_price_sell,
         share_kept = round(median_price_sell / median_price_buy, 2))

# 1. Overall price curve by age (all models together)
sample |>
  group_by(car_age) |>
  summarise(n = n(), median_price = median(price)) |>
  mutate(drop_vs_last_year = round(1 - median_price / lag(median_price), 2)) |>
  print(n = Inf)

# 2. Buy a 3-year-old car, keep it 5 years: who loses the least?
ownership |>
  filter(buy_age == 3) |>
  arrange(segment, desc(share_kept)) |>
  select(segment, manufacturer, model_base, median_price_buy,
         median_price_sell, loss_5yr, share_kept) |>
  print(n = Inf)

# 3. Average 5-year loss by the age at which the car is bought
ownership |>
  group_by(buy_age) |>
  summarise(models = n(),
            avg_loss_5yr = round(mean(loss_5yr)),
            avg_share_kept = round(mean(share_kept), 2)) |>
  print(n = Inf)

# milestone 3 figures
# fig 1 = price by age for each model, fig 2 = % of price kept (buy at 3, sell at 8)
# run 01_clean_data.R first if data/vehicles_clean.csv.gz is missing

library(tidyverse)
library(scales)

dir.create("figures", showWarnings = FALSE)
cars <- read_csv("data/vehicles_clean.csv.gz", show_col_types = FALSE)

# same models as 02_first_look.R
models <- tribble(
  ~manufacturer, ~model_base, ~segment,
  "honda", "civic", "Compact car",
  "toyota", "corolla", "Compact car",
  "nissan", "sentra", "Compact car",
  "hyundai", "elantra", "Compact car",
  "volkswagen", "jetta", "Compact car",
  "toyota", "camry", "Midsize car",
  "honda", "accord", "Midsize car",
  "nissan", "altima", "Midsize car",
  "hyundai", "sonata", "Midsize car",
  "ford", "fusion", "Midsize car",
  "chevrolet", "malibu", "Midsize car",
  "toyota", "rav4", "SUV",
  "honda", "cr-v", "SUV",
  "nissan", "rogue", "SUV",
  "ford", "escape", "SUV",
  "chevrolet", "equinox", "SUV",
  "subaru", "forester", "SUV",
  "jeep", "wrangler", "SUV",
  "jeep", "grand cherokee", "SUV",
  "ford", "explorer", "SUV",
  "toyota", "highlander", "SUV",
  "toyota", "4runner", "SUV",
  "ford", "f-150", "Pickup",
  "chevrolet", "silverado", "Pickup",
  "ram", "1500", "Pickup",
  "gmc", "sierra", "Pickup",
  "toyota", "tacoma", "Pickup",
  "toyota", "tundra", "Pickup"
)

seg_colors <- c("Compact car" = "#1b9e77", "Midsize car" = "#7570b3", "SUV" = "#d95f02", "Pickup" = "#e7298a")

sample <- cars |>
  inner_join(models, by = c("manufacturer", "model_base")) |>
  filter(between(car_age, 1, 15),
         between(odometer, 8000 * car_age, 16000 * car_age)) |>  # normal mileage
  mutate(segment = factor(segment, levels = c("Compact car", "Midsize car", "SUV", "Pickup")),
         label = str_to_title(paste(manufacturer, model_base)))

# fix some names that str_to_title breaks
sample$label <- sample$label |>
  str_replace("Rav4", "RAV4") |>
  str_replace("Cr-V", "CR-V") |>
  str_replace("Gmc", "GMC") |>
  str_replace("4runner", "4Runner") |>
  str_replace("Volkswagen", "VW")

prices <- sample |>
  group_by(segment, label, car_age) |>
  summarise(n = n(), median_price = median(price), .groups = "drop") |>
  filter(n >= 20)

## Figure 1
# log scale so a straight line = same % drop every year
seg_median <- prices |>
  group_by(segment, car_age) |>
  summarise(median_price = median(median_price), .groups = "drop")

fig1 <- ggplot(prices, aes(car_age, median_price)) +
  geom_line(aes(group = label), color = "grey70", linewidth = 0.4) +
  geom_line(data = seg_median, aes(color = segment), linewidth = 1.3) +
  facet_wrap(~segment, nrow = 1) +
  scale_y_log10(labels = label_dollar(accuracy = 1), breaks = c(2500, 5000, 10000, 20000, 40000)) +
  scale_x_continuous(breaks = c(1, 5, 10, 15)) +
  scale_color_manual(values = seg_colors, guide = "none") +
  labs(title = "Used car prices fall at a similar % rate every year",
       subtitle = "Median asking price by car age (log scale). Grey = one model, color = segment median.",
       x = "Car age (years)", y = "Median asking price",
       caption = "Craigslist listings, Apr-May 2021. Normal mileage only (8k-16k miles per year). Model-age groups with 20+ listings.") +
  theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"),
        plot.caption = element_text(color = "grey40", size = 8))
fig1
ggsave("figures/fig1_price_by_age.png", fig1, width = 9, height = 4, dpi = 300, bg = "white")

## Figure 2
keep <- prices |>
  filter(car_age %in% c(3, 8)) |>
  select(segment, label, car_age, median_price) |>
  pivot_wider(names_from = car_age, values_from = median_price, names_prefix = "age_") |>
  filter(!is.na(age_3), !is.na(age_8)) |>
  mutate(share_kept = age_8 / age_3, loss = age_3 - age_8) |>
  arrange(share_kept) |>
  mutate(label = fct_inorder(label))

fig2 <- ggplot(keep, aes(share_kept, label, color = segment)) +
  geom_vline(xintercept = median(keep$share_kept), linetype = "dashed", color = "grey50") +
  geom_segment(aes(x = 0.4, xend = share_kept, yend = label), color = "grey85") +
  geom_point(size = 3) +
  # $ loss as a column on the right (it overlapped the dashed line before)
  geom_text(aes(x = 0.84, label = dollar(round(loss, -2))), hjust = 1, size = 3, color = "grey30") +
  annotate("text", x = 0.84, y = nrow(keep) + 0.9, label = "5-year loss", hjust = 1, size = 3, fontface = "bold", color = "grey30") +
  scale_x_continuous(labels = label_percent(), limits = c(0.4, 0.84), breaks = seq(0.4, 0.8, 0.1)) +
  coord_cartesian(clip = "off") +
  scale_color_manual(values = seg_colors, name = NULL) +
  labs(title = "Pickups and Jeep Wrangler keep the most value",
       subtitle = "Share of price kept: median price at age 8 / median price at age 3.\nRight column = 5-year loss in dollars. Dashed line = median of all 28 models.",
       x = "Share of price kept after 5 years", y = NULL,
       caption = "Craigslist listings, Apr-May 2021. Normal mileage only. Each model-age group has 20+ listings.") +
  theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(), panel.grid.major.y = element_blank(),
        legend.position = "top", plot.title = element_text(face = "bold"),
        plot.caption = element_text(color = "grey40", size = 8))
fig2
ggsave("figures/fig2_share_kept.png", fig2, width = 7, height = 7.5, dpi = 300, bg = "white")

## numbers for the write-up
# yearly drop (% and $) by segment and age group
yearly <- prices |>
  group_by(label) |>
  arrange(car_age, .by_group = TRUE) |>
  mutate(pct_drop = 1 - median_price / lag(median_price),
         usd_drop = lag(median_price) - median_price) |>
  filter(car_age - lag(car_age) == 1) |>
  ungroup()

yearly |>
  mutate(ages = cut(car_age, c(1, 4, 8, 15), labels = c("2-4", "5-8", "9-15"))) |>
  group_by(segment, ages) |>
  summarise(pct = round(median(pct_drop), 3), usd = round(median(usd_drop)), .groups = "drop") |>
  print(n = Inf)

keep |> arrange(desc(share_kept)) |> print(n = Inf)

keep |>
  group_by(segment) |>
  summarise(median_share = round(median(share_kept), 2), median_loss = round(median(loss)))

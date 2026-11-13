
# Venezuela CO2 Emissions Dataset
# Source: Our World in Data

country_code <- "VEN"
start_year <- 1990
end_year <- 2024

# Create data folder
dir.create("data", showWarnings = FALSE)

# Download the official dataset
url <- "https://owid-public.owid.io/data/co2/owid-co2-data.csv"

full_file <- "data/owid-co2-data.csv"

if (!file.exists(full_file)) {
  options(timeout = 300)
  download.file(url, full_file, mode = "wb")
}

# Read the dataset
all_data <- read.csv(full_file)

# Select Venezuela only
venezuela <- subset(
  all_data,
  iso_code == "VEN" &
    year >= 1990 &
    year <= 2024,
  select = c(country, iso_code, year,
             co2, co2_per_capita)
)

# Save Venezuela-only dataset
write.csv(
  venezuela,
  "data/VEN_co2.csv",
  row.names = FALSE,
  na = ""
)

# Display the dataset
View(venezuela)

print("Venezuela dataset saved successfully!")



# Create the figures folder
dir.create("figures", showWarnings = FALSE)

# Arrange Venezuela data by year
venezuela <- venezuela[order(venezuela$year), ]

# GRAPH 1: Annual CO2 emissions
png("figures/VEN_annual_co2.png",
    width = 1200, height = 700)

plot(venezuela$year, venezuela$co2,
     type = "o",
     col = "blue",
     pch = 16,
     main = "Venezuela - Annual CO2 Emissions",
     xlab = "Year",
     ylab = "Million tonnes CO2/year")

grid()
dev.off()

# GRAPH 2: CO2 emissions per capita
png("figures/VEN_per_capita.png",
    width = 1200, height = 700)

plot(venezuela$year, venezuela$co2_per_capita,
     type = "o",
     col = "darkgreen",
     pch = 16,
     main = "Venezuela - CO2 Emissions Per Capita",
     xlab = "Year",
     ylab = "Tonnes CO2/person/year")

grid()
dev.off()

# GRAPH 3: Yearly percentage change
change_pct <- rep(NA_real_, nrow(venezuela))

for (i in 2:nrow(venezuela)) {
  if (!is.na(venezuela$co2[i]) &&
      !is.na(venezuela$co2[i - 1]) &&
      venezuela$year[i] == venezuela$year[i - 1] + 1 &&
      venezuela$co2[i - 1] > 0) {
    change_pct[i] <- 100 *
      (venezuela$co2[i] / venezuela$co2[i - 1] - 1)
  }
}

png("figures/VEN_annual_change.png",
    width = 1200, height = 700)

plot(venezuela$year, change_pct,
     type = "o",
     col = "red",
     pch = 16,
     main = "Venezuela - Annual CO2 Change",
     xlab = "Year",
     ylab = "Change from previous year (%)")

grid()
dev.off()

print("Three graphs created successfully!")


# VENEZUELA SUMMARY STATISTICS

dir.create("results", showWarnings = FALSE)

# Select valid CO2 data
valid <- venezuela[!is.na(venezuela$co2), ]

first <- valid[1, ]
last <- valid[nrow(valid), ]
peak <- valid[which.max(valid$co2), ]

# Calculate percentage change
percent_change <- 100 * (last$co2 / first$co2 - 1)

# Latest per-capita emissions
pc <- venezuela$co2_per_capita
latest_pc <- tail(pc[!is.na(pc)], 1)

# Create summary table
summary_table <- data.frame(
  country = "Venezuela",
  iso_code = "VEN",
  first_year = first$year,
  last_year = last$year,
  first_co2_mt = first$co2,
  last_co2_mt = last$co2,
  endpoint_change_percent = percent_change,
  peak_year = peak$year,
  peak_co2_mt = peak$co2,
  latest_co2_per_capita_t = latest_pc
)

# Save summary
write.csv(summary_table,
          "results/VEN_summary.csv",
          row.names = FALSE)

# Save yearly changes
yearly_changes <- data.frame(
  year = venezuela$year,
  co2 = venezuela$co2,
  co2_per_capita = venezuela$co2_per_capita,
  change_pct = change_pct
)

write.csv(yearly_changes,
          "results/VEN_yearly_changes.csv",
          row.names = FALSE)

# Save R session information
writeLines(
  c(
    "Source: https://owid-public.owid.io/data/co2/owid-co2-data.csv",
    paste("Downloaded/processed:", Sys.time()),
    capture.output(sessionInfo())
  ),
  "results/session_info.txt"
)

print("Summary statistics created successfully!")
print(summary_table)


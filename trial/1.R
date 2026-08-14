# since its complexily formated government data we use rvest library ####
install.packages("rvest", repos="https://cloud.r-project.org")
library(rvest)


# Reading it as a webpage
page <- read_html("horizontal_crop_vertical_year_report(2).xls")

# Grabbing all the tables on the page
tables <- html_table(page, fill = TRUE)

# if many tables found we start from first one.
raw_data <- tables[[1]]

#seeing if the data is correct
head(raw_data)

#slicing off the extra rows seen and leaving columns as it is
clean_data <- raw_data[-c(1, 2), ]
head(clean_data)

# Renaming the colums to area(hectare)    production(tonne) and yield (tonne per hectare) as per the original data
colnames(clean_data) <- c("State", "District", "Year", "Area(hectare)", "Production(Tonne)", "Yield(Tonne per hectare)")

# Since i live in Kalaburagi i will filter for it using its old name
kalaburagi_tur <- clean_data[grepl("Gulbarga", clean_data$District, ignore.case = TRUE), ]
head(kalaburagi_tur)

#since i am getting backticks, we will simplify the headers
colnames(kalaburagi_tur)[4:6] <- c("Area", "Production", "Yield")
str(kalaburagi_tur)

# the data has commas and numbers are seen as characters. we will use as.number command just in case
kalaburagi_tur$Area <- as.numeric(gsub(",", "", kalaburagi_tur$Area))
kalaburagi_tur$Production <- as.numeric(gsub(",", "", kalaburagi_tur$Production))
kalaburagi_tur$Yield <- as.numeric(kalaburagi_tur$Yield)

str(kalaburagi_tur)

#saving the file
write.csv(kalaburagi_tur, "kalaburagi_pigeon_pea_clean.csv", row.names = FALSE)

#now that i am satisfied with the sample data lets do this for the whole table.
 karnataka_tur <- clean_data[grepl("Karnataka", clean_data$State, ignore.case = TRUE), ]
 colnames(karnataka_tur)[4:6] <- c("Area", "Production", "Yield")
 karnataka_tur$Area <- as.numeric(gsub(",", "", karnataka_tur$Area))
 karnataka_tur$Production <- as.numeric(gsub(",", "", karnataka_tur$Production))
 karnataka_tur$Yield <- as.numeric(karnataka_tur$Yield)
 str(karnataka_tur)
 write.csv(karnataka_tur, "karnataka_tur.csv", row.names = FALSE)
 
#importing rainfall data from nasapower, couldnt get repos with specific years for our data on opensource repos so
 install.packages("nasapower")
library(nasapower)

#trying this for kalaburagi , checked its longitude latitude as 76.83 and 17.33
kalaburagi_rain <- get_power(
  community = "ag",     # agricultural data
  lonlat = c(76.83, 17.33),
  pars = "PRECTOTCORR",      #corrected data
  dates = c("1997", "2022"),
  temporal_api = "monthly"
)

head(kalaburagi_rain)
colnames(kalaburagi_rain)

#removing the annoying prectotcorr column
 kalaburagi_rain$PARAMETER <- NULL
 head(kalaburagi_rain)

#saving the dataset 
 write.csv(kalaburagi_rain, "kalaburagi_rain.csv", row.names = FALSE)

#lets debug before merging
 head(kalaburagi_tur$Year)   # two years in one cell
 head(kalaburagi_rain$YEAR)  #one year in one cell

# Creating a common year column in the crop data
 kalaburagi_tur$Years <- as.numeric(substr(kalaburagi_tur$Year, 1, 4))

# Merging them together and cleaning duplicates
 final_data <- merge(kalaburagi_tur, kalaburagi_rain, by.x = "Years", by.y = "YEAR")
 final_data$Year <- NULL
 head(final_data)

#since this looks good we do this for entire table.
unique(karnataka_tur$District)
district_names <- c("1. Bagalkot", "2. Bangalore rural", "3. Belgaum", "4. Bellary", "5. Bengaluru urban", 
                    "6. Bidar", "7. Bijapur", "8. Chamarajanagar", "9. Chikballapur", "10. Chikmagalur", 
                    "11. Chitradurga", "12. Dakshin kannad", "13. Davangere", "14. Dharwad", "15. Gadag", 
                    "16. Gulbarga", "17. Hassan", "18. Haveri", "19. Kodagu", "20. Kolar", 
                    "21. Koppal", "22. Mandya", "23. Mysore", "24. Raichur", "25. Ramanagara", 
                    "26. Shimoga", "27. Tumkur", "28. Udupi", "29. Uttar kannad", "30. Vijayanagar", "31. Yadgir")
lat <- c(16.1821, 13.2505, 15.8497, 15.1394, 12.9716, 17.9102, 16.8302, 11.9261, 13.4357, 13.3153, 14.2251, 12.9141, 14.4644, 15.4589, 15.4317, 17.3297, 13.0068, 14.7937, 12.4244, 13.1367, 15.3525, 12.5225, 12.2958, 16.2076, 12.7236, 13.9299, 13.3379, 13.3409, 14.8143, 15.3350, 16.7618)
lon <- c(75.6963, 77.5807, 74.4977, 76.9214, 77.5946, 77.5199, 75.7100, 76.9447, 77.7315, 75.7754, 76.3980, 74.8560, 75.9218, 75.0078, 75.6358, 76.8343, 76.1004, 75.4022, 75.7382, 78.1292, 76.1550, 76.8956, 76.6394, 77.3463, 77.2804, 75.5681, 77.1173, 74.7421, 74.1309, 76.4600, 77.1352)

# Combining them into single data frame
districts <- data.frame(District = district_names,Lat = lat,Lon = lon)
head(districts)
write.csv(districts, "karnataka_district_coordinates.csv", row.names = FALSE)


#downloading data from nasapowe by fetching weather data for each unique district from the dataframe exactly once
Karnataka_rain<- mapply(function(d_name, d_lon, d_lat) {
  cat("Fetching data for:", d_name, "\n")      #ai used here for this operation
  
  temp_data <- get_power(
    community = "ag",
    lonlat = c(d_lon, d_lat),
    pars = "PRECTOTCORR", 
    dates = c("1997", "2022"),
    temporal_api = "monthly"
  )
  
  temp_data$District <- d_name
  return(temp_data)
}, districts$District, districts$Lon, districts$Lat, SIMPLIFY = FALSE)
karnataka_rain <- do.call(rbind, Karnataka_rain)
#ai use end




#lets debug before merging
head(karnataka_tur$Year)   #same issue we caught before
head(karnataka_rain$YEAR)  
karnataka_tur$Match_Year <- as.numeric(substr(karnataka_tur$Year, 1, 4))
final_state_data <- merge(karnataka_tur, karnataka_rain, 
                          by.x = c("District", "Match_Year"), 
                          by.y = c("District", "YEAR"))

head(final_state_data)

# Seeing if there are errors ####

sum(is.na(final_state_data))
table(final_state_data$District)

# checking how many years each district actually has, sorted
district_counts <- table(final_state_data$District)
sort(district_counts)

# flagging districts with very few years
low_count_districts <- names(district_counts[district_counts < 10])
low_count_districts

# excluding districts with fewer than 10 years of data or newly formed. districts (Vijayanagar, formed 2021) or districts where tur is a minor crop (Dakshin Kannada, Udupi, Kodagu) with too few points for reliable analysis
final_state_data_clean <- final_state_data[!final_state_data$District %in% low_count_districts, ]
table(final_state_data_clean$District)

#analysis ######

mean(final_state_data$Yield)
mean(final_state_data$ANN)
mean(final_state_data_clean$Yield)
mean(final_state_data_clean$ANN)

# is yield skewed?
hist(final_state_data_clean$Yield, main = "Distribution of Yield", xlab = "Yield")     #histogram showed positively skewed
# outliers by district
boxplot(Yield ~ District, data = final_state_data_clean, las = 2, cex.axis = 0.6,
        main = "Yield by District")                   #circles in the boxplot represent yeild gains that pulled the mean upwards

# average yield per year across all districts
yearly_avg <- aggregate(Yield ~ Match_Year, data = final_state_data_clean, FUN = mean)
plot(yearly_avg$Match_Year, yearly_avg$Yield, type = "l",
     main = "State Average Yield Over Time", xlab = "Year", ylab = "Yield")

colnames(karnataka_rain)

# Tur is sown in kharif season (roughly June-September)
final_state_data_clean$Monsoon_Rain <- final_state_data_clean$JUN + final_state_data_clean$JUL + 
  final_state_data_clean$AUG + final_state_data_clean$SEP

# compare correlation: annual rainfall vs monsoon rainfall
cor(final_state_data_clean$Yield, final_state_data_clean$ANN)
cor(final_state_data_clean$Yield, final_state_data_clean$Monsoon_Rain)


#standard deviation

sd(final_state_data_clean$Yield)     
sd(final_state_data_clean$ANN)      

cor(final_state_data_clean$Yield, final_state_data_clean$ANN)   #correlation between yeild and annual rainfall

#simple linear regression model
# model 1: just annual rainfall 
model1 <- lm(Yield ~ ANN, data = final_state_data_clean)
summary(model1)

# model 2: monsoon rainfall instead of annual
model2 <- lm(Yield ~ Monsoon_Rain, data = final_state_data_clean)
summary(model2)

# model 3: monsoon rainfall + year (captures technology or varietal improvements over time)
model3 <- lm(Yield ~ Monsoon_Rain + Match_Year, data = final_state_data_clean)
summary(model3)

# does adding year significantly improve the model?
anova(model2, model3)


# modal level assumptions
par(mfrow = c(2, 2))
plot(model3)
par(mfrow = c(1, 1))   

# correlation between yield and monsoon rain, per district
district_summary <- data.frame()

for (d in unique(final_state_data_clean$District)) {
  subset_d <- final_state_data_clean[final_state_data_clean$District == d, ]
  
  if (nrow(subset_d) > 2) {   # need at least a few points to correlate
    corr_val <- cor(subset_d$Yield, subset_d$Monsoon_Rain)
    mean_yield <- mean(subset_d$Yield)
    
    district_summary <- rbind(district_summary, 
                              data.frame(District = d, 
                                         Correlation = corr_val, 
                                         Mean_Yield = mean_yield))
  }
}

district_summary
write.csv(district_summary, "district_rainfall_sensitivity.csv", row.names = FALSE)

#district level correlation between rainfall and yield
district_summary[order(-abs(district_summary$Correlation)), ]


# holding out the last 4 years as a test set
train_data <- final_state_data_clean[final_state_data_clean$Match_Year <= 2018, ]
test_data  <- final_state_data_clean[final_state_data_clean$Match_Year > 2018, ]

# training the model only on training years
train_model <- lm(Yield ~ Monsoon_Rain + Match_Year, data = train_data)

# predict on unseen years
predictions <- predict(train_model, newdata = test_data)

# checking how far off predictions were
actual <- test_data$Yield
errors <- actual - predictions

rmse <- sqrt(mean(errors^2))
rmse

# Plotting actual vs predicted for the test set
plot(test_data$Match_Year, actual, type = "b", col = "blue", pch = 19,
     main = "Actual vs Predicted Yields (2019-2022 Test Set)",
     xlab = "Year", ylab = "Yield (Tonne/ha)", ylim = c(0, max(c(actual, predictions), na.rm = TRUE)))

lines(test_data$Match_Year, predictions, type = "b", col = "red", pch = 17, lty = 2)
legend("topright", legend = c("Actual", "Predicted"), col = c("blue", "red"), pch = c(19, 17), lty = c(1, 2))

naive_prediction <- mean(train_data$Yield)
naive_errors <- actual - naive_prediction
naive_rmse <- sqrt(mean(naive_errors^2))

naive_rmse   
rmse

install.packages("plm", repos = "https://cloud.r-project.org")
library(plm)

panel_model <- plm(Yield ~ Monsoon_Rain, 
                   data = final_state_data_clean,
                   index = c("District", "Match_Year"), 
                   model = "within")

summary(panel_model)

# a quick visual
install.packages("ggplot2", repos = "https://cloud.r-project.org")
library(ggplot2)
ggplot(district_summary, aes(x = reorder(District, Correlation), y = Correlation)) +
  geom_col() +
  coord_flip() +
  labs(title = "Rainfall-Yield Correlation by District",
       x = "District", y = "Correlation (Monsoon Rainfall vs Yield)")

# Analysis for Kalaburagi ######

str(final_data)
colnames(final_data)

final_data$Monsoon_Rain <- final_data$JUN + final_data$JUL + final_data$AUG + final_data$SEP
head(final_data[, c("Years", "Monsoon_Rain")])    #adding monsoon

# yield trend over time
plot(final_data$Years, final_data$Yield, type = "b", pch = 19,
     main = "Kalaburagi: Tur Yield Over Time",
     xlab = "Year", ylab = "Yield (Tonne per hectare)")

trend_line <- lm(Yield ~ Years, data = final_data)
abline(trend_line, col = "red")

# Rainfall trend over time
plot(final_data$Years, final_data$Monsoon_Rain, type = "b", pch = 19, col = "blue",
     main = "Kalaburagi: Monsoon Rainfall Over Time",
     xlab = "Year", ylab = "Monsoon Rainfall (mm)")

# yield and rainfall scaled together
yield_scaled <- (final_data$Yield - min(final_data$Yield)) / 
  (max(final_data$Yield) - min(final_data$Yield))
rain_scaled <- (final_data$Monsoon_Rain - min(final_data$Monsoon_Rain)) / 
  (max(final_data$Monsoon_Rain) - min(final_data$Monsoon_Rain))

plot(final_data$Years, yield_scaled, type = "l", col = "darkgreen", lwd = 2,
     main = "Kalaburagi: Yield vs Rainfall (scaled)",
     xlab = "Year", ylab = "Scaled value (0-1)")
lines(final_data$Years, rain_scaled, col = "blue", lwd = 2)
legend("topright", legend = c("Yield", "Monsoon Rainfall"), col = c("darkgreen", "blue"), lty = 1, bty = "n")   # "n" = no box

# correlation 
cor(final_data$Yield, final_data$Monsoon_Rain)

kalaburagi_model <- lm(Yield ~ Monsoon_Rain + Years, data = final_data)
summary(kalaburagi_model)

# Prediction for 2026-27 (even though data is not up to date)
# checking recent monsoon rainfall to set a realistic baseline
tail(final_data[, c("Years", "Monsoon_Rain")], 10)

avg_recent_rain <- mean(tail(final_data$Monsoon_Rain, 10))
avg_recent_rain

# scenario 1: normal monsoon
new_data_normal <- data.frame(Years = 2026, Monsoon_Rain = avg_recent_rain)
predict(kalaburagi_model, newdata = new_data_normal, interval = "prediction")

# scenario 2: poor monsoon (20% below recent average)
new_data_poor <- data.frame(Years = 2026, Monsoon_Rain = avg_recent_rain * 0.8)
predict(kalaburagi_model, newdata = new_data_poor, interval = "prediction")

# scenario 3: good monsoon (20% above recent average)
new_data_good <- data.frame(Years = 2026, Monsoon_Rain = avg_recent_rain * 1.2)
predict(kalaburagi_model, newdata = new_data_good, interval = "prediction")

#insights
final_data[which.max(final_data$Yield), c("Years", "Yield", "Monsoon_Rain")]
final_data[which.min(final_data$Yield), c("Years", "Yield", "Monsoon_Rain")]

cv_yield <- sd(final_data$Yield) / mean(final_data$Yield) * 100
cv_yield     #yield volatility

final_data$Yield_Change_Pct <- c(NA, diff(final_data$Yield) / head(final_data$Yield, -1) * 100)
final_data[, c("Years", "Yield", "Yield_Change_Pct")]     #year over year changes

avg_rain_overall <- mean(final_data$Monsoon_Rain)
final_data$Low_Rain_Year <- final_data$Monsoon_Rain < avg_rain_overall
final_data$Yield_Dropped <- c(NA, diff(final_data$Yield) < 0)

table(final_data$Low_Rain_Year, final_data$Yield_Dropped)    #drought years vs yield drops

#state vs kalaburagi
state_avg_yield <- mean(final_state_data_clean$Yield)
kalaburagi_avg_yield <- mean(final_data$Yield)

state_avg_yield
kalaburagi_avg_yield
kalaburagi_avg_yield - state_avg_yield


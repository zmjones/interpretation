args = commandArgs(TRUE)

if (length(args) == 0) {
  message("using default arguments")
  crime = "BURGLARY"
  threads = parallel::detectCores()
} else {
  crime = args[1]
  threads = 1
}

library(ranger)
library(edarf)
library(ggplot2)
library(dplyr)
library(dtplyr)
library(data.table)
library(lubridate)
library(zoo)
library(tidyr)
library(stringr)

path <- unlist(str_split(getwd(), "/"))
dir_prefix <- ifelse(path[length(path)] == "src", "../", "./")
r_dir_prefix <- ifelse(path[length(path)] == "crime", "src/", "./")
data_prefix <- paste0(dir_prefix, "data/")

## get last modified times
src.mod.time = file.info(paste0(dir_prefix, "src/analyze.R"))$mtime
data.mod.time = file.info(paste0(dir_prefix, "data/replication.csv"))$mtime
fit.mod.time = file.info(paste0(dir_prefix, "results/fit.RData"))$mtime

if (src.mod.time > data.mod.time) {
  ## import chicago crime data
  ## aggregate event times to the hour/beat
  data = fread(paste0(data_prefix, "chicago.csv")) %>%
    select(Date, Beat, Crime = `Primary Type`) %>%
    filter(Crime == crime) %>%
    mutate(Date = ceiling_date(mdy_hms(Date, tz = "CST"), "hours")) %>%
    group_by(Date, Beat) %>%
    summarise(Count = n())

  ## create an evenly spaced time series
  ts = tbl_dt(expand.grid(Date = seq(
    mdy_hms("01/01/2001 00:00:00", tz = "CST"),
    mdy_hms("02/07/2017, 24:00:00", tz = "CST"), by = "hours"),
    Beat = unique(data$Beat)))

  ## merge time series and source data
  data = left_join(ts, data, by = c("Date", "Beat"))

  ## summarize variation amongst beats in terms of monthly totals
  summary.month.beat = data %>%
    mutate(Date = round_date(Date, "month"), Beat = as.factor(Beat)) %>%
    group_by(Beat, Date) %>%
    summarize(Count = sum(!is.na(Count))) %>%
    ggplot(aes(Date, Count)) +
    geom_line(stat = "smooth", method = "gam", formula = y ~ s(x), color = "red", size = 1) +
    geom_line(aes(group = Beat), stat = "smooth",
      method = "gam", formula = y ~ s(x), alpha = .1) + theme_bw()
  ggsave(paste0(dir_prefix, "figures/summary_month_beat.png"),
    summary.month.beat, width = 12, height = 6)

  ## aggregate to am/pm, binary incidence instead of counts (due to sparsity)
  ## construct time-series features (lags and seasonality)
  data = data %>%
    mutate(TimeOfDay = as.factor(ifelse(hour(Date) >= 12, "PM", "AM")),
      Month = month(Date),
      Year = year(Date),
      Day = mday(Date)) %>%
    group_by(Beat, TimeOfDay, Month, Year, Day) %>%
    summarize(Incidence = sum(!is.na(Count))) %>%
    mutate(Date = ymd(paste(Year, Month, Day, sep = "/")),
      Week = week(Date)) %>%
    group_by(Beat) %>%
    mutate(MonthLag = rollapply(Incidence, width = 30 * 2, FUN = sum, fill = NA),
      WeekLag = rollapply(Incidence, width = 7 * 2, FUN = sum, fill = NA),
      DayLag = rollapply(Incidence, width = 1 * 2, FUN = sum, fill = NA)) %>%
    mutate(Weekday = wday(Date, label = TRUE),
      Month = month(Date, label = TRUE),
      Incidence = factor(Incidence > 0),
      Beat = as.factor(Beat))
  fwrite(data, paste0(data_prefix, "replication.csv"))
} else {
  data = fread(paste0(data_prefix, "replication.csv")) %>%
    mutate(Weekday = ordered(Weekday,
      levels = c("Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun")),
      TimeOfDay = as.factor(TimeOfDay),
      Incidence = as.factor(Incidence),
      Month = ordered(Month,
        levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
          "Aug", "Sep", "Oct", "Nov", "Dec")),
      Beat = as.factor(Beat))
}

## date not used as a feature
## and i don't expect any day-of-month trends
## also omit the first parts of the series where lags aren't defined
## expand beats into binary variables
beats = as.character(unique(data$Beat))
beats = paste0("beat_", beats)

data = data %>%
  ## bind_cols(setnames(setDF(lapply(levels(data$Beat),
  ##   function(x) as.integer(data$Beat == x))), paste0("beat_", levels(data$Beat)))) %>%
  na.omit() %>%
  select(-one_of("Date", "Day", "Week", "Beat")) %>%  
  as.data.frame()

if (src.mod.time > fit.mod.time) {
  load(paste0(dir_prefix, "results/fit.RData"))
} else {
  fit = ranger(data = data,
    num.trees = 1000L,
    mtry = floor(sqrt(ncol(data) - 1L)),
    write.forest = TRUE,
    seed = 1987,
    dependent.variable.name = "Incidence",
    verbose = TRUE,
    probability = TRUE,
    save.memory = TRUE,
    respect.unordered.factors = "partition",
    num.threads = threads,
    importance = "impurity")
  save(fit, file = paste0(dir_prefix, "results/fit.RData"))
}

## plot impurity importance
beat.idx = grepl("beat", names(fit$variable.importance))
plt = melt(fit$variable.importance[beat.idx])
plt$beat = str_replace(row.names(plt), "beat_", "")
plt$beat = factor(plt$beat, levels = unique(plt$beat)[order(plt$value)])
p = ggplot(plt, aes(value, beat)) + geom_point() + theme_bw()
ggsave(paste0(dir_prefix, "figures/beat_importance.png"), p, width = 6, height = 30)

plt = melt(fit$variable.importance[!beat.idx])
plt$feature = row.names(plt)
plt = bind_rows(data_frame("value" = sum(fit$variable.importance[beat.idx]),
  "feature" = "Beat"), plt)
p = ggplot(plt, aes(feature, value)) + geom_point() + theme_bw() +
  labs(y = "Importance (Impurity)", x = NULL)
ggsave(paste0(dir_prefix, "figures/feature_importance.png"), p, width = 12, height = 8)

## estimate and plot marginal effects
estimateEffect = function(vars, p = .01, filename, interaction = TRUE) {
  ## points = sapply(vars, function(x) na.omit(unique(data[[x]])), simplify = FALSE)
  n = c(10, floor(p * nrow(data)))
  pd = partial_dependence(fit,
    vars = vars,
    n = n,
    uniform = FALSE,
    ## points = points,
    data = data,
    interaction = interaction
  )
  save(pd, file = paste0(dir_prefix, "results/", filename, ".RData"))
  return(pd)
}

tod.effect = estimateEffect("TimeOfDay", filename = "tod_effect")
week.effect = estimateEffect("Weekday", filename = "week_effect")
week.tod.effect = estimateEffect(c("TimeOfDay", "Weekday"), filename = "week_tod_effect")
month.effect = estimateEffect("Month", filename = "month_effect")
month.tod.effect = estimateEffect(c("Month", "TimeOfDay"), filename = "month_tod_effect")
year.effect = estimateEffect("Year", filename = "year_effect")
daylag.effect = estimateEffect("DayLag", filename = "daylag_effect")
weeklag.effect = estimateEffect("WeekLag", filename = "weeklag_effect")
monthlag.effect = estimateEffect("MonthLag", filename = "monthlag_effect")
## beat.effect = estimateEffect(beats, filename = "beat_effect", interaction = FALSE)
## beat.effect = melt(id.vars = c(FALSE, TRUE), na.rm = TRUE) %>%
##   rename(prob = `TRUE`) %>%
##   mutate(variable = str_replace(variable, "beat_", "")) %>%
##   filter(value == 1) %>%
##   select(prob, variable) %>%
##   mutate(variable = factor(variable, levels = levels(variable)[order(prob)]))
## p = ggplot(beat.effect, aes(`TRUE`, variable)) + geom_point()

ggplot(tod.effect, aes(TimeOfDay, `TRUE`)) + geom_point() +
  labs(x = "Time of Day", y = "Marginal Prob of Burglary")
ggplot(week.effect, aes(Weekday, `TRUE`)) + geom_point() +
  labs(y = "Marginal Prob of Burglary")
ggplot(week.tod.effect, aes(Weekday, `TRUE`)) + geom_point() +
  facet_wrap(~ TimeOfDay) +
  labs(y = "Marginal Prob of Burglary")
ggplot(month.effect, aes(Month, `TRUE`)) + geom_point() +
  labs(y = "Marginal Prob of Burglary")
ggplot(month.tod.effect, aes(Month, `TRUE`)) + geom_point() +
  facet_wrap(~ TimeOfDay) +
  labs(y = "Marginal Prob of Burglary")
ggplot(year.effect, aes(Year, `TRUE`)) + geom_point() +
  labs(y = "Marginal Prob of Burglary")
ggplot(daylag.effect, aes(DayLag, `TRUE`)) + geom_point() +
  labs(x = "Previous Day Total Number of Reported Burglaries by Police Beat", y = "Marginal Prob of Burglary")
ggplot(weeklag.effect, aes(WeekLag, `TRUE`)) + geom_point() +
  labs(x = "Previous Week Total Number of Reported Burglaries by Police Beat", y = "Marginal Prob of Burglary")
ggplot(monthlag.effect, aes(MonthLag, `TRUE`)) + geom_point() +
  labs(x = "Previous Month Total Number of Reported Burglaries by Police Beat", y = "Marginal Prob of Burglary")

## plot_pd(tod.effect)
## plot_pd(week.effect)
## plot_pd(week.tod.effect, facet = "TimeOfDay")
## plot_pd(month.effect)
## plot_pd(month.tod.effect, facet = "TimeOfDay")
## plot_pd(year.effect)

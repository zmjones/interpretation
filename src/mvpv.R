library(data.table)
library(edarf)
library(mmpf)
library(party)
library(ggplot2)

## load and transform data
dat = fread("./data/1990_2008_rep.csv")
dat$xpolity = as.factor(dat$xpolity)
dat[, war := ifelse(max_hostlevel == "war", 1, 0), ]
dat$newstate = factor(dat$newstate, c("not a recent entrant",
  "entry into system in last two years"))

## outcomes to predict and pretty labels for them
outcomes = c("latent_mean", "terror_killed", "terror_events", "war",
  "cwar_count", "cconflict_count", "osv_deaths", "nsv_deaths", "violent_protest",
  "nonviolent_protest")
outcome.names = c("Repression", "Terrorism (killed)", "Terrorism (events)",
  "War", "Civil War (count)", "Civil Conflict (count)", "Deaths (One-Sided)",
  "Deaths (Non-State)", "Violent Protest (count)", "Non-Violent Protest (count)")

## transform partial dependence output into plottable data.table
plot_transform = function(dat, names, id) {
  setDT(dat)
  setnames(dat, names(dat), names)
  melt(dat, id.vars = id)
}

## mark observations with missing outcome data to be dropped
## should only be a few observations
dropped = apply(is.na(dat[, outcomes, with = FALSE]), 1, any)

## fit a multivariate random forest
fit = cforest(latent_mean + terror_killed + terror_events +
  war + cwar_count + cconflict_count +
  osv_deaths + nsv_deaths + violent_protest + nonviolent_protest
  ~ year + newstate + pop + rgdppc + exclpop + oilpc + xpolity + durable,
  data = dat[!dropped, ])

fit.alt = cforest(latent_mean + terror_killed + terror_events +
  war + cwar_count + cconflict_count +
  osv_deaths + nsv_deaths + violent_protest + nonviolent_protest
  ~ year + newstate + pop + rgdppc + exclpop + oilpc + xpolity_nas + durable,
  data = dat[!dropped, ])

## partial dependence of xpolity
pd = partial_dependence(fit, "xpolity",
  n = c(17, nrow(dat[!dropped, ])), uniform = TRUE)
pd = plot_transform(pd, c("xpolity", outcome.names), "xpolity")
ggplot(pd, aes(xpolity, value)) + geom_point() +
  facet_wrap(~ variable, scale = "free_y", ncol = 3) +
  labs(y = "Marginal Prediction", x = "X-Polity (unordered)")
ggsave("figures/pd_mvpv.png", width = 10.5, height = 8)

## partial variance of xpolity for interaction detection
pd.var = partial_dependence(fit, "xpolity", interaction = TRUE,
  n = c(17, nrow(dat[!dropped, ])),
  uniform = TRUE, aggregate.fun = var)
pd.var = plot_transform(pd.var, c("xpolity", outcome.names), "xpolity")
ggplot(pd.var, aes(xpolity, value)) + geom_point() +
  facet_wrap(~ variable, scale = "free_y", ncol = 3) +
  labs(y = "Predicted Variance", x = "X-Polity (unordered)")
ggsave("figures/pd_mvpv_var.png", width = 10.5, height = 8)

## partial dependence of xpolity and real gdppc
pd.int = partial_dependence(fit, c("xpolity", "exclpop"),
  n = c(18, 100), interaction = TRUE, uniform = TRUE)
pd.int = plot_transform(pd.int, c("xpolity", "exclpop", outcome.names),
  c("xpolity", "exclpop"))

pd.int.alt = partial_dependence(fit.alt, c("xpolity_nas", "exclpop"),
  n = c(15, 100), interaction = TRUE, uniform = TRUE)
pd.int.alt = plot_transform(pd.int.alt, c("xpolity_nas", "exclpop", outcome.names),
  c("xpolity_nas", "exclpop"))


## plots!
ggplot(pd.int[variable == "Terrorism (events)", ], aes(exclpop, value)) +
  geom_point() + geom_line() + 
  facet_wrap(~ xpolity, scales = "free") +
  labs(x = "Excluded Population %", y = "Terrorism (events)")
ggsave("figures/pd_mvpv_int_terrorism.png", width = 10.5, height = 8)

dat[exclpop < .1 & xpolity == -66, ]
## 346: Bosnia-Herzegovina (1996-2008) (.01)
## 645: Iraq (0)
## 700: Afghanistan (0)

## out = dat[exclpop > .25 & exclpop < .375 & xpolity != -66, ]
## out$name = countrycode(out$ccode, "cown", "country.name")
## summary(out)

ggplot(pd.int[variable == "Terrorism (killed)", ], aes(exclpop, value)) +
  geom_point() + geom_line() + 
  facet_wrap(~ xpolity, scales = "free") +
  labs(x = "Excluded Population %", y = "Terrorism (killed)")
ggsave("figures/pd_mvpv_int_terrorism.png", width = 10.5, height = 8)

ggplot(pd.int[variable == "Deaths (Non-State)", ], aes(exclpop, value)) +
  geom_point() + geom_line() + facet_wrap(~ xpolity) +
  labs(x = "Excluded Population %", y = "Deaths (Non-State)")
## ggsave("figures/pd_mvpv_int_repression.png", width = 10.5, height = 8)

## permutation importance of xpolity on outcomes
## this has to be a custom thing since this is a multivariate regression
features = c("year", "newstate", "pop", "rgdppc", "exclpop", "oilpc",
  "xpolity", "durable")
feature.names = c("Year", "New State", "Population", "Real GDP per Capita",
  "% Population Excluded", "% Oil Revenue", "X-Polity", "Regime Durability (Polity)")
## create the permuted design matrix
pdat = lapply(features, function(x)
  makePermutedDesign(data = as.data.frame(dat[!dropped, ]), vars = x, nperm = 2))
pdat = rbindlist(pdat, idcol = "feature.id")
## compute predictions on the design
ppred = predict(fit, newdata = pdat)
ppred = as.data.frame(do.call(rbind, ppred))
setDT(ppred)
ppred$id = seq_len(nrow(ppred))
pdat$id = seq_len(nrow(pdat))
## compute the sample average loss for the predictions on permuted data
pid = merge(pdat[, c("id", "feature.id", outcomes), with = FALSE], ppred, by = "id")
pimp = (pid[, grepl("*\\.x$", names(pid)), with = FALSE] -
          pid[, grepl("*\\.y$", names(pid)), with = FALSE])^2
pimp = data.table(pimp)
setnames(pimp, names(pimp), gsub("\\.x$", "", names(pimp)))
pimp$feature = features[pdat$feature.id]
pimp = pimp[, lapply(.SD, mean), by = feature]
pimp$feature.names = feature.names
## rows show, for a given feature, the mean increase in squared error
## from permuting said feature M times averaged over the unpermuted training
## data for the other features

## get unpermuted predictions and compute sample-average loss
preds = predict(fit, newdata = dat[!dropped, ])
preds = as.data.frame(do.call(rbind, preds))
setDT(preds)
preds$id = seq_len(nrow(preds))
dat.outcomes = dat[!dropped, outcomes, with = FALSE]
dat.outcomes$id = seq_len(nrow(dat.outcomes))
m.dat = merge(preds, dat.outcomes, by = "id")
baseline = (m.dat[, grepl("*\\.x$", names(m.dat)), with = FALSE] -
                      m.dat[, grepl("*\\.y$", names(m.dat)), with = FALSE])^2
baseline = data.table(baseline)
setnames(baseline, names(baseline), gsub("\\.x$", "", names(baseline)))
baseline[, id := NULL]
baseline = baseline[, lapply(.SD, mean)]
baseline = cartesianExpand(data.table(feature = features), baseline)
out = merge(pimp, baseline, by = "feature")
out = out[, grepl("*\\.x$", names(out)), with = FALSE] -
  out[, grepl("*\\.y$", names(out)), with = FALSE]
out$feature = pimp$feature.names
setnames(out, names(out), gsub("\\.x$", "", names(out)))
setnames(out, names(out), c(outcome.names, "feature"))

## melt and plot
out = melt(out, id.vars = "feature")
ggplot(out, aes(feature, value)) + geom_point() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~ variable, scales = "free_y", nrow = 2) +
  labs(x = NULL, y = "Expected Error from Permutation")
ggsave("imp_mvpv.png", width = 10, height = 6)

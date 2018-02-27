library(data.table)

dat = fread("./data/1990_2008_rep.csv")
dat$xpolity = as.factor(dat$xpolity)
dat[, war := ifelse(max_hostlevel == "war", 1, 0), ]
dat$newstate = factor(dat$newstate, c("not a recent entrant",
  "entry into system in last two years"))

library(edarf)
library(party)

outcomes = c("latent_mean", "terror_killed", "terror_events", "war",
  "cwar_count", "cconflict_count", "osv_deaths", "nsv_deaths", "violent_protest",
  "nonviolent_protest")

dropped = apply(is.na(dat[, outcomes, with = FALSE]), 1, any)

fit = cforest(latent_mean + terror_killed + terror_events +
  war + cwar_count + cconflict_count +
  osv_deaths + nsv_deaths + violent_protest + nonviolent_protest
  ~ year + newstate + pop + rgdppc + exclpop + oilpc + xpolity + durable,
  data = dat[!dropped, ])

pd = partial_dependence(fit, "xpolity",
  n = c(17, nrow(dat[!dropped, ])), uniform = TRUE)

setDT(pd)
setnames(pd,
  names(pd),
  c("X-Polity (unordered)", "Repression", "Terrorism (killed)", "Terrorism (events)",
    "War", "Civil War (count)", "Civil Conflict (count)", "Deaths (One-Sided)",
    "Deaths (Non-State)", "Violent Protest (count)", "Non-Violent Protest (count)")
)
pd = melt(pd, id.vars = "X-Polity (unordered)")

library(ggplot2)
ggplot(pd, aes(`X-Polity (unordered)`, value)) + geom_point() +
  facet_wrap(~ variable, scale = "free_y", ncol = 3) +
  labs(y = "Predicted Value")
ggsave("figures/pd_mvpv.png", width = 10.5, height = 8)

pd.var = partial_dependence(fit, "xpolity", n = c(17, nrow(dat[!dropped, ])),
  uniform = TRUE, aggregate.fun = var)

setDT(pd.var)
setnames(pd.var,
  names(pd.var),
  c("X-Polity (unordered)", "Repression", "Terrorism (killed)", "Terrorism (events)",
    "War", "Civil War (count)", "Civil Conflict (count)", "Deaths (One-Sided)",
    "Deaths (Non-State)", "Violent Protest (count)", "Non-Violent Protest (count)")
)
pd.var = melt(pd.var, id.vars = "X-Polity (unordered)")
ggplot(pd.var, aes(`X-Polity (unordered)`, value)) + geom_point() +
  facet_wrap(~ variable, scale = "free_y", ncol = 3) +
  labs(y = "Predicted Variance")
ggsave("figures/pd_mvpv_var.png", width = 10.5, height = 8)

pd.int = partial_dependence(fit, c("xpolity", "rgdppc"),
  n = c(17, nrow(dat[!dropped, ])), uniform = TRUE)

## transforma and plot

imp = permutationImportance(dat[!dropped, ], "xpolity", outcomes, fit)

## transforma and plot

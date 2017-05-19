set.seed(1987)

library(partykit)
library(mmpf)
library(randomForest)
library(data.table)
library(ggplot2)
library(gridExtra)

n = 5000
x = as.integer(sample(c(-1, 0, 1), n, TRUE))
w = runif(n, -2, 2)
v = runif(n, -2, 2)
z = runif(n, -2, 2)
f = function(w, x, v, z) x + v^2 + x * w + sin(z)
F = f(w, x, v, z)
predict.fun = function(object, newdata) f(newdata$w, newdata$x, newdata$v, newdata$z)
data = data.frame(w, x, v, z)
e = rnorm(n)
Fn = F + e

model = ctree(Fn ~ ., data.frame(x, w, v, z, Fn),
  control = ctree_control(minprob = .4))

png("figures/tree.png", width = 1700, height = 1080, pointsize = 22)
plot(model, type = "simple", inner_panel = node_inner(model, pval = FALSE))
dev.off()

effects = list("x", "v", c("w", "x"), "z")
effects.names = sapply(effects, function(x) paste0(x, collapse = ":"))
## effects.var = list("x" = var(x),
##   "v" = var(v^2),
##   "w:x" = var(w * x),
##   "z" = var(sin(z))
## )

fit = randomForest(data, Fn, ntree = 1000, mtry = 2)
mp = lapply(effects, function(u) marginalPrediction(data, u, c(50, 2000), fit))
mp = lapply(mp, function(x) {
  x$preds = x$preds - mean(Fn)
  x
})
names(mp) = effects.names
mp$`w:x`$preds = mp$`w:x`$preds - mp$`x`$preds
pd = mp
mp = rbindlist(mp, fill = TRUE, idcol = "effect")
noiseless = lapply(effects, function(u)
  marginalPrediction(data, u, c(50, 2000), NULL,
    predict.fun = predict.fun)$preds - mean(Fn))
names(noiseless) = effects.names
noiseless$`w:x` = noiseless$`w:x` - noiseless$`x`
pd.noiseless = noiseless
mp$noiseless = do.call("c", noiseless)
names(mp)[3] = "randomForest"
mp$x = factor(mp$x, label = paste0("x = ", c(-1, 0, 1)))

to.extract = c("randomForest", "noiseless")
png("figures/pd.png", 12, 6, "in", res = 1000, pointsize = 20)
grid.arrange(
  ggplot(melt(mp[effect == "x", c("x", to.extract), with = FALSE],
    id.vars = "x", variable.name = "method"),
    aes(x, value, color = method)) + geom_point() +
    labs(y = expression(f(x) == x)),
  ggplot(melt(mp[effect == "v", c("v", to.extract), with = FALSE],
    id.vars = "v", variable.name = "method"),
    aes(v, value, color = method)) + geom_line() +
    labs(y = expression(f(v) == v^2)),
  ggplot(melt(mp[effect == "w:x", c("w", "x", to.extract),
    with = FALSE], id.vars = c("x", "w"), variable.name = "method"),
    aes(w, value, color = method)) + facet_wrap(~ x) + geom_line() +
    labs(y = expression(f(w, x) == sum(I(x == j) * w, j == -1, 1))),
  ggplot(melt(mp[effect == "z", c("z", to.extract), with = FALSE],
    id.vars = "z", variable.name = "method"),
    aes(z, value, color = method)) + geom_line() +
    labs(y = expression(f(z) == sin(x))),
  ncol = 2
)
dev.off()

truth = list(
  "x" = var(pd[[1]]$x),
  "v" = var(pd[[2]]$v^2),
  "w:x" = var(pd[[3]]$w * pd[[3]]$x),
  "z" = var(sin(pd[[4]]$z))
)
pd = lapply(pd, function(x) var(x$preds))
pd.noiseless = lapply(pd.noiseless, var)

pd.imp = data.table(
  "effect" = effects.names,
  "randomForest" = unlist(pd),
  "noiseless" = unlist(pd.noiseless),
  "truth" = unlist(truth)
)
pd.imp = melt(pd.imp, id.vars = "effect", variable.name = "method",
  value.name = "variance")
ggplot(pd.imp, aes(effect, variance, color = method)) +
  geom_point(position = position_jitter(width = 0.05, height = 0.05))
ggsave("figures/pd_variance.png", width = 10, height = 5)

pi = sapply(effects, function(u)
  permutationImportance(data.frame(data, Fn), u, "Fn", fit, 500))
pi.noiseless = sapply(effects, function(u)
  permutationImportance(data.frame(data, Fn), u, "Fn", NULL, predict.fun = predict.fun))
pi = data.table("randomForest" = pi, "noiseless" = pi.noiseless,
  "effect" = effects.names)
pi = melt(pi, id.vars = "effect")
pi[, ranks := rank(value), by = variable]
ggplot(pi, aes(effect, value, color = variable)) + geom_point() +
  labs(y = "permutation importance")
ggsave("pi.png", width = 8, height = 5)
ggplot(pi, aes(effect, ranks, color = variable)) + geom_point() +
  labs(y = "ranked permutation importance")
ggsave("figures/pi_rank.png", width = 8, height = 5)

effects = c("w", "x", "v", "z")
mp.var = lapply(effects, function(u) marginalPrediction(data, u, c(25, 1000),
  fit, aggregate.fun = var))
names(mp.var) = effects
mp.var = rbindlist(mp.var, fill = TRUE, idcol = "effect")
noiseless.var = lapply(effects, function(u) marginalPrediction(data, u, c(25, 1000),
  NULL, predict.fun = predict.fun, aggregate.fun = var)$preds)
mp.var$noiseless = do.call("c", noiseless.var)
names(mp.var)[3] = "randomForest"
mp.var = melt(mp.var, id.vars = c("effect", to.extract), na.rm = TRUE)
mp.var = melt(mp.var, id.vars = c("effect", "variable", "value"),
  value.name = "marginal variance", variable.name = "method")
ggplot(mp.var, aes(value, `marginal variance`, color = method)) +
  geom_point() + geom_line() + facet_wrap(~ effect, scales = "free_x") +
  labs(y = "marginal variance")
ggsave("figures/int.png", width = 8, height = 5)

## fit = aov(f ~ x + y + w:x + z, data.frame(data, f = f(w, x, y, z)))
## library(fanova)
## fa = functionalANOVA(data, c("x", "y"), c(10, 100), NULL, predict.fun)
## ggplot(fa[effect == "x", ], aes(x, f)) + geom_line() + geom_point()
## ggplot(fa[effect == "y", ], aes(y, f)) + geom_line() + geom_point()
## ggplot(fa[effect == "x:y", ], aes(x, y, fill = f)) + geom_raster()


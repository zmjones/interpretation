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

png("tree.png", width = 1700, height = 1080, pointsize = 22)
plot(model, type = "simple", inner_panel = node_inner(model, pval = FALSE))
dev.off()

effects = list("x", "v", c("w", "x"), "z")
effects.names = sapply(effects, function(x) paste0(x, collapse = ":"))

fit = randomForest(data, Fn, ntree = 1000, mtry = 2)
mp = lapply(effects, function(u) marginalPrediction(data, u, c(25, 1000), fit))
names(mp) = effects.names
mp = rbindlist(mp, fill = TRUE, idcol = "effect")
noiseless = lapply(effects, function(u)
  marginalPrediction(data, u, c(25, 100), NULL, predict.fun = predict.fun)$preds)
mp$noiseless = do.call("c", noiseless)
mp$x = factor(mp$x, label = paste0("x = ", c(-1, 0, 1)))
names(mp)[3] = "randomForest"

to.extract = c("randomForest", "noiseless")
png("pd.png", 12, 6, "in", res = 1000, pointsize = 20)
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

pi = sapply(c(effects, "w"), function(u)
  permutationImportance(data.frame(data, F), u, "F", fit, 500))
## truth = sapply(effects, function(u)
##   permutationImportance(data.frame(data, F)), u, "F", fit, 1000)
pi = data.table("value" = pi, "effect" = effects.names)
ggplot(pi, aes(effect, value)) + geom_bar(stat = "identity") +
  labs(y = "permutation importance")
ggsave("pi.png", width = 8, height = 5)

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
ggsave("int.png", width = 8, height = 5)

## fit = aov(f ~ x + y + w:x + z, data.frame(data, f = f(w, x, y, z)))
## library(fanova)
## fa = functionalANOVA(data, c("x", "y"), c(10, 100), NULL, predict.fun)
## ggplot(fa[effect == "x", ], aes(x, f)) + geom_line() + geom_point()
## ggplot(fa[effect == "y", ], aes(y, f)) + geom_line() + geom_point()
## ggplot(fa[effect == "x:y", ], aes(x, y, fill = f)) + geom_raster()


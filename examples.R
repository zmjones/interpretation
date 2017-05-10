set.seed(1987)

## make tree plot
library(partykit)
library(mmpf)
library(randomForest)
library(data.table)
library(ggplot2)
library(gridExtra)

n = 5000
x = as.integer(sample(c(-1, 0, 1), n, TRUE))
w = runif(n, -2, 2)
y = runif(n, -2, 2)
z = runif(n, -2, 2)
f = function(w, x, y, z) x + y^2 + x * w + sin(z)
F = f(w, x, y, z)
predict.fun = function(object, newdata) f(newdata$w, newdata$x, newdata$y, newdata$z)
data = data.frame(w, x, y, z)
e = rnorm(n)
Fn = F + e

model = ctree(Fn ~ ., data.frame(x, w, y, z, Fn),
  control = ctree_control(minprob = .4))

png("tree.png", width = 1700, height = 1080, pointsize = 22)
plot(model, type = "simple", inner_panel = node_inner(model, pval = FALSE))
dev.off()

effects = list("x", "y", c("w", "x"), "z")
effects.names = sapply(effects, function(x) paste0(x, collapse = ":"))

fit = randomForest(data, Fn, ntree = 1000, mtry = 2)
mp = lapply(effects, function(u) marginalPrediction(data, u, c(25, 100), fit))
names(mp) = effects.names
mp = rbindlist(mp, fill = TRUE, idcol = "effect")
truth = lapply(effects, function(u)
  marginalPrediction(data, u, c(25, 100), NULL, predict.fun = predict.fun)$preds)
mp$truth = do.call("c", truth)
mp$x = factor(mp$x, label = paste0("x = ", c(-1, 0, 1)))

png("pd.png", 12, 8, "in", res = 1200)
grid.arrange(
  ggplot(mp[effect == "x", ], aes(x, preds, group = 1)) + geom_point() +
    geom_point(aes(x, truth), color = "red") +
    labs(y = expression(hat(f)(x))),
  ggplot(mp[effect == "y", ], aes(y, preds)) + geom_line() +
    geom_line(aes(y, truth), color = "red") +
    labs(y = expression(hat(f)(y))),
  ggplot(mp[effect == "w:x", ], aes(w, preds)) + facet_wrap(~ x) + geom_line() +
    geom_line(aes(w, truth), color = "red") +
    labs(y = expression(hat(f)(w, x))),
  ggplot(mp[effect == "z", ], aes(z, preds)) + geom_line() +
    geom_line(aes(z, truth), color = "red") +
    labs(y = expression(hat(f)(z))),
  ncol = 2
)
dev.off()

pi = sapply(effects, function(u)
  permutationImportance(data.frame(data, F), u, "F", fit, 1000))
## truth = sapply(effects, function(u)
##   permutationImportance(data.frame(data, F)), u, "F", fit, 1000)
pi = data.table("value" = pi, "effect" = effects.names)
ggplot(pi, aes(effect, value)) + geom_bar(stat = "identity") +
  labs(y = "permutation importance")
ggsave("pi.png", width = 8, height = 5)

## fit = aov(f ~ x + y + w:x + z, data.frame(data, f = f(w, x, y, z)))
## library(fanova)
## fa = functionalANOVA(data, c("x", "y"), c(10, 100), NULL, predict.fun)
## ggplot(fa[effect == "x", ], aes(x, f)) + geom_line() + geom_point()
## ggplot(fa[effect == "y", ], aes(y, f)) + geom_line() + geom_point()
## ggplot(fa[effect == "x:y", ], aes(x, y, fill = f)) + geom_raster()


set.seed(1987)

library(partykit)
library(mmpf)
library(data.table)
library(ggplot2)
library(gridExtra)

n = 5000
x = as.integer(sample(c(-1, 0, 1), n, TRUE))
w = runif(n, -2, 2)
v = runif(n, -2, 2)
z = runif(n, -2, 2)
f.x = function(x) ifelse(is.na(x), 0, x)
f.v = function(v) ifelse(is.na(v), 0, v^2)
f.w = function(w) ifelse(is.na(w), 0, w)
f.xw = function(x, w) ifelse(is.na(x) | is.na(w), 0, x * w)
f.z = function(z) ifelse(is.na(z), 0, sin(z))
f = function(w, x, v, z) f.x(x) + f.v(v) + f.xw(x, w) + f.w(w) + f.z(z)
F = f(w, x, v, z)
predict.fun = function(object, newdata) f(newdata$w, newdata$x, newdata$v, newdata$z)
data = data.frame(w, x, v, z)
e = rnorm(n)
y = F + e

model = ctree(y ~ ., data.frame(x, w, v, z, y),
  control = ctree_control(minprob = .4, mtry = 0))
model = cforest(y ~ x + v + w + z, ntree = 1000)

png("figures/tree.png", width = 1700, height = 1080, pointsize = 22)
plot(model, type = "simple", inner_panel = node_inner(model, pval = FALSE))
dev.off()

x.grid = uniformGrid(x, 3)
d.mat = cartesianExpand(data.table(x = x.grid), data[, c("w", "v", "z")])
p.vec = predict(model, newdata = d.mat)
p.mat = data.table(y.hat = p.vec, d.mat)
p.fun = function(x) list(mean(x), var(x))
p.mat[, c("pd", "p.var") := p.fun(y.hat), by = x]
names(p.mat) = c("hat(f)(x, w, v, z)", "x", "v", "w", "z", "hat(f)(x)",
  "var(hat(f)(x))")
p.mat = round(p.mat, 3)
tt = ttheme_default(colhead = list(fg_params = list(parse = TRUE)))

png("figures/pd_tab.png", 5, 10, "in", res = 1200)
grid.arrange(
  tableGrob(head(p.mat[`x` == -1, ], 10), rows = NULL, theme = tt),
  tableGrob(head(p.mat[`x` == 0, ], 10), rows = NULL, theme = tt),
  tableGrob(head(p.mat[`x` == 1, ], 10), rows = NULL, theme = tt),
  ncol = 1
)
dev.off()

pd = partial_dependence(model, c("x", "w", "v", "z"), c(10, 100), FALSE, TRUE, data)
pd$f = predict.fun(NULL, pd[, c("x", "w", "v", "z")])
names(pd)[5] = "hat(y)"
pd = melt(pd, na.rm = TRUE, id.vars = c("hat(y)", "f"), parse = TRUE)
pd = melt(pd, id.vars = c("variable", "value"), variable.name = "model",
  value.name = "pred")

ggplot(pd, aes(value, pred, color = model)) + geom_point() + geom_line() +
  facet_wrap(~ variable, scales = "free") +
  theme(legend.title = element_blank()) +
  labs(x = "covariate value", y = "marginal prediction")
ggsave("figures/pd.png", width = 8, height = 4)

predict.both = function(object, newdata) {
  data.table("f" = f(newdata$w, newdata$x, newdata$v, newdata$z),
    "y" = predict(object, newdata))
}

pd.var = rbindlist(lapply(c("x", "w", "v", "z"), function(feature)
  marginalPrediction(data, feature, c(10, 100),
    model = model,
    aggregate.fun = var,
    predict.fun = predict.both)),
  fill = TRUE)

pd.var = melt(pd.var, id.vars = c("f", "y"), na.rm = TRUE)
pd.var = melt(pd.var, id.vars = c("variable", "value"),
  variable.name = "model", value.name = "pred")

ggplot(pd.var, aes(value, pred, color = model)) + geom_point() + geom_line() +
  facet_wrap(~ variable, scales = "free_x") +
  theme(legend.title = element_blank()) +
  labs(x = "covariate value", y = "variance of marginal prediction")
ggsave("figures/pd_var.png", width = 8, height = 4)


pd.int = partial_dependence(model, c("x", "w"), c(10, 100), TRUE, TRUE, data)
pd.int$f = predict.fun(NULL, data.table(pd.int[, c("x", "w")], v = NA, z = NA))
names(pd.int)[3] = "hat(y)"
pd.int = melt(pd.int, id.vars = c("x", "w"))

ggplot(pd.int, aes(w, value, color = variable)) +
  geom_point() + geom_line() +
  facet_wrap(~ x) +
  theme(legend.title = element_blank()) +
  labs(x = "covariate value", y = "marginal prediction")
ggsave("figures/pd_int.png", width = 8, height = 4)

# Title

Hello everyone, thanks for inviting me.

# Introduction

Today I'm going to talk to you about how we can use statistical learning methods in political science.

Statistical learning methods, which were largely developed by computer scientists, are designed to minimize out-of-sample prediction errors.

These methods make small out-of-sample prediction errors because they learn complex nonlinearities and interactions amongst explanatory variables without prespecification.

They are, however, uninterpretable.

This makes them unusable in the social sciences, where our goal is not pure prediction, but instead explanation and the evaluation of theory.

My work has focused on making statistical learning methods usable in political science.

To do this I have developed easy-to-use software which makes statistical learning methods interpretable.

This allows us to use these methods to evaluate and elaborate our theories without having to make unecessary assumptions.

I am going to demonstrate this with two examples from my research on state repression and political violence.

# Repression (Social Movements)

I think we all agree that social science is **hard**.

The reason that it is hard is because social phenomena are driven by complex processes.

As I said, I'm particularly interested in explaining state repression.

I'm going to show you a simplistic model of state repression just to illustrate that even simple models of social phenomena can become very complicated very quickly.

Social movements often induce repression, and external actors sometimes create or encourage such movements.

# Represssion (Economic Opportunities)

A lack of economic opportunities can provide fertile ground for social movements.

# Repression (Demographics)

Demographics can affect and be affected by economic opportunities.

Demographics can also make social mobilization more or less likely.

# Repression (Regime Type)

Regime type of course also matters.

The relationship between economics and political institutions is the subject of an enormous literature.

Regime type is also related to demographics and social movements.

The red lines here represent interactions between these factors.

There are lots of interactions in social processes.

# Conventional Data Analysis in the Social Sciences

As social scientists we construct theories which explain social phenomena.

With data, we can test our theories by specifying empirical models, fitting them to our data, and interpreting them.

The conventional way of doing this is to use regression models.

Typically after a regression model is fit to the data, the estimated relationship between the explanatory variables specified by theory and the outcome variable are interpreted.

If the estimated relationships match theoretical expectations and the relationship is statistically significant, this is treated as evidence in support of the theory.

# Assumptions of Conventional Data Analysis

If we thought that repression was explained by the sum of the individual effects of each explanatory variable, we'd miss all of the interactions between them, the red arrows I showed before.

Not specifying those relationships amounts to assuming that they don't exist.

Even when those interactions are not of theoretical interest, assuming they don't exist can have a substantial impact on our conclusions.

# Problems with Conventional Data Analysis

The functional form, that is, the shape of the relationships between the explanatory variables and the outcome, is often not fully determined by theory. 

Although interactions and nonlinearities between variables of theoretical interest are sometimes specified, control variables are generally ignored.

Misspecifying the relationship between control variables, theoretically important variables, and the outcome, can make substantial differences in whether your model supports your theory.

Without theoretical guidance, the functional form of the control variables is arbitrary.

As a result many theoretical models imply a large number of possible empirical models, because there are many reasonable functional forms.

For example if I was interested in the relationship between state repression and human rights treaty status, I might want to control for the fact that autocracies sign such treaties for different reasons and at different rates and may also repress their people at higher rates than do democracies.

But it might not be the case that the relationship between regime type and repression is linear.

It is reasonable to suppose that highly autocratic states have to use less repression than states that are neither highly democratic nor highly autocratic.

This is the "more violence in the middle" hypothesis.

So we could enter a regime type and regime type squared terms

But this is just one of many plausible ways that we could specify this empirical model.

This gets even more difficult when we have more control variables.

It is often the case that different model specifications tested as part of a robustness check.

However, these robustness checks usually involve only a partial search over the set of possible models compatible with theory.

Additionally, it is difficult to choose which model from this set to interpret, and it is easy to chose one that confirms your theory, even though others might not.

Statistical learning methods offer a way to avoid this problem.

# Statistical Learning Methods

Statistical learning methods are synonomous with machine learning methods.

I use the term "statistical learning" rather than "machine learning" to emphasize that these methods can be analyzed in the same statistical framework as conventional methods.

As I mentioned before statistical learning methods generally have low out-of-sample prediction error.

And the reason for this, is that, given a set of explanatory variables, they can estimate complex interactions and nonlinearities automatically.

# Definitions

The key difference between conventional methods and statistical learning methods is that conventional methods use a fixed number of parameters.

If I specified a linear regression and fit it to some data, the number of regression coefficients would be the same regardless of how much data I had.

Statistical learning methods have a data-adaptive number of parameters.

The number of parameters in a model fit using statistical learning methods depends on the complexity of the data and how much data is available.

Many statistical learning methods are consistent estimators of both very complicated and very simple data generating functions.

If you give them enough data they can estimate just about function you can imagine.

# Decision Trees

A very simple type of statistical learning method is a decision tree.

This is a simple simulated example where we are going to use ideology and age to explain whether people are republicans or democrats.

Democrats are the D's and republicans are the R's.

Ideology is shown on the x-axis and age on the y-axis.

A decision tree estimates the relationship between age and ideology and party by grouping people into increasingly homogenous groups in terms of party identification, using the two covariates.

In the top right panel you can see that if we split people into these two groups using this vertical line the resulting groups are homogenous compared to what the data looked like before we grouped it.

If we predict that all of the people on the right are democrats, and all the people on the left are republicans, we only make a few errors, which are indicated by red.

If we additionally used age to group people by party id, we can see that in the bottom right the groups are even more homogenous. 

This grouping structure can be represented as a tree.

If we had a new person and we wanted to predict their party id, we would simply apply the rules that are defined by these lines.

You can think of each one of these lines as a parameter.

A decision tree would learn more of these parameters if the relationship between these explanatory variables and party id was more complicated, or if we had more data.

Already it is a little difficult to interpret the relationship between each explanatory variable and the tree's predictions.

There isn't a single number which represents the relationship between either explanatory variable and party identification.

This is a very simple statistical learning method.

More common types of statistical learning methods which use trees employ the average of hundreds or thousands of these trees.

This makes it all but impossible to directly interpret these types of models.

# Conventional versus Statistical Learning Methods

Here we have an explanatory variable x, which is related to the outcome y via a very nonlinear function: the sine function.

This relationship isn't deterministic, it is noisy.

The sample data are shown as gray dots.

The truth, the sine function, is the black line.

We can fit a linear model to this data, which amounts to the assumption that the functional form of the relationship between x and y is explained by two parameters: a slope and an intercept.

Clearly this does a very poor job.

A random forest, which is a type of statistical learning method composed of decision trees, does a pretty good job getting the functional form right.

This was accomplished without specifying that the relationship was nonlinear in any way.

# Why Don't We Use Statistical Learning Methods?

Statistical learning methods aren't used because they aren't interpretable and interpretability is necessary for evaluating theory.

However, there are methods which can make statistical learning methods interpretable, which allows them to be used by social scientists for explanation.

I have written software that makes these methods easy-to-use and I'm going to show you some of my substantive reasearch where I apply these methods.

But first, I want to talk a little about what I mean by interpretability.

# Interpreting Models

Interpreting models is how we evaluate theory.

We use theory to specify empirical models, we fit those models to our data, and then we look to see whether the empirical model fits with our theory.

Interpretability is at a certain level the same thing as simplicity.

Like parsimony in theoretical models this simplicity is attractive, but parsimony is only appropriate if the parsimonious model is also powerful.

Inappropriate parsimony is not what we want.

So if interpretability is more or less the same thing as simplicity, we should make our models only as simple as they have to be for us to be able to understand them.

# Components of Interpretability

There are four components of interpretability.

All of components refer to the interpretation of the relationship between a explanatory variable and an outcome.

I am going to focus on two of these components, size and shape.

Size is the strength of the relationship.

Shape is the functional form of the relationship.

Variability is whether or not the size or shape of the relationship varies with other expalantory variables: interaction.

Reliability refers to how stable or trustworthy this relationship is.

With conventional methods the strength of a relationship is defined by a regression coefficient.

The shape of a relationship is assumed when specifying the model.

In the case of a linear model this is the sign of the regression coefficient.

When nonlinear terms or interactions are used, a marginal effect can show the shape of the relationship.

Interactions are either prespecified or not.

Reliability is usually assessed using confidence intervals.

With statistical learning methods size can be assessed by using variable importance methods like permutation importance.

Shape can be estimated using partial dependence, which is a method similar to marginal effects. 

The shape of the relationships can be linear or nonlinear or even discontinuous depending on what is implied by the data.

There are a variety of methods of detecting interactions and quantifying reliability as well. 

These methods are implemented in my software and described in greater detail in my dissertation.

# Permutation Importance

Permutation importance is a method for assessing the strength of relationships.

So say I wanted to explain repression using civil wars and earthquakes.

If I fit a regression model with these two variables the coefficient for civil wars would be huge, because civil wars always generate a repressive respone, and the coefficient on earthquakes would be close to zero, because earthquakes have no relationship with repression.

If I took the civil wars variable and randomly shuffled it, this would break the relationship between civil war and repression in the data.

If I made predictions with this shuffled version of the civil wars variable, my predictions would be very bad, and my prediction error would go way up.

That is, my empirical model wouldn't explain repression very well.

If I shuffled the earthquakes variable this wouldn't increase prediction error, because there is no relationship to break. 

Earthquakes aren't very useful in explainaing repression.

So this is how permutation importance is computed.

It works with any model, regardless of how complex it is.

To compute permutation importance randomly shuffle an explanatory variable, or a group of explanatory variables, and estimate how much the prediction error changes.

I'm going to show you an analysis of state repression I did using permutation importance.

Many explanations have been proposed for state repression.

These explanations have been evaluated in the conventional manner I described earlier.

Danny and I wanted to avoid making any unwarranted functional form assumptions.

We used a random forest, which is a type of statistical learning method, to explain state repression using a large set of variables that have been found to have statistically significant relationships with repression.

This method avoids assumptions about the shape of the relationship between the explanatory variables and repression, as well as how the explanatory variables interact.

# Permutation Importance (Hill and Jones 2014)

This graph shows the permutation importance a subset of the explanatory variables we used in our analysis, where their importance is defined in terms of predicting a measure of state repression from Fariss' 2014 APSR paper.

On the x-axis the increase in prediction error from permuting the variable on the y-axis is shown.

In this particular figure this is the increase in mean squared error.

We found that some variables, like civil war and regime type, are both statistically significant and predictively important.

However, we found that many explanatory variables that were found to be statistical significant were unimportant predictors of state repression.

We did find that some understudied concepts, namely aspects of domestic legal institutions and demographic factors, were surprisingly important.

We also found that international factors were generally less important than domestic factors.

Although permutation importance directly answers how strong a relationship is, it doesn't tell us anything about the shape of the relationship.

# Partial Dependence (Friedman 2001)

Partial dependence can tell us what the shape of the relationship between an explanatory variable and the models' predictions looks like.

It is very similar to marginal effects.

A marginal effect is the derivative of the model with respect to one or more explanatory variables.

It tells us how much the models' predictions change as a result of changes in the explanatory variable.

In many cases the marginal effects of variables of theoretical interest depend on the values of the control variables.

It is common practice to simply set these control variables to their mean or modal values.

For example if GDP per capita and population were control variables, we might set them to their sample mean values of $500 and 5 million.

However it might not be the case that there are any countries with a population of 5 million and a GDP per capita of $500. 

In fact, this might be very unusual.

This can have a substantial impact on your estimated marginal effect.

A solution to this problem is to instead compute an average marginal effect.

An average marginal effect is a marginal effect estimated for every observation, and then averaged over all of the sample data.

This is essentially the same thing as partial dependence.

Now I'm going to show you a figure from a paper I am working on with Yon Lupu.

In this paper we are investigating support for the "more violence in the middle" hypothesis.

The "more violence in the middle" hypothesis says that states that are neither highly autocratic nor highly democratic should experience more violence, because they have neither the capacity to effectively repress dissent, nor the means to accomodate it.

This hypothesis has been studied using conventional methods.

Typically what people have done is include a regime type squared term to allow the empirical model to find U or inverse U relationships.

However, this hypothesis says nothing about the relationship between control variables and political violence, and they are conventionally entered into the empirical model in a linear and additive fashion.

We instead fit a multivariate random forest to jointly predict many types of political violence simultaneously while avoiding any unwarranted assumptions about the relationship between the controls and violence, and indeed not even specifying the relationship between regime type and violence.

# Partial Dependence (Jones and Lupu 2016)

This graph shows the partial dependence of X-UDS, which is a measure of regime type, on types of political violence, each indicate by a gray panel.

On the x-axis we have our measure of regime type, where values on the left indicate more autocratic states and values on the right indicate more democratic states.

The y-axis shows the partial dependence of this regime type measure on the above type of violence.

If this hypothesis is correct we would expect an inverse U relationship in each of these graphs.

If we'd used conventional methods to test this hypothesis, it would have been difficult to see all of the nuance that you can see in this graph, because we would have assumed that the relationship looked like an inverse U.

And again, we would have had to specify the functional form of the relationship between our control variables and these forms of political violence, which the hypothesis does not specify.

What we've found so far is limited support for the hypothesis.

Repression, miltarized interstate disputes which escalate to the use of force, and civil war onsets are all most common in autocracies.

Violent and non-violent protest is most common in democracies.

Killings from non-state and one-sided violence and terrorism appear to be the only forms of political violence which fit the hypothesis.

In the paper we also consider a number of other measures of regime type.

What we are finding is that which states are "in the middle" matters enormously.

States that are going through transition periods are often difficult to code and so are treated as missing or otherwise excluded.

Measurement and theorizing are still imporant with interpretable statistical learning methods.

# Software

Both of the empirical examples I've shown you were done using software that I've developed as part of my dissertation.

Prior to my work, using many of these methods was non-trivial in terms of technical expertise and time.

The software I have written makes them easy to use. 

I would argue that in some ways they are easier to use than conventional methods.

I have implemented one package, called edarf, which stands for exploratory data analylsis using random forests, which implements these methods in a way that is specific to random forests.

Random forests are a nice statistical learning method for us because they work with just about any type of outcome variables and they are relatively easy to fit.

I just published an article based on this package.

I also am a core developer of the mlr package, which stands for machine learning in R.

We have also just published a paper on this package.

The mlr package offers a comprehensive interface to nearly every statistical learning method implemented in R.

It also has all of the methods for interpretation I showed you today, as well as a number of ones that I didn't cover.

# Future Research

In the future I plan on continuing the practical and statistical development of these methods.

Although I am personally most interested in repression and political violence, I am also interested in collaborations with people interested in applying these methods.

# Conclusion

Statistical learning methods can now be used in social science for tasks other than prediction.

They can be used in conjunction with conventional methods as a robustness check, or on their own.

I actually just reviewed a very neat article for the APSR that used a combination of ethnography, conventional methods, and statistical learning methods as a robsutness check for the conventional methods.

I have tutorials, more technical details, and a video of another talk that I gave on this topic, as well as these slides on my "hire me" page.

Please check it out! Thanks!








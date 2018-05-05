% Interpretable Machine Learning Methods
% Zachary M. Jones

# Conventional Methods in (Observational) Social Science

 - lots of linear models of various flavors fit to tabular, labelled, data (features usually have meaning)
 - use of variance estimates/NHST as "importance"/validation/hurdle for publication
 - little model evaluation (strange epistemology)
 
<!--
i'm a political scientist but practically more like a quantitative historian

a lot of social science is like this in the sense that we analyze passively collected tabular data
looking for patterns

a lot of questions we've come up with can't be answered with experiments

and, also, because we often can't design experiments, the data we have are usually uncontrolled and
are obviously generated by complex processes

unsurprising since these are often large scale social systems (the economy, conflicts, etc.)

so it is pretty strange that we use the statistical models we do

the default is to use variations on linear models

these models are usually justified based on their statistical properties in synthetic scenarios that
would be extremely unusual outside of designed data

specifically one thing we often do (and i blame economics for this) is focus on unbiased estimators while ignoring variance

another thing we do is to use variance estimates or transformations thereof to make yes/no decisions about whether or not
results are important and therefore worthy of publication: p < .05

strangely this is often the closest thing to model validation we do: are coefficients on variables i expect to be significant significant and in the "right" direction

essentially we are using our intuition as a vague check on our empirical models
-->
 
# Problems

 - theory/experience suggests social systems are often complex and high dimensional
 - little reason to trust observational models without predictive validation
 - variance estimates are bogus
 
<!--

as is undoubtedly obvious i don't think this works particularly well

there are lots of reasons to think that uncontrolled social systems (and really controlled ones too) are very complex

describing such a system with an inappropriately simple model is not illuminating, it is obfuscating.

just because a model is simple doesn't mean it is useful

if the model does a poor job representing the system then it isn't much use usually

although ostensibly much of social science is about estimating causal effects i don't think in scenarios
where we can't experiment that we ought to trust models which don't predict well

ours usually don't (i don't think) and usually we don't bother to check

-->
 
# Goals

 - be (more) clear about our modeling goals
 - assume as little as possible
 - predictive validation
 
<!--

i think these problems are all fixable if we were more clear about what we were trying to do with our models

we assumed less in our models

and we tested them

-->

# Argument

machine learning methods

   + (generally) weakened functional form assumptions (+)
   + predictive power (+)
   + computational complexity (-)
   + uninterpretable black-box outputs (-)

meta-modeling can make any black-box function "interpretable"

<!--

my argument is that machine learning can help solve these problems

ml methods generally are designed to make good predictions and accomplish this by making few functional form assumptions and balancing bias and variance

the downside is that the computational complexity is sometimes problematic and that the outputs are often, by construction, not interpretable

the resulting model could be high dimensional or it could be just that it was estimated in such a way that it isn't easy or maybe even possible to grasp in totality what the model learned.

meta-modeling, that is, deconstructing an estimated model via another explicit or implicit model, is a way to make these black box models interpretable or understandable and can allow us to learn more from our data than how we've been doing things thus far

-->
   
# Contribution

 - software to interpret black-box models
   + `mlr`, `edarf`, `mmpf`, `fanova` in `R`
   + would like to contribute to scikit-learn as well
 - survey/re-analysis of prominent papers
 - applications
 
<!--

i've developed or helped develop a few packages in R that implement these interpretation methods and make them easier to use in the context of a "normal" data analysis pipeline

i'd also like to make this stuff available to python users in a similar way

i've also published a number of applications of these methods in political science and am working on re-analyzing a whole bunch of prominent papers

-->
 
# Interpretable Machine Learning

 - normal ML (preprocess, tune, evaluate, deploy)
 - meta-modeling on deployed model (or part of evaluation)
 
<!--

so what i mean by "interpretable machine learning" is "normal" supervised ML

that is, take some data, preprocess it, estimate and tune a model on it,
validate said model, and then deploy it

meta-modeling, or the "interpretablility" step can occur on the deployed model or as part of evaluation
which is sort-of what we do now: use our intiution about what a model "ought" to learn to evaluate it

-->


<!-- # Machine Learning in the Social Sciences

 - social sciences largely use simple methods
   + historical
   + representation of uncertainty?
   + interpretability
 - lots of industrial application (data science on people)
 - **F**airness **A**ccountability and **T**ransparency in **M**achine **L**earning
 -->
 
# Why Not Directly Estimate the Interpretable Model?

 - do predictions have to be made by an interpretable model?
 - what sort of interpretations are required? does all of the model need to be interpretable?
 - exploratory data anlysis and/or model evaluation (contrast prediction w/ explanatory model)
 
<!--

i think a reasonable question to ask is why we shouldn't directly estimate a model of the desired complexity

i haven't exactly convinced myself that i have all of the answers here but i have a few ideas

if predictions don't have to be made by an interpretable model then this gets you better predictions that you might otherwise have

there are lots of situations (maybe most?) in social science where we are only interested in part of a model really

in those cases it makes a lot of sense to let the other parts of the model be as complex as necessary; it doesn't matter that that part of the model is a black box

lastly i think it can be illuminating to look at the differences between the full complexity ML model and the explainable meta-model

-->
 
# Common Interpretation Tasks

 1. is this feature important
    + on its own? in combination with other features?
	+ what does important mean?
 2. what is shape of the relationship between this (these) feature(s) and the outcome(s)?
 3. how reliable is my model's representation of these things?
 
<!--

broadly i think there are 3 things we ask of our models

is this feature important?

is its importance modified by other features?

but what does important mean? i think often we really only have the colloquial definition of important in mind, which is why p-values and the ever-pernicious word "significant" are used for this purpose

we want to know the shape of the relationship between our features and our outcomes

and of course we want to know how reliable these things are

measuring reliability i think is a really difficult problem but is sort of a the core of "science" as we are ostensibly trying to find
patterns that generalize in some sense, and reliability speaks to how likely a pattern found in a sample will generalize to similar samples

-->
 
# Interpretation Methods

to decompose $\hat{f}$ or $\mathcal{L}(\hat{f})$

 - fit a constrained model to $\{\hat{f}, \mathbf{x}\}$ (e.g., a parametric or semi-parametric model)
 - marginalize out variables iteratively (e.g., $\mathbf{x}_{23}$ to obtain $f_1(x_1)$)
 
<!--
the interpretation methods i've worked with essentially do two things. they decompose the estimated model f-hat

or they decompose the variance of f-hat or the loss of f-hat in representing the target or outcome feature(s)

in both cases there are two ways of doing this that i am aware of

in one case you fit another simpler or somehow constrained-to-be-interpretable model using f-hat as your outcome

you can also iteratively marginalize out features, which amounts to basically the same thing
-->
 
# Meta-Models

partial or full factorization of $f(x_1, x_2, x_3)$
 
$$f_1(x1) + f_2(x_2) + f_3(x_3) + f_{12}(x_1, x_2) + f_{23}(x_2, x_3) + f_{123}(x_1, x_2, x_3)$$

"interpretability" is treated as a function of the dimension of the factors

<!--
so say we have our estimated model f which depends on 3 features and for now we are interested in learning about
how our model has used x1 to produce predictions

we could partially decompose f into two components f_1 + f_23

we could also fully decompose it which has the advantage of providing a more full picture of how the model 
used the features but also generally more computationally costly

i never really defined it but here my definition of "interpretable" is the dimensionality of the terms

the two basic things to do with these terms is to plot them and to compute summaries of their variability

e.g., line plots for the terms that depend on one feature

surface plots or similar for the terms that depend on two features

ranking the sample variance of the terms

basically all of my applied work has done these two things

and, to reiterate, i think this way of doing things is better than the status-quo because the model restrictions are far far weaker

the model is explicitly tuned for predictive performance rather than just fit to the sample data

i also think the quantites extracted are much closer to what social scientists want to ask than what is normally extracted
from linear type models and associated NHST

-->

# Estimation

pointwise estimation on a grid (points are effects)

$$\hat{f}(\mathbf{x}) \approx g_u(x_u) + \sum_{v \subset u} g_v(x_v) + g_{-u}(x_{-u}) + \sum_{i \in u \subset v^{\prime} \subseteq -i} g_{v^{\prime}}(x_{v^\prime})$$

# Political Violence (Lupu and Jones 2018)

![](figures/pd_uds_xpolity_1990_main.png)

# Repression (Hill and Jones 2014)

![](figures/eeesr.png)

# Problems

 - goals and how to evaluate them
 - variance estimation (additional error from approximation)
 
<!--

of course what i've described isn't a panacea

i think there are a ton of challenges to doing a "good" job analyzing these sorts of data

i don't think we have a firm idea what our overall goal is: that is, our epistemology is mixed up

some people sort of seem to want to create engineering quality knowledge

others want to describe the world

defining what the goal of a particular study is and how its success will be appropriately evaluated is extraordinarily important i think

relatedly i think estimating reliability is important but also very hard

i think everyone basically realizes the reliability estimates we have are often just total nonsense, but 

-->
 
# Future Problems/Directions

 - different ideas of interpretability (task-specific)
 - model evaluation
 - variance estimation
 - for python
 - FATML
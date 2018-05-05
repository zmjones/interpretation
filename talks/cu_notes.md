# Title

# Preview

 - necessity of exposition - preview
 - slm or ml ~ generalized better
   + known for out-of-sample
   + why?
   + interpretability - theory
   + solution
   + replacement - robustness
   + software
   
# Main Points

 - disadvantages of conventional methods
   + arbitrary functional forms
 - what SLMs offer
   + avoid arbitrary assumptions
   + learn complex relationships without presepecification
 - interpretability with SLMs
   + describe methods for any prediction fun
   + two empirical applications

# Common Features of Social Data

 - common ground
 - accuracy, reliability
 - compleixty
 
# Repression (Social Movements)

 - why?

 - social movements threatening
 - external influences
 - arab spring
 - spatial/network models
 
# Repression (Economic Opportunity)

 - wealth/economic opportunities distribution
 - structure of groups
 - outside ties
 - social mobilization
 - saddam, shia, gulf war, iran
 - intense study
 
# Repression (Demographics)

 - youth bulges
 - economic opportunities
 - empirical use
 
# Repression (Regime Type)

 - big effect
 - caused and caused by economics
 - ditto with demographics, social movements, and external influences
 
 - many other factors such as... treaties, ptas, oil rents, etc.
 
# Conventional Data Analysis in Political Science

 - data analysis problem
 - theory testing
 - use linear models
 - interpretation = theory test
 
# Assumptions of Conventional Data Analysis

 - assume additivity
 - missing interactions
   + social movements and regime type
   + economic opportunitiy and regime type
   + economic opportunitiy and demographics
 - conventional methods must presume these exist
 - omitting them is assuming they don't
 - complexity limits theory improvement
 
# Problems with Conventional Data Analysis

 - theory partial implies models
 - oil rents example
    + mechanism (resource curse)
	+ model specification
	+ linearity for oil rents
	+ theory evaluation
	+ what about controls?
  - many plausible model specifications
  - robustness checks
    + partial search
	+ evaluation criteria?
	
# Statistical Learning Methods

 - contrast: slm = ml
 - minimize out-of-sample error = generalizability
 - design/motivation: learns simple or complex dgps
 - consistency, not w/ conventional methods
 
# Definitions

 - fixed params
   + lm
   + regression
 
 - data adaptive params
   + decision trees, random forests, neural networks
   + few functional form restrictions
   + uninterpretable

# Decision Trees

 - setup
 - group outcomes using covariates
 - set of rules
 - rule cut points are parameters
 - generalizations
   + diverse ensembles
   + better predictions
   + less interpretable
   
# Conventional Vesus Statistical Learning Methods

 - setup
 - lm horrible
 - random forest, despite trees
 - bends = parameters
 
# Why Don't We Use Statistical Learning Methods to Analyze Our Data?

 - slms can do everything better, agree that social world complex
 - slms not generally interpretable - can't theory test
 - problem solved
 - class of methods, any method gen. predictions
 - describe a few
 - dissertation does better
 - software
 - interpretability definition
 
# Interpreting Models

 - interpretability = simplicity
 - stats = fewer params
 - parsimony good? - evaluation criteria
 - prior on complexity
 - lack of comparisons
 - conventional simpler than theories imply
 - assume less
 
# Components of Model Interpretation

 - size: importance of covariate(s) to model
 - shape: functional form between covariate(s) and model
 - variability: shape and size as fun of other covariates: interactions
 - reliability:
   + sampling variation
   + measurement error, operationalization
   + model choice
   + functional form assumptions
   + covariates
   + distance from data
   
# Interpreting Conventional Methods

 - easy
 
  - coefficient size
  - assume a lot about shape
    + sign
	+ marginal effects for nonlinear models or interactions
  - interactions: prespecified
  - reliability = confidence
  
# Interpreting Statistical Learning Methods

 - thought of as black box except special cases like CART

 - variable importance
 - functional form estimation
 - automatic interaction size/shape estimation
 - quantify reliability in two senses:
   - closeness to data
   - sampling
   
# Permutation Importance

 - shuffling important covariates increases prediction error
 
 - repression = earthquakes + civil war
   + civil war coef large because law of repressive response
   + earthquakes coef small because no relationship
   + shuffle civil wars variable breaks relationship
   + predict using shuffled variable, error goes up
   + shuffle earthquakes variable, no relationship to break
   + error stays the same
   
 - computing permutation importance
 - interactions
 
# Hill and Jones (2014)

 - large literature
 - many covariates, theories, papers
 - theory evaluation method
   + conventional methods
   + sign and significance
 - statistical significance = size, variability, information

 - civil war and regime type
   + big, not variable, always significant
   + measure repression!
   
 - theories don't say what to do with control variables
 - model specifications chosen are arbitrary and important!
 - incorrect assumptions can mask evidence for theories
 
 - random forest + permutation importance
   + don't assume model is additive or linear
   + can be interactions
 
 - found measurement issues
 
 - EXPLAIN GRAPH!
 
 - many statistically significant covariates not important
 - some understudied covariates were
   + legal institutions
   + demographics
 - international versus domestic factors

 - only estimates size, not shape
 
# Partial Dependence (Friedman 2001)

 - similar to marginal effects
 - estimates shape of relationships
 - marginal effects
   + definition
   + means and modes for control variables
   + no mean/modal countries example
 - partial dependence ~ average marginal effects
   + computation
 - any prediction method
 
# Partial Dependence (Jones and Lupu 2016)

 - MVM hypothesis
 - testing with regime type squared term
   + maybe wrong?
 - control variable specification
   + arbitrary
   + impactful
 - choosing plausible models hard
 - use out-of-sample error
   + SLMs minimize
   + manual search unecessary
   
 - political violence forms interrelated
 - model them simultaneously using rf w/ partial dependence
 
 - explain graph!
 
 - findings
   + autocracies (MIDS, civil war, repression)
   + middle (terrorism)
   + democracies (protest)
   
 - using different regime type measures
 - how "the middle" is coded
   + difficult to code states
 - measurement problems not fixed
 - makes it easier to find problems

# Future Research

 - motivation
 - dissertation = comprehensive
 - my interest in violence
   + collaboration
 - usefulness as a robustness check
 
# Conclusion

 - benefits of using SLMs
 - makes theory testing and development better
 
 - mlr
 - edarf

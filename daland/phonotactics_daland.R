library(readr)
library(ggplot2)
library(MASS)
library(ordinal)

rm(list=ls())

setwd("C:/hplaptop/4thYearUCI/PhonotacticsResearch/daland")

daland_data <- read_csv("daland_cleaned_metric_output.csv")
daland_data[3:16] = scale(daland_data[3:16])

uni_bi_model = polr(as.factor(rating) ~ uni_prob * bi_prob, data=daland_data, Hess=TRUE)
summary(uni_bi_model)

pos_uni_bi_model = polr(as.factor(rating) ~ pos_uni_score * pos_bi_score, data = daland_data, Hess=TRUE)
summary(pos_uni_bi_model)

pos_uni_bi_smoothed_model = polr(as.factor(rating) ~ pos_uni_score_smoothed * pos_bi_score_smoothed, 
                                 data = daland_data, Hess=TRUE)
summary(pos_uni_bi_smoothed_model)

uni_bi_smoothed_model = polr(as.factor(rating) ~ uni_prob * bi_prob_smoothed, data = daland_data, Hess=TRUE)
summary(uni_bi_smoothed_model)

uni_bi_freq_model = polr(as.factor(rating) ~ uni_prob_freq_weighted * bi_prob_freq_weighted, data=daland_data, Hess=TRUE)
summary(uni_bi_freq_model)

uni_bi_freq_smooth_model = polr(as.factor(rating) ~ uni_prob_freq_weighted * bi_prob_freq_weighted_smoothed,
                             data=daland_data, Hess=TRUE)
summary(uni_bi_freq_smooth_model)

pos_uni_bi_freq_model = polr(as.factor(rating) ~ pos_uni_score_freq_weighted * pos_bi_score_freq_weighted,
                             data=daland_data, Hess=TRUE)
summary(pos_uni_bi_freq_model)

pos_uni_bi_freq_smoothed_model = polr(as.factor(rating) ~ pos_uni_score_freq_weighted_smoothed * pos_bi_score_freq_weighted_smoothed,
                                      data=daland_data, Hess=TRUE)
summary(pos_uni_bi_freq_smoothed_model)

all_model_names = vector()
all_models = vector()
for (var in ls()) {
    if (endsWith(var, "model")) {
        all_model_names = append(all_model_names, var)
        all_models = append(all_models, get(var))
    }
}

num_models = length(all_model_names)

intercept1_2 = vector(mode="numeric", length=num_models)
intercept2_3 = vector(mode="numeric", length=num_models)
intercept3_4 = vector(mode="numeric", length=num_models)
intercept4_5 = vector(mode="numeric", length=num_models)
uni_coef = vector(mode="numeric", length=num_models)
uni_coef = vector(mode="numeric", length=num_models)
bi_coef = vector(mode="numeric", length=num_models)
interaction_coef = vector(mode="numeric", length=num_models)
AIC = vector(mode="numeric", length=num_models)

for (index in 1:num_models) {
    model = get(all_model_names[index])
    intercept1_2[index] = model[[2]][1]
    intercept2_3[index] = model[[2]][2]
    intercept3_4[index] = model[[2]][3]
    intercept4_5[index] = model[[2]][4]
    uni_coef[index] = coef(model)[1]
    bi_coef[index] = coef(model)[2]
    interaction_coef[index] = coef(model)[3]
    AIC[index] = AIC(model)
}

df = data.frame(intercept1_2, intercept2_3, intercept3_4, intercept4_5, uni_coef, 
                bi_coef, interaction_coef, AIC, row.names=all_model_names)
df

sorted_df = df[order(df$AIC),]
sorted_df

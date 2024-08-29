library(readr)
library(tidyverse)
library(lme4)
library(lmerTest)

rm(list = ls())

setwd("C:/hplaptop/4thYearUCI/PhonotacticsResearch/turkish")

# new file uses unigram smoothing, scale columns 5 to 20
# if using original file, don't use "new_" prefix and scale columns 5 to 18
turkish_data <- read_csv("new_turkish_cleaned_metric_output.csv")
turkish_data[5:20] = scale(turkish_data[5:20])

uni_bi_model = lmer(response ~ uni_prob * bi_prob + (1|word) + (1|ID), data=turkish_data)
summary(uni_bi_model)

pos_uni_bi_model = lmer(response ~ pos_uni_score * pos_bi_score + (1|word) + (1|ID), data = turkish_data)
summary(pos_uni_bi_model)

pos_uni_bi_smoothed_model = lmer(response ~ pos_uni_score_smoothed * pos_bi_score_smoothed + 
                                     (1|word) + (1|ID), data = turkish_data)
summary(pos_uni_bi_smoothed_model)

# for original metric output, use uni_prob column instead of uni_prob_smoothed
uni_bi_smoothed_model = lmer(response ~ uni_prob_smoothed * bi_prob_smoothed + (1|word) + (1|ID),
                             data = turkish_data)
summary(uni_bi_smoothed_model)

all_model_names = vector()
all_models = vector()
for (var in ls()) {
    if (endsWith(var, "model")) {
        all_model_names = append(all_model_names, var)
        all_models = append(all_models, get(var))
    }
}

model_comp = do.call(anova, as.list(all_models))
model_comp

num_models = length(all_models)

fixed_effects = sapply(all_models, FUN=fixef)

intercept = vector(mode="numeric", length=num_models)
uni_coef = vector(mode="numeric", length=num_models)
bi_coef = vector(mode="numeric", length=num_models)
interaction_coef = vector(mode="numeric", length=num_models)

for (index in 1:num_models) {
    intercept[index] = fixed_effects[(index-1) * 4 + 1]
    uni_coef[index] = fixed_effects[(index-1) * 4 + 2]
    bi_coef[index] = fixed_effects[(index-1) * 4 + 3]
    interaction_coef[index] = fixed_effects[(index-1) * 4 + 4]
}

df = data.frame(intercept, uni_coef, bi_coef, interaction_coef, model_comp[2], model_comp[3], model_comp[4], row.names=all_model_names)
df

sorted_df = df[order(df$AIC),]
sorted_df

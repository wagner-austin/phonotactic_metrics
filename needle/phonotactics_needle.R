library(readr)
library(tidyverse)
library(lme4)
library(lmerTest)

setwd("C:/hplaptop/4thYearUCI/PhonotacticsResearch/needle")

# new file uses unigram smoothing, scale columns 4 to 19
# if using original file, don't use "new_" prefix and scale columns 4 to 17
needle_data <- read_csv("new_needle_cleaned_metric_output.csv")
needle_data[4:19] = scale(needle_data[4:19])

uni_bi_model = lmer(rating ~ uni_prob * bi_prob + (1|word) + (1|subject), data=needle_data)
summary(uni_bi_model)

pos_uni_bi_model = lmer(rating ~ pos_uni_score * pos_bi_score + (1|word) + (1|subject), data = needle_data)
summary(pos_uni_bi_model)

pos_uni_bi_smoothed_model = lmer(rating ~ pos_uni_score_smoothed * pos_bi_score_smoothed + 
                                     (1|word) + (1|subject), data = needle_data)
summary(pos_uni_bi_smoothed_model)

# for original metric output, use uni_prob column instead of uni_prob_smoothed
uni_bi_smoothed_model = lmer(rating ~ uni_prob_smoothed * bi_prob_smoothed + (1|word) + (1|subject),
                             data = needle_data)
summary(uni_bi_smoothed_model)

model_comp = anova(uni_bi_model, pos_uni_bi_model, pos_uni_bi_smoothed_model, uni_bi_smoothed_model)
model_comp

all_models = list(uni_bi_model, pos_uni_bi_model, pos_uni_bi_smoothed_model, uni_bi_smoothed_model)


num_models = length(all_models)

fixed_effects = sapply(all_models, FUN=fixef)

intercept = vector(mode="numeric", length=num_models)
uni_coef = vector(mode="numeric", length=num_models)
bi_coef = vector(mode="numeric", length=num_models)
interaction_coef = vector(mode="numeric", length=num_models)

for (index in 1:num_models) {
    intercept[index] = fixed_effects[(index-1) * num_models + 1]
    uni_coef[index] = fixed_effects[(index-1) * num_models + 2]
    bi_coef[index] = fixed_effects[(index-1) * num_models + 3]
    interaction_coef[index] = fixed_effects[(index-1) * num_models + 4]
}

df = data.frame(intercept, uni_coef, bi_coef, interaction_coef, model_comp[2], model_comp[3], model_comp[4])
df

sorted_df = df[order(df$AIC),]
sorted_df

# phonotactics_daland.R - Linear regression models for phonotactic scores
# -------------------------------------------------------------------------
# This module fits 16 linear regression models based on various combinations of:
#   - Model Category: Positional vs. Non-Positional
#   - Normalization: Conditional vs. Joint
#   - Word Boundaries: With (wb) vs. Without (noWB)
#   - Aggregation: Sum vs. Product (log-product)
#
# Predictors are constructed from associated unigram and bigram score columns.
#
# Version: 1.0.1

library(readr)
library(ggplot2)
library(MASS)
library(ordinal)

rm(list=ls())

# Set working directory (update as needed)
setwd("C:/hplaptop/4thYearUCI/PhonotacticsResearch/daland")

# Read in data and scale predictor columns.
# If using the new file with smoothing, scale columns 3 to 18.
# For the original file, do not use the "new_" prefix and scale columns 3 to 16.
daland_data <- read_csv("new_daland_cleaned_metric_output.csv")
daland_data[3:18] <- scale(daland_data[3:18])

# ------------------------------------------------------------------------------
# Define model configurations for 16 linear regression models.
# ------------------------------------------------------------------------------
configs <- list()
for (model_category in c("nonpos", "pos")) {
  for (norm in c("conditional", "joint")) {
    for (bound in c("wb", "noWB")) {
      for (agg in c("sum", "prod")) {
        
        # Construct a unique model name based on the combination.
        model_name <- paste(model_category, norm, bound, agg, sep = "_")
        
        # Determine the unigram predictor column.
        if (model_category == "nonpos") {
          if (norm == "conditional") {
            uni <- "uni_prob"
          } else {  # joint
            uni <- "uni_joint_nonpos"
          }
        } else {  # positional models
          if (norm == "conditional") {
            uni <- if (agg == "sum") "pos_uni_score_cond" else "pos_uni_score_cond_prod"
          } else {  # joint
            uni <- if (agg == "sum") "pos_uni_score" else "pos_uni_score_prod"
          }
        }
        
        # Determine the bigram predictor column.
        if (model_category == "nonpos") {
          if (norm == "conditional") {
            bi <- if (bound == "wb") "bi_cond_nonpos_wb" else "bi_cond_nonpos_noWB"
          } else {  # joint
            bi <- if (bound == "wb") "bi_joint_nonpos_wb" else "bi_joint_nonpos_noWB"
          }
        } else {  # positional models
          if (norm == "conditional") {
            bi <- if (bound == "wb") "bi_cond_pos_wb" else "bi_cond_pos_noWB"
          } else {  # joint
            bi <- if (bound == "wb") "bi_joint_pos_wb" else "bi_joint_pos_noWB"
          }
        }
        
        # For non-positional models, if aggregation is product, append "_prod"
        # (For positional models the column names already incorporate the aggregation type.)
        if (agg == "prod" && model_category == "nonpos") {
          if (!grepl("_prod$", uni)) {
            uni <- paste0(uni, "_prod")
          }
          if (!grepl("_prod$", bi)) {
            bi <- paste0(bi, "_prod")
          }
        }
        
        configs[[model_name]] <- list(uni = uni, bi = bi)
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Function: fit_models
# Purpose: Fit all linear regression models based on configurations.
# Returns: A named list of fitted glm model objects.
# ------------------------------------------------------------------------------
fit_models <- function(data, configs) {
  models <- list()
  for (name in names(configs)) {
    uni_col <- configs[[name]]$uni
    bi_col  <- configs[[name]]$bi
    formula_str <- paste("rating ~", uni_col, "*", bi_col)
    models[[name]] <- glm(as.formula(formula_str), data = data)
    cat("Fitted model:", name, "\n")
  }
  return(models)
}

# ------------------------------------------------------------------------------
# Function: extract_model_summary
# Purpose: Extract coefficients and AIC from each model in a robust manner.
# Returns: A data frame with model names, coefficients, and AIC.
# ------------------------------------------------------------------------------
extract_model_summary <- function(models_list) {
  summaries <- lapply(models_list, function(mod) {
    coefs <- coef(mod)
    list(
      intercept = ifelse(length(coefs) >= 1, coefs[1], NA),
      uni_coef = ifelse(length(coefs) >= 2, coefs[2], NA),
      bi_coef = ifelse(length(coefs) >= 3, coefs[3], NA),
      interaction_coef = ifelse(length(coefs) >= 4, coefs[4], NA),
      AIC = AIC(mod)
    )
  })
  
  df <- do.call(rbind, lapply(names(summaries), function(nm) {
    data.frame(
      model = nm,
      intercept = summaries[[nm]]$intercept,
      uni_coef = summaries[[nm]]$uni_coef,
      bi_coef = summaries[[nm]]$bi_coef,
      interaction_coef = summaries[[nm]]$interaction_coef,
      AIC = summaries[[nm]]$AIC,
      row.names = NULL,
      stringsAsFactors = FALSE
    )
  }))
  return(df)
}

# ------------------------------------------------------------------------------
# Fit the models and extract summaries.
# ------------------------------------------------------------------------------
models_list <- fit_models(daland_data, configs)
model_summary_df <- extract_model_summary(models_list)

cat("All model coefficients and AIC:\n")
print(model_summary_df)

# Sort models by AIC and display the sorted data frame.
sorted_df <- model_summary_df[order(model_summary_df$AIC), ]
cat("Models sorted by AIC:\n")
print(sorted_df)
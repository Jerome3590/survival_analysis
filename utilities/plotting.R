##########################################################################
# Functions to plot univariate associations
# - one predictor variable (var) and one outcome variable (outcome)
#
# Instructions:
# 1. Modify setting if desired
# 2. Set outcome variable name
# 3. call make_plots() 
#
# Author: Michael D Porter/Jerome Dixon (Univeristy of Virginia) | March 17, 2024
##########################################################################
library(tidyverse)
library(rlang)

# categorical_plots <- lapply(cat_features, function(feature) {
#   risk_train %>% make_plots(feature)
# })
# 
# 
# numeric_plots <- lapply(num_features, function(feature) {
#   risk_train %>% make_plots(feature)
# })

#------------------------------------------------------------------------#
# Settings
#------------------------------------------------------------------------#

# set theme for plots
theme_smooth = list(
  theme_bw(base_size = 14),
  scale_y_continuous(breaks = seq(0, 1, by = .02)), # set y-axis ticks
  coord_cartesian(ylim = c(0, .25)),                # set y-axis limits
  labs(y = "Pr(Waitlist Mortality | X)")            # set y-axis label
)

# color settings:
col_outcome = c(`0` = "#0C7BDC", `1` = "#FFC20A")  # colors for rug
default = list(
  fill = "azure4",     
  line = "black", 
  alpha = .40
)

#------------------------------------------------------------------------#
# Plotting Functions
#------------------------------------------------------------------------#

#: function to plot univariate relationship
make_plots <- function(data, var, ...) {
  # Convert string to symbol
  var_sym = ensym(var)
  
  # Dynamically select column and determine its type
  var_type = data %>% pull(var_sym) %>% class()
  
  if(var_type[1] %in% c('integer', 'numeric')) {
    plt = plot_numeric(data, var_sym, ...)
  } else {
    plt = plot_categorical(data, var_sym, ...)
  }
  plt
}


#: Plot for numerical predictor
plot_numeric <- function(df, var, caption = NULL){
  # Ensure `var` is treated as a symbol for dynamic evaluation
  var_sym = rlang::ensym(var)
  
  # Extracting the outcome variable symbol
  outcome_sym = ensym("outcome_final") 
  
  # Calculate baseline outcome rate
  base_p = mean(df[[outcome_sym]] == 1)  # Baseline outcome rate
  
  # Generate plot
  plt = df %>% 
    ggplot(aes(x = !!var_sym, y = !!outcome_sym)) + 
    geom_hline(yintercept = base_p, linetype = "dashed", color = "grey50") +
    geom_smooth(method = "gam", method.args = list(family = "binomial"), 
                formula = y ~ s(x, bs = "cs"), 
                fill = default$fill, color = default$line, alpha = default$alpha) +
    geom_rug(data = df %>% filter(!!outcome_sym == 1), sides = "t", color = col_outcome["1"]) + 
    geom_rug(data = df %>% filter(!!outcome_sym == 0), sides = "b", color = col_outcome["0"]) +    
    theme_smooth
  
  # Add missing value component if applicable
  if(sum(is.na(df %>% pull(!!var_sym))) > 5){
    d = df %>% filter(!is.na(!!var_sym)) %>% pull(!!var_sym)
    width = diff(range(d)) * .05 / 2
    x = min(d) - 2 * width
    
    k = 5  # Smoothing strength
    missing_df = df %>% 
      filter(is.na(!!var_sym)) %>% 
      summarize(
        x = x, width = width,
        n = n(), 
        n1 = sum(!!outcome_sym), 
        a = n1 + base_p * k,
        b = n - n1 + (1 - base_p) * k,
        p = a / (a + b),
        lower = qbeta(0.025, a, b),
        upper = qbeta(0.975, a, b),
        moe = upper - lower
      )
    
    plt = plt + 
      geom_tile(data = missing_df, aes(x = x, y = p, width = width, height = moe), 
                fill = default$fill, alpha = default$alpha) + 
      geom_segment(data = missing_df, color = default$line, 
                   aes(x = x - width / 2, xend = x + width / 2, y = p, yend = p)) + 
      annotate("text", x = missing_df$x, y = 0, label = "Missing", color = "black", 
               angle = -90, hjust = 1)
  }
  
  # Add caption if provided
  if(!is.null(caption)) plt = plt + labs(caption = caption)
  
  plt
}


#: Plot for categorical predictor
plot_categorical <- function(df, var, caption = NULL){
  # Convert string to symbol for dynamic evaluation
  var_sym = ensym(var)
  outcome_sym = ensym("outcome_final") # Ensure this matches your actual outcome variable name
  
  # Calculate baseline outcome rate
  base_p = mean(df[[outcome_sym]] == 1)
  
  # Prepare the dataframe: handle missing values, truncate long text strings, and lump categories
  df_modified = df %>%
    mutate(
      !!var_sym := str_trunc(!!var_sym, width = 30, side = "right"),
      !!var_sym := fct_lump_n(!!var_sym, n = 15, other_level = "All Others"),
      !!var_sym := as_factor(!!var_sym) %>% fct_explicit_na(na_level = "Missing")
    )
  
  # Create the plot
  pointrng = df_modified %>%
    ungroup() %>%
    count(!!var_sym, !!outcome_sym) %>%
    spread(key = !!outcome_sym, value = n, fill = 0L) %>%
    mutate(
      n = `0` + `1`,
      a = `1` + base_p * k,
      b = `0` + (1 - base_p) * k,
      p = a / (a + b),
      lower = qbeta(0.025, a, b),
      upper = qbeta(0.975, a, b)
    ) %>%
    ggplot(aes(x = !!var_sym, y = p, ymin = lower, ymax = upper)) +
    geom_hline(yintercept = base_p, linetype = "dashed", color = "grey50") +
    geom_pointrange() +
    theme_smooth
  
  if (!is.null(caption)) {
    pointrng <- pointrng + labs(caption = caption)
  }
  
  nx = df_modified %>% pull(!!var_sym) %>% paste(collapse = " ") %>% nchar()
  if (nx > 80) {
    pointrng <- pointrng + theme(axis.text.x = element_text(angle = -45, hjust = 0))
  }
  
  return(pointrng)
}


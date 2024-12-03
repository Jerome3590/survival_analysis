##########################################################################
# Functions to plot univariate associations
# - one predictor variable (var) and one outcome variable (outcome)
#
# Instructions:
# 1. Modify setting if desired
# 2. Set outcome variable name
# 3. call make_plots() 
#
# Author: Michael D Porter/Jerome Dixon (University of Virginia) | March 17, 2024
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

##########################################################################
# Functions to plot partial dependency plots from Shap Values
# - one predictor variable (var) and one outcome variable (outcome)
#
# Instructions:
# 1. Modify settings if desired
# 2. Create Shap Value Dataframe
# 3. Create Test Data Dataframe
# 4. Call create_pdp_numeric(), create_pdp_categorical(), or create_shap_pdp_plots()
#
# Author: Michael D Porter/Jerome Dixon (University of Virginia) | November 27, 2024
##########################################################################


create_pdp_numeric <- function(feature_name, pdp_data_df, pdp_shap_df, save_plots = TRUE) {
  
  # Set the threshold for outlier removal based on Z-score
  threshold <- 3
  
  # Check if the feature is present in both test_data and pdp_shap_data
  if (!feature_name %in% colnames(pdp_data_df) || !feature_name %in% colnames(pdp_shap_df)){
    stop(paste("Feature", feature_name, "not found in the data."))
  }
  
  # Dataframe for the feature values and corresponding SHAP values
  pdp_shap_data_feature <- data.frame(
    feature_value = pdp_data_df[[feature_name]],  # Original feature values
    shap_value = pdp_shap_df[[feature_name]]  # SHAP values
  )
  
  # Remove rows with NA values in either feature_value or shap_value
  pdp_shap_data_feature <- na.omit(pdp_shap_data_feature)
  
  if (feature_name == 'eGFR'){
    pdp_shap_data_feature <- pdp_shap_data_feature[pdp_shap_data_feature$feature_value < 400, ]
  }
  
  # Define unit labels for axis titles only
  unit_labels <- list(
    eGFR = "ml/min/1.73m^2",
    Albumin = "g/dL",
    Height = "cm",
    Weight = "kgs",
    Age = "years",
    BSA = "m^2",
    BMI = "kg/m^2"
  )
  
  # Get the appropriate unit label for the feature
  unit_label <- unit_labels[[feature_name]]
  
  # Scatter plot using ggplot2
  scatter_plot <- ggplot(pdp_shap_data_feature, aes(x = feature_value, y = shap_value)) +
    geom_point(color = 'blue', alpha = 0.6) + 
    scale_x_continuous(breaks = function(x) pretty(x, n = 10)) +
    scale_y_continuous() +  
    labs(x = if (!is.null(unit_label) && unit_label != "") 
      paste(feature_name, " Values (", unit_label, ")", sep = "") 
      else 
        paste(feature_name, "Values"),
      y = "SHAP Values",
      title = paste("SHAP Partial Dependency Plot for", feature_name)) +
    theme_minimal()  
  
  # Create marginal histogram for the bottom (x-axis)
  histogram_plot <- ggplot(pdp_shap_data_feature, aes(x = feature_value)) +
    geom_histogram(fill = "grey", bins = 30) +
    theme_minimal() +
    labs(x = paste(feature_name, "Values (", unit_label, ")", sep = ""), y = "Count")
  
  # Remove axis labels, ticks, and gridlines from the histogram to clean up appearance
  histogram_plot <- histogram_plot +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid = element_blank(), 
      plot.margin = margin(5, 5, 5, 5)
    )
  
  combined_plot <- scatter_plot / histogram_plot + plot_layout(heights = c(20, 1))
  
  # Display the plot
  print(combined_plot)
  
  # Save the plot as a PNG file
  if (save_plots) {
    ggsave(paste0("images/dependence_plots/shap_plot_numeric_", feature_name, ".png"), combined_plot)
  }
}


create_pdp_categorical <- function(feature_name, pdp_data_df, pdp_shap_df, save_plot = TRUE, plot_width = 5, plot_height = 4) {
  
  # Check if the feature is present in both test_data and pdp_shap_data
  if (!feature_name %in% colnames(pdp_data_df) || !feature_name %in% colnames(pdp_shap_df)) {
    stop(paste("Feature", feature_name, "not found in the data."))
  }
  
  # Create a dataframe for the feature values and corresponding SHAP values
  pdp_shap_data_feature <- data.frame(
    feature_value = pdp_data_df[[feature_name]],  # Actual feature values (categories)
    shap_value = pdp_shap_df[[feature_name]]  # Corresponding SHAP values
  )
  
  # Define unit labels for axis titles only
  cat_labels <- list(
    DCM = "Dilated Cardiomyopathy",
    HCM = "Hypertrophic Cardiomyopathy",
    ECMO = "ECMO Cardiogram",
    RCM = "Restrictive Cardiomyopathy",
    Myocard = "Myocardium",
    Defib = "Defibrillator",
    `VAD REG` = "Ventricular Assist Device (VAD) at Registration",
    `VAD TCR` = "Ventricular Assist Device (VAD) at Listing",
    VHD = "Valvular Heart Disease (VHD)",
    `XMatch Req` = "Transplant Match Requested"
  )
  
  # Get the appropriate unit label for the feature
  cat_label <- cat_labels[[feature_name]]
  
  # Calculate the mean SHAP value for each category
  pdp_shap_summary <- pdp_shap_data_feature %>%
    group_by(feature_value) %>%
    summarize(mean_shap = mean(shap_value, na.rm = TRUE), .groups = 'drop')
  
  # Create the plot
  plot <- ggplot(pdp_shap_summary, aes(x = reorder(feature_value, mean_shap), y = mean_shap, fill = feature_value)) +
    geom_bar(stat = "identity", show.legend = FALSE) +
    
    # Set axis labels and title
    labs(
      x = if (!is.null(cat_label) && cat_label != "") 
        cat_label 
      else 
        paste(feature_name, "Categories"),
      y = "Mean SHAP Value",
      title = paste("Partial Dependency Plot for", feature_name)
    ) +
    
    # Apply minimal theme and customize appearance
    theme_minimal() +
    theme(
      panel.grid = element_blank(),  # Remove gridlines if desired
      axis.text.x = if (feature_name == "Listing Ctr") element_blank() else element_text(angle = 45, hjust = 1),
      axis.title.x = if (feature_name == "Listing Ctr") element_blank() else element_text(),
      axis.ticks.x = if (feature_name == "Listing Ctr") element_blank() else element_line(),
      axis.text.y = element_text(),
      axis.title.y = element_text()
    )
  
  # Display the plot
  print(plot)
  
  # Save the plot if required
  if (save_plot) {
    ggsave(paste0("images/dependence_plots/shap_plot_categorical_", feature_name, ".png"), plot, width = plot_width, height = plot_height)
  }
}


create_shap_pdp_plots <- function(feature_names, pdp_data_df, pdp_shap_data, save_plots = TRUE) {
  
  # Loop over each feature in the feature_names list
  for (feature_name in feature_names) {
    
    # Check if the feature is present in test_data
    if (!feature_name %in% colnames(pdp_data_df)) {
      message(paste("Feature", feature_name, "not found in the data. Skipping..."))
      next  # Skip this feature if not found
    }
    
    # Determine if the feature is numeric or categorical
    if (is.numeric(pdp_data_df[[feature_name]])) {
      # If numeric, call the numeric plotting function
      create_pdp_numeric(feature_name, pdp_data_df, pdp_shap_data, save_plots = TRUE)
    } else if (is.factor(pdp_data_df[[feature_name]]) || is.character(pdp_data_df[[feature_name]])) {
      # If categorical, call the categorical plotting function
      create_pdp_categorical(feature_name, pdp_data_df, pdp_shap_data, save_plot = TRUE, plot_width = 5, plot_height = 4)
    } else {
      message(paste("Unsupported data type for feature:", feature_name, "Skipping..."))
    }
  }
}

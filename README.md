# **Survival Analysis With CatBoost**

This repository contains a comprehensive survival analysis project focusing on mortality prediction and waitlist analysis in healthcare. The project utilizes various machine learning techniques, including CatBoost, XGBoost, and Random Forest models, to analyze and predict patient outcomes.

## Project Structure

survival_analysis/  
│  
├── survival_analysis_final_catboost_model.qmd  
├── eda/  
│ ├── center-stats.qmd  
│ ├── listing-mortality-prediction.qmd  
│ ├── survival_analysis_catboost_xgboost_random_forest.qmd  
│ ├── survival_analysis_feature_analysis.qmd  
│ ├── survival_analysis_feature_encoding.qmd  
│ ├── survival_analysis_model_evaluation.qmd  
│ ├── survival_analysis_models.qmd  
│ └── waitlist-data2.qmd  
│  
├── html/  
│ ├── center-stats.html  
│ ├── listing-mortality-prediction.html  
│ ├── model_data.html  
│ ├── sorted_shap_values_interactive.html  
│ ├── survival_analysis_final_catboost_model.html  
│ └── waitlist-data2.html  
│  
├── images/  
│ ├── catboost_beeswarm.png  
│ ├── mean_absolute_shap_importance.png  
│ ├── partial_dependence_plots/  
│ ├── shap_correlation_plot.png  
│ └── shapley_bar_one_hot.png  
│  
├── utilities/  
│ └── plotting.R  
│  
└── data/  


## Project Components

### Main Analysis
- `survival_analysis_final_catboost_model.qmd`: The final CatBoost model for survival analysis.
[survival_analysis_final_catboost_model.qmd](https://plotly-demo.s3.us-east-1.amazonaws.com/survival_analysis_final_catboost_model.html)

### Exploratory Data Analysis (EDA)
The `eda/` directory contains Quarto documents (.qmd files) for various aspects of the analysis:
- Center statistics
- Listing mortality prediction
- Comparison of CatBoost, XGBoost, and Random Forest models
- Feature analysis and encoding
- Model evaluation
- Waitlist data analysis

### HTML Output
The `html/` directory contains rendered HTML files from the Quarto documents, including:
- Center statistics
- Listing mortality prediction
- Model data visualization
- Interactive SHAP values
- Final CatBoost model results
- Waitlist data analysis
- Interactive Feature Importance Plot

### Visualizations
The `images/` directory stores generated plots and figures:
- CatBoost beeswarm plot
- Mean absolute SHAP importance
- Partial dependence plots
- SHAP correlation plot
- Shapley bar plot (one-hot encoded)

### Utilities
The `utilities/` directory contains R scripts for common functions:
- `plotting.R`: Custom plotting functions for the project

### Data
The `data/` directory contains the datasets used in the analysis.
Available upon request.

## Usage

To reproduce the analysis:

1. Ensure you have R and the required packages installed.
2. Request the data files and place in /data directory.
3. Run `survival_analysis_final_catboost_model.qmd`.


## Contact

[Jerome Dixon](https://www.linkedin.com/in/jeromedixon3590/)
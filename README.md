# **Survival Analysis With CatBoost**

This repository contains a comprehensive survival analysis project focusing on mortality prediction and waitlist analysis in healthcare. The project utilizes various machine learning techniques, including CatBoost, XGBoost, and Random Forest models, to analyze and predict patient outcomes.

## Project Structure

survival_analysis/  
│  
├── final_model/survival_analysis_final_catboost_model.qmd (final model)  
│ ├── survival_analysis_final_catboost_model.qmd (final model)  
│ └── survival_analysis_final_catboost_model.html (final model)  
|
├── shap_values/  
│ └── sorted_shap_values_interactive.html  
|
├── images/  
│ ├── catboost_beeswarm.png  
│ ├── mean_absolute_shap_importance.png  
│ ├── partial_dependence_plots_test/ 
│ ├── partial_dependence_plots_train/ 
│ ├── shap_correlation_plot.png  
│ └── shapley_bar_one_hot.png  
|  
├── tripod_ai_checklist/  
│ ├── tripod_ai_checklistt.qmd  
│ └── tripod_ai_checklist.html  
|
├── utilities/  
│ ├── make.R  
│ └── plotting.R  
|
└── model_data/  
│ ├── center-stats.qmd  
│ ├── center-stats.html  
│ ├── model_data.qmd  
│ ├── model_data.html  
│ ├── waitlist-data2.qmd  
│ └── waitlist-data2.html  
|
├── eda/  
│ ├── listing-mortality-prediction.qmd (various models)  
│ ├── listing-mortality-prediction.html (various models)  
│ ├── survival_analysis_catboost_xgboost_random_forest.qmd  
│ ├── survival_analysis_feature_analysis.qmd   
│ ├── survival_analysis_feature_encoding.qmd   
│ ├── survival_analysis_model_evaluation.qmd   
└──── survival_analysis_models.qmd   


## Project Components  

### Final Model
The `final_model/` directory contains- `survival_analysis_final_catboost_model.qmd`: The final CatBoost model for survival analysis.
[survival_analysis_final_catboost_model.qmd](https://plotly-demo.s3.us-east-1.amazonaws.com/survival_analysis_final_catboost_model.html)

### Shap Values  
The `shap_values/` directory contains an Interactive Feature Importance Plot

### Images
The `images/` directory stores generated plots and figures:
- CatBoost beeswarm plot
- Mean absolute SHAP importance
- Partial dependence plots - Test and Train
- SHAP correlation plot
- Shapley bar plot (one-hot encoded)

### TRIPOD+AI Checklist
The `tripod_ai_checklist/` directory contains the completed TRIPOD+AI Checklist.  

### Model Data
The `model_data/` directory contains the data pre-processing and processing used in the analysis.

### Data
The `data/` directory contains the data sets used in the analysis.
Available upon request.

### Exploratory Data Analysis (EDA)  
The `eda/` directory contains various aspects of the analysis:
- Center statistics
- Listing mortality prediction
- Comparison of CatBoost, XGBoost, and Random Forest models
- Feature analysis and encoding
- Model evaluation
- Waitlist data analysis

### Utilities
The `utilities/` directory contains R scripts for common functions:
- `plotting.R`: Custom plotting functions for the project
- 'make.R': Orchestration file for data pipelines

## Usage
To reproduce the analysis:

1. Ensure you have R and the required packages installed.
2. Request the data files and place in /data directory.
3. Run `survival_analysis_final_catboost_model.qmd`.


## Contact

[Jerome Dixon](https://www.linkedin.com/in/jeromedixon3590/)
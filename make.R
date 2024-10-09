# Make File
clear_cache = TRUE
library(quarto)
quarto_render("center-stats.qmd", cache_refresh = clear_cache)
quarto_render("waitlist-data2.qmd", cache_refresh = clear_cache)
quarto_render("model_data.qmd", cache_refresh = clear_cache)
quarto_render("listing-mortality-prediction.qmd", cache_refresh = clear_cache)

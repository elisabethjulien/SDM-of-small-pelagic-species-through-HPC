# ---- Load all required packages ----
library(parallelly)     # For detecting CPUs and worker handling
library(future)         # For plan(), multicore/multisession parallel backend
library(future.apply)   # For future_lapply()
library(dplyr)          # For data manipulation (bind_rows, filter, etc.)
library(terra)          # For raster handling (rast, crs, etc.)
library(flexsdm)        # For occfilt_geo() and SDM filtering tools
library(tibble)         # For tibble/dplyr tibbles

# ---- Setup parallel backend ----
nc <- as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))
plan(multicore, workers = nc)   # use multicore on Linux
cat("Using", nc, "CPUs\n")

# ---- Input paths ----
df_path <- "/projects/F202415137CPCAA0/small_pel_geofiltering/all_species_cleaned.csv"
tif_path <- "/projects/F202415137CPCAA0/small_pel_geofiltering/present.tif"

# ---- Load data ----
dfsea <- read.csv(df_path)
somevar <- rast(tif_path)
r_crs <- crs(somevar)

apply_filter <- function(df) {
  if (nrow(df) < 2) return(NULL)

  tryCatch(
    {
      occfilt_geo(
        data     = df,
        x        = "lon",
        y        = "lat",
        env_layer = somevar,  # safe under multicore
        method   = c("defined", d = "1"),
        prj      = r_crs
      )
    },
    error = function(e) {
      message("Error filtering ", unique(df$species), ": ", e$message)
      NULL
    }
  )
}

df_list <- split(dfsea, dfsea$species)
filtered_list <- future_lapply(df_list, apply_filter)

out <- bind_rows(Filter(function(x) inherits(x, "tbl_df"), filtered_list))

write.csv(out,
          "/projects/F202415137CPCAA0/small_pel_geofiltering/all_species_cleaned_and_geofiltered.csv",
          row.names = FALSE)

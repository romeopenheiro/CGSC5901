## code to prepare `DATASET` dataset goes here

# Setup packages
if (!requireNamespace('xfun')) install.packages('xfun')
xf <- loadNamespace('xfun')

cran_packages = c(
        "readr",
        "tidyverse",
        "dplyr",
        "here",
        "tibble",
        "data.table"
)
if (length(cran_packages) != 0) xf$pkg_load2(cran_packages)

import::from(magrittr, '%>%')

dp <- import::from(dplyr, .all=TRUE, .into={new.env()})


# Make a list of all the csv files in the directory
list <- list.files(here::here("data/data-raw"))

# Create a data frame for holding all the data
final <- data.frame(NULL)
# Data organized by trial order
trial_count <- data.frame(NULL)

#Go though each file, extract the relevant info, add a subject number

for(i in 1:length(list)){
        temp <- data.table::fread(list[i], select = c("resp.keys",
                                                      "resp.corr",
                                                      "resp.rt",
                                                      "strings",
                                                      "corrans",
                                                      "gender (m/f)",
                                                      "age",
                                                      "freq",
                                                      "trials.thisIndex",
                                                      "OS"))
        # Remove the practice trials
        temp <- temp[-(1:10),]
        # Add subject number
        temp$subject <- i
        # Remove randomization by reordering the rows by the order of the original experiment parameters
        temp <- dp$arrange(temp$trials.thisIndex)
                # Remove NAs from the index column
                # dp$filter(!is.na(temp$trials.thisIndex))
                # Not required as we removed the practice trials
        # Concatenate successive files
        dp$bind_rows(final, temp, .id = temp$subject)

}

shrimp <- readr::read_csv(here::here("data/data-raw", "shrimp.csv"))

# Add any tidying steps to this script if necessary
shrimp <- shrimp_raw[-c(1:2),]
colnames(shrimp) <- c("Year", "Month", shrimp_raw[1,3:10])
shrimp <- readr::type_convert(shrimp)

usethis::use_data(DATASET, overwrite = TRUE)

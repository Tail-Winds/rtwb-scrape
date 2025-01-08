library(googlesheets4)
library(rvest)
library(dplyr)

# This brings the Year 3 sheet up-to-date with October 4, 2023

# https://josiahparry.medium.com/googlesheets4-authentication-for-deployment-9e994b4c81d6
# https://googlesheets4.tidyverse.org/articles/drive-and-sheets.html
# https://github.com/Ryo-N7/CanPL_Analysis

# If running this on your computer, uncomment the following, sign in on
#   your browser, and skip line 14
# gs4_auth()

gs4_auth(path = Sys.getenv('GDRIVE_PAT'))

n_reviewed <- function(date){
  
  daily_url <- paste0(
    ## Year 2 base URL
    # 'http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc_html/mdoc0722_mdoc_summary_',
    ## Year 3 base URL
    'https://dcs.whoi.edu/mdoc2410/mdoc2410_mdoc_html/mdoc2410_mdoc_summary_',
    date,
    '.html') |> 
    URLencode()
  
  read_html(daily_url) |> 
    html_element(xpath = '/html/body/table') |> 
    html_table(na.strings = '') |> 
    dplyr::summarize(date = unique(gsub(' .*', '', `Date/time`)),
                     n_reviewed = sum(!is.na(Tracks))
    )  
}

dates <- seq(
  ## Year 2 dates
  # as.Date('2022-07-20'), as.Date('2023-10-04'),
  ## Year 3 dates
  
  ### From this date...
  as.Date('2024-10-22'),
  ### To this date...
  as.Date('2025-01-07'),
  by = 'day')
dates <- format(dates, '%Y%m%d')

all_n_reviewed <- lapply(dates,
                         n_reviewed) |> 
  bind_rows(all_n_reviewed)

write_sheet(
  all_n_reviewed,
  # Year 2 URL for "Webscraper_TallyPeriods_year2" (HIDDEN)
  # Year 3 URL for "Webscraper_TallyPeriods_year3"
  'https://docs.google.com/spreadsheets/d/1M293uj32-a_aSv8jhKsjEnZ7-eD7Rt0S80ggburvBe0',
  sheet = 1)

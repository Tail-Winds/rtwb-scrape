library(googlesheets4)
library(rvest)

# This brings the sheet up-to-date with March 6, 2023

# https://josiahparry.medium.com/googlesheets4-authentication-for-deployment-9e994b4c81d6
# https://googlesheets4.tidyverse.org/articles/drive-and-sheets.html
# https://github.com/Ryo-N7/CanPL_Analysis

gs4_auth(path = Sys.getenv('GDRIVE_PAT'))

n_reviewed <- function(date){
  
  daily_url <- paste0('http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc_html/mdoc0722_mdoc_summary_',
                      date,
                      '.html') |> 
    URLencode()
  
  read_html(daily_url) |> 
    html_element(xpath = '/html/body/table') |> 
    html_table(na.strings = '')|> 
    dplyr::summarize(date = unique(gsub(' .*', '', `Date/time`)),
                     n_reviewed = sum(!is.na(Tracks))
    )  
}

dates <- seq(as.Date('2023-05-12'), as.Date('2023-05-29'), by = 'day')
dates <- format(dates, '%Y%m%d')

all_n_reviewed <- lapply(dates,
                         n_reviewed)
all_n_reviewed <- dplyr::bind_rows(all_n_reviewed)

write_sheet(all_n_reviewed, 'https://docs.google.com/spreadsheets/d/10tMVbEwzHaSPVQwaN8QP_BegXoIKNUKzJoaYkrViWIA/edit#gid=0',
            sheet = 1)

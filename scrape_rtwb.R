library(googledrive)
library(googlesheets4)
library(rvest)

drive_auth(path = Sys.getenv('GDRIVE_PAT'))

yesterday <- format(Sys.Date()-1, '%Y%m%d')


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

sheet_append(
  'https://docs.google.com/spreadsheets/d/11qKDM3nNPgC802fe8gFRVJ6J3dVfmAR1uq0tJVlFvAY/edit#gid=0',
  n_reviewed(yesterday),
  sheet = 1
)
  

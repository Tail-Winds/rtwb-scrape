# Load used packages
library(googlesheets4)
library(rvest)
library(dplyr)

# Get yesterday's date in YYYYMMDD format
yesterday <- format(Sys.Date() - 1, '%Y%m%d')

# Create the URL where yesterday's data should be found
yesterdays_url <- paste0(
  # Year 2 base URL
  # 'http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc_html/mdoc0722_mdoc_summary_',
  # Year 3 base URL
  'https://dcs.whoi.edu/mdoc2410/mdoc2410_mdoc_html/mdoc2410_mdoc_summary_',
  yesterday,
  '.html'
) |> 
  URLencode()


n_reviewed <- yesterdays_url |> 
  # Read in the HTML using rvest::read_html
  read_html() |> 
  # Select the table using the XPath
  # (Ctrl + Shift + I in Chrome, then:
  #   right click the element > Copy > Copy Full XPath)
  html_element(xpath = '/html/body/table') |> 
  # Tell R that this is a table, and NAs are blanks, not the text "NA" that
  #   it assumes
  html_table(na.strings = '')|> 
  summarize(
    # Pull out the date by deleting the time data (substituting anything after
    #   a space (' .*') with nothing ('')) and selecting one (unique)
    date = unique(gsub(' .*', '', `Date/time`)),
    # Find the number of reviewed pitch tracks by adding up everything that
    #   is not NA
    n_reviewed = sum(!is.na(Tracks))
  )  


# Get Google Drive authorization token from the GitHub secrets vault
gs4_auth(path = Sys.getenv('GDRIVE_PAT'))

# Tack the number of reviewed pitch tracks to the bottom of the spreadsheet
sheet_append(
  # Year 2 URL for "Webscraper_TallyPeriods_year2" (HIDDEN)
  # Year 3 URL for "Webscraper_TallyPeriods_year3"
  'https://docs.google.com/spreadsheets/d/18zA7XAaZQTDdYxgaVf6GM8Kp-p8Wwa8BL6J2siALsaw/edit#gid=0',
  n_reviewed,
  sheet = 1
)
  
# https://www.r-bloggers.com/2021/09/creating-a-data-pipeline-with-github-actions-the-googledrive-package-for-the-canadian-premier-league-soccer-data-initiative/

# https://github.com/marketplace/actions/google-sheets-secrets-action

# Load used packages
library(rvest)
library(dplyr)
library(tidyr)
library(lubridate)
library(googlesheets4)

# Read in HTML using rvest::read_html
whales_html <- read_html('http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc.shtml') 

# Pull out the table using the XPath
# (Ctrl + Shift + I in Chrome, then:
#   right click the element > Copy > Copy Full XPath)
whales <- whales_html |> 
  html_element(xpath = '/html/body/table[1]') |> 
  html_table()

# The "style" HTML attribute encodes the information.
# Pull out the "style" attribute from each table row, found using the XPath
colors <- whales_html |> 
  html_elements(xpath = '/html/body/table[1]/tr/td')|> 
  html_attr('style')

# There are other "style" attributes. Use base::grepl to pull out anything that
# contains the text "background-color"
colors <- colors[grepl('background-color', colors)]

# Use base::gsub to substitute the text "background-color:" with nothing
#   (delete the text "background-color:" from everything, leaving just the color)
colors <- gsub('background-color:', '', colors)

# This has created a character vector, but it's really a 4-column matrix with
#   the same amount of rows as the "whales" data frame made above.
# Tell R this is a 4-column matrix, byrow meaning it's
#   "Row 1, Row 1, Row 1, Row 1,
#    Row 2, Row 2, Row 2, Row 2, etc.
# AND directly replace the corresponding columns of the "whales" data frame
whales[, 2:5] <- matrix(colors, ncol = 4, byrow = T)

# Convert written colors to D/PD/ND
whales <- whales |>
  mutate(
    # For every column ("across everything") convert the color text to the
    #   corresponding detection information
    across(
      everything(),
      ~ case_when(. == 'lightgray' ~ 'not detected',
                  . == 'yellow' ~ 'possibly detected',
                  . == 'red' ~ 'detected',
                  T ~ .)
    ),
    # Convert the "Date" column to R's Date class
    Date = as.Date(Date, format = '%m/%d/%Y')
  )

# Create summary table
whale_summary <- whales |> 
  mutate(
    # Pull out month from "Date" column, label it as text
    month = month(Date, label = T),
    # Pull out year from "Date" column
    year = year(Date)
  ) |> 
  # Tell R that we will want summary stats for each year-by-month group
  group_by(year, month) |> 
  # Create the summary
  summarize(`Monitoring Days` = n(),
            `# Days PD only SW` = sum(`Sei whale` == 'possibly detected'),
            `# Days D SW` =  sum(`Sei whale` == 'detected'),
            `# Days PD only FW` = sum(`Fin whale` == 'possibly detected'),
            `# Days D FW` =  sum(`Fin whale` == 'detected'),
            `# Days PD only RW` = sum(`Right whale` == 'possibly detected'),
            `# Days D RW` =  sum(`Right whale` == 'detected'),
            `# Days PD only HW` = sum(`Humpback whale` == 'possibly detected'),
            `# Days D HW` =  sum(`Humpback whale` == 'detected'))

# Add summary row
whale_summary <- whale_summary |> 
  bind_rows(
    whale_summary |> 
      ungroup () |>
      summarize(across(`Monitoring Days`:`# Days D HW`, sum))
  )

# Get Google Drive authorization token from the GitHub secrets vault
gs4_auth(path = Sys.getenv('GDRIVE_PAT'))

# The sheet we are targeting:
occurrence_sheet <- 'https://docs.google.com/spreadsheets/d/1hGFPbmarhzRI_zf-E01mVEZKCjP7dezYsTQihKhUgZs/edit#gid=0'

# Remove previously-scraped sheets (anything containing the text "Scraper - " in
#   its name)
sheet_delete(
  occurrence_sheet,
  grep('Scraper - ',
       sheet_names(occurrence_sheet)
  )
)

# Add newly-scraped full table, tagged with the current time (UTC)
sheet_write(
  whales,
  occurrence_sheet,
  sheet = paste0('Scraper - Full table ', Sys.time())
)

# Add newly-scraped and summarized table, tagged with the current time (UTC)
sheet_write(
  whale_summary,
  occurrence_sheet,
  sheet = paste0('Scraper - Summary ', Sys.time())
)

library(rvest)
library(dplyr)
library(tidyr)
library(lubridate)
library(googlesheets4)

whales_html <- read_html('http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc.shtml') 

whales <- whales_html |> 
  html_element(xpath = '/html/body/table[1]') |> 
  html_table()

colors <- whales_html |> 
  html_elements(xpath = '/html/body/table[1]/tr/td')|> 
  html_attr('style')

colors <- colors[grepl('background', colors)]

colors <- gsub('background-color:', '', colors)

whales[, 2:5] <- matrix(colors, ncol = 4, byrow = T)

whales <- whales |>
  mutate(
    across(
      everything(),
      ~ case_when(. == 'lightgray' ~ 'not detected',
                  . == 'yellow' ~ 'possibly detected',
                  . == 'red' ~ 'detected',
                  T ~ .)
    ),
    Date = as.Date(Date, format = '%m/%d/%Y')
  )


whale_summary <- whales |> 
  mutate(month = month(Date, label = T),
         year = year(Date)) |> 
  group_by(year, month) |> 
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

gs4_auth(path = Sys.getenv('GDRIVE_PAT'))

# remove previously-scraped sheet
occurrence_sheet <- 'https://docs.google.com/spreadsheets/d/1hGFPbmarhzRI_zf-E01mVEZKCjP7dezYsTQihKhUgZs/edit#gid=0'
sheet_delete(
  occurrence_sheet,
  grep('Scraper - ',
       sheet_names(occurrence_sheet)
  )
)

# Add newly-scraped sheet
sheet_write(
  whales,
  occurrence_sheet,
  sheet = paste0('Scraper - Full table ', Sys.time())
)

sheet_write(
  whale_summary,
  occurrence_sheet,
  sheet = paste0('Scraper - Summary ', Sys.time())
)

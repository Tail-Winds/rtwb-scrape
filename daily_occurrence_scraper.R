library(rvest)
library(dplyr)
library(tidyr)
library(lubridate)

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


whales <- whales |> 
  mutate(month = month(Date),
         year = year(Date)) |> 
  group_by(year, month) |> 
  summarize(monitoring_days = n(),
            n_sw_pd = sum(`Sei whale` == 'possibly detected'),
            n_sw_d =  sum(`Sei whale` == 'detected'),
            n_fw_pd = sum(`Fin whale` == 'possibly detected'),
            n_fw_d =  sum(`Fin whale` == 'detected'),
            n_rw_pd = sum(`Right whale` == 'possibly detected'),
            n_rw_d =  sum(`Right whale` == 'detected'),
            n_hw_pd = sum(`Humpback whale` == 'possibly detected'),
            n_hw_d =  sum(`Humpback whale` == 'detected'))


<!-- README.md is generated from README.Rmd. Please edit that file -->

# Scrape data from the Ocean City buoy site

File in this repository relate to scraping the data on the [Ocean City
Real-time Whale Buoy (RTWB)
website](http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc.shtml).

## Summarize number of analyzed periods

This repository uses a GitHub Action to scrape the number of tracks per
day on the [“Automated detection data”
table](http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc_html/mdoc0722_mdoc_summary.html#table).
The table is scraped and results posted to a Google Sheet on the private
TailWinds Google Drive every day at 09:00 UTC.

Refer to the [raw walkthrough
document](https://github.com/Tail-Winds/rtwb-scrape/blob/main/walkthroughs/rtwb_scrape_walkthrough.qmd),
or download the [compiled
version](https://github.com/Tail-Winds/rtwb-scrape/blob/main/walkthroughs/rtwb_scrape_walkthrough.html)
and open with your web browser.

This process uses the code in
[`scrape_rtwb.R`](https://github.com/Tail-Winds/rtwb-scrape/blob/main/scheduled_code/scrape_rtwb.R)
and a secret access token. The process to set the access token is
currently outlined at
[`quick permissitions notes.txt`](https://github.com/Tail-Winds/rtwb-scrape/blob/main/walkthroughs/quick%20permissions%20notes.txt);
this will be updated to a markdown document with a better narrative
soon(?).

Should the Google Sheet get deleted, run
[`scrape_rtwb_to_current.R`](https://github.com/Tail-Winds/rtwb-scrape/blob/main/other_code/scrape_rtwb_to_current.R)
and change the second date in [line
27](https://github.com/Tail-Winds/rtwb-scrape/blob/main/other_code/scrape_rtwb_to_current.R#L27)
with yesterday’s date to bring everything up to date.

## Daily occurrence table

[`daily_occurrence_scraper.R`](https://github.com/Tail-Winds/rtwb-scrape/blob/main/scheduled_code/daily_occurrence_scraper.R)
pulls in the table under “Data analyst review” on the [RTWB
website](http://dcs.whoi.edu/mdoc0722/mdoc0722_mdoc.shtml). The routine
runs immediately after that outlined above at 9:00AM UTC.

The general idea is:

1)  The two sheets named “Scraper - XXXX” are **DELETED**;
2)  Two **NEW** sheets are made, including their time stamps in UTC;
3)  “Scraper - Full table xxxx” is the table noted above on the main
    site, with color-coded detection/possible detection/no detection
    information converted to text;
4)  “Scraper - Summary xxxx” is the sum of detections and possible
    detections per species, per month;
    - The last row of “Scraper - Summary” are the respective column sums

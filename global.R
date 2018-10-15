library(shiny)
library(shinydashboard)
library(ggplot2)
library(googleVis)
library(ggthemes)
library(data.table)
library(dplyr)
library(plotly)

# Loading data
h1b <- fread("h1b_consolidated.csv")

#Creating job_title_list for selectinput
job_title_df = as.data.frame(h1b %>%
                               group_by(JOB_TITLE) %>% 
                               summarise(count = n()) %>% 
                               arrange(desc(count)) %>% 
                               top_n(100, wt = count))

job_title_list = job_title_df[1]
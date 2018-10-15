library(dplyr)
library(data.table)

server <- function(input, output, session){

# Creating top_positions df
top_positions = as.data.frame(h1b %>% 
                                 group_by(JOB_TITLE) %>%
                                 summarise(count = n(), percent = round(count*100/nrow(h1b),1)) %>% 
                                 arrange(desc(count))%>% 
                                 top_n(15, wt = count))

#Creating top_employer df
top_employer = as.data.frame(h1b %>% 
                                group_by(EMPLOYER_NAME) %>%
                                summarise(count = n(), percent = round(count*100/nrow(h1b),1)) %>% 
                                arrange(desc(count))%>% 
                                top_n(15, wt = count))
  
# Creating map dataframe
h1b$WORKSITE = sub('.*,\\s*', '', h1b$WORKSITE)
  
getJobLocat = h1b %>% 
  group_by(WORKSITE) %>% 
  summarise(count = n())
  
getJobLocatFinal = filter(getJobLocat, WORKSITE != 'na')
  
# Extracting Job Titles
getJobsTitle = reactive({
  term = input$JobTitle
  return(h1b[grep(term, h1b$JOB_TITLE, ignore.case = TRUE)])
})
  
# Plot Total Applications
  output$TotalApplications = renderPlotly({
    h1b %>%
      group_by(., YEAR) %>%
      count() %>%
      ggplot(aes(x = YEAR, y = n)) +
      geom_line() + theme(plot.caption = element_text(vjust = 1)) +
      labs(x = "Year") +
      ggtitle("Total Petitions for H-1B Visa, 2011 - 2016") +
      theme_few() + scale_y_continuous(name="Number of Petitions", labels = scales::comma)
  })
  
# Plot Applicants by Position Type
  output$TopPositions = renderPlot(
    ggplot(data = top_positions, aes(x = reorder(JOB_TITLE, percent),
                                    y = percent, fill = JOB_TITLE)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = percent), vjust = 1.1, hjust = 1.2) + 
      labs(x = "Job Title", y = "Petitions (% of)") + 
      theme(legend.position = "none") +
      coord_flip() +
      ggtitle("Percentage of Total H-1B Petitions from Top 15 Job Titles") +
      theme_few()
  )

  
# Plot Applicants by Employer
  output$TopEmployers = renderPlot(
    ggplot(data = top_employer, aes(x = reorder(EMPLOYER_NAME, percent),
                                    y = percent, fill = EMPLOYER_NAME)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = percent), vjust = 1.1, hjust = 1.2) + 
      labs(x = "Employer Name", y = "Petitions (% of)") + 
      theme(legend.position = "none") +
      coord_flip() +
      ggtitle("Percentage of Total H-1B Petitions from Top 15 Employers") +
      theme_few()
  )

  
# Plot Applications by Status
  output$ApplicationStatus = renderPlotly({
    h1b %>% 
      group_by(., YEAR, CASE_STATUS) %>% 
      count() %>% 
      ggplot(aes(x = YEAR, y = n)) +
      geom_line(aes(color = CASE_STATUS)) +
      labs(color = "", x = "Year") +
      theme_few() +
      ggtitle("Petition Status for H-1B Visa, 2011 - 2016") +
      scale_y_continuous(name="Number of Petitions", labels = scales::comma)
 })
  
# Plot the Output of Jobs Title
  output$TitlePlot <- renderPlotly({
    h1b %>% 
      filter(JOB_TITLE == input$JobTitle) %>% 
      group_by(YEAR) %>% 
      count() %>% 
      ggplot(aes(x = YEAR, y = n)) +
      geom_line() +
      labs(x = "Year", y = "Number of Petitions") +
      # geom_text(aes(label = n), position = position_dodge(.25), vjust = 0) +
      ggtitle("Total Number of Petitions for Specified Job Title") +
      theme_few()
  })
  
# Value Box Outputs for tab 2
  output$MinSalary = renderValueBox({
    dat <- getJobsTitle()[CASE_STATUS == "CERTIFIED"]
    infoBox("Minimum Salary", min(dat$PREVAILING_WAGE), icon = icon("money"), fill = T)
  })
  output$MaxSalary = renderValueBox({
    dat <- getJobsTitle()[CASE_STATUS == "CERTIFIED"]
    infoBox("Maximum Salary", max(dat$PREVAILING_WAGE), icon = icon("money"), fill = T)
  })
  output$MeanSalary = renderValueBox({
    dat <- getJobsTitle()[CASE_STATUS == "CERTIFIED"]
    infoBox("Average Salary", round(mean(dat$PREVAILING_WAGE),2), icon = icon("calculator"), fill = T)
  })
  
# Value Box Outputs for tab 3
  output$maxBox = renderInfoBox({
    max_value = max(getJobLocatFinal[,"count"])
    max_state =
      getJobLocatFinal$WORKSITE[getJobLocatFinal[,"count"]==max_value]
    infoBox(max_state, max_value, icon = icon("hand-o-up"))
  })
  output$minBox = renderInfoBox({
    min_value = min(getJobLocatFinal[,"count"])
    min_state =
      getJobLocatFinal$WORKSITE[getJobLocatFinal[,"count"]==min_value]
    infoBox(min_state, min_value, icon = icon("hand-o-down"))
  })

  
# Geo map for tab 3  
  output$GeoMap1 = renderGvis({
    gvisGeoChart(getJobLocatFinal, "WORKSITE", 
                   colorvar = 'count',
                   options = list(region="US", displayMode="regions", resolution="provinces", width="auto", height="auto"))
  })
  
}
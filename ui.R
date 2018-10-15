dashboardPage(
  
  # Dashboard Header
  dashboardHeader(
    title = "H-1B Visa Petitions"
  ),
  
  # Dashboard Sidebar
  dashboardSidebar(
    collapsed = FALSE,
    sidebarUserPanel(
      name = "Shiny Project: Logan Childers"
    ),
    sidebarMenu(
      menuItem(
        text = "Charts", tabName = "GraphTab",
        icon = icon("line-chart")
      ),
      menuItem(
        text = "Salary Lookup", tabName = "SelectTab",
        icon = icon("search")
      ),
      menuItem(
        text = "Map", tabName = "JobLocatTab",
        icon = icon("map")
      )
    )
  ),
  # Dashboard Body
  dashboardBody(
        tabItems(
          # Tab 1
          tabItem(
            tabName = "GraphTab",
            fluidPage(
              h1("H-1B Visa Petitions Analysis"),
              tabBox(
                side = "left",
                width = 12,
                tabPanel(
                  title = "Total Petitions",
                  plotlyOutput(outputId = "TotalApplications", width = "100%", height = "400px")
                ),
                tabPanel(
                  title = "Top Employers",
                  plotOutput(outputId = "TopEmployers")
                ),
                tabPanel(
                  title = "Top Positions",
                  plotOutput(outputId = "TopPositions")
                ),
                tabPanel(
                  title = "Petition Status",
                  plotlyOutput(outputId = "ApplicationStatus", width = "100%", height = "400px")
                )
              )
            )
          ),
          
          # Tab 2
          tabItem(
            tabName = "SelectTab",
            fluidPage(
              h1("Reported Salary Lookup"),
              fluidRow(
                      selectInput(
                        inputId = "JobTitle", label = "Select a Job Title from the Top 100 Jobs",
                        job_title_list, selectize = FALSE, width = "100%"
                      )
                    ),
                    br(),
                    valueBoxOutput(outputId = "MinSalary", width = 4),
                    valueBoxOutput(outputId = "MaxSalary", width = 4),
                    valueBoxOutput(outputId = "MeanSalary", width = 4),
                    br(), br(), br(), br(), br(), br(),
                    plotlyOutput(outputId = "TitlePlot")
                  )
                ),

          # Tab 3
          tabItem(
            tabName = "JobLocatTab",
            fluidRow(infoBoxOutput("maxBox"),
                     infoBoxOutput("minBox"),
                     infoBox("Total Petitions", 3002458, icon = icon('list'), fill = FALSE)),
            fluidPage(
              h1("Distribution of Petitions Across the US"),
              htmlOutput(outputId = "GeoMap1")
            )
          )
    )
    )
  )
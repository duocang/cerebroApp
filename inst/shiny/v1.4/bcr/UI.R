##----------------------------------------------------------------------------##
## Tab: BCR (B cell receptor repertoire)
##----------------------------------------------------------------------------##

tab_bcr <- tabItem(
  tabName = "bcr",
  fluidRow(
    cerebroBox(
      title = boxTitle("BCR settings"),
      content = uiOutput("bcr_settings_UI")
    )
  ),
  fluidRow(
    cerebroBox(
      title = boxTitle("BCR visualizations"),
      content = uiOutput("bcr_visualizations_UI")
    )
  )
)

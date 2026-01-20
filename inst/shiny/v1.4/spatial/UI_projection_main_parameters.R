##----------------------------------------------------------------------------##
## UI elements to set main parameters for the projection.
##----------------------------------------------------------------------------##
output[["spatial_projection_main_parameters_UI"]] <- renderUI({
  ## determine which metadata columns to include based on exclude_trivial_metadata
  exclude_trivial <- FALSE
  if (exists('Cerebro.options') && !is.null(Cerebro.options[['exclude_trivial_metadata']])) {
    exclude_trivial <- Cerebro.options[['exclude_trivial_metadata']]
  }

  ## build choices based on setting
  if (exclude_trivial == TRUE) {
    ## only include groups from getGroups()
    metadata_cols <- getGroups()
  } else {
    ## include all metadata columns except cell_barcode
    metadata_cols <- colnames(getMetaData())[! colnames(getMetaData()) %in% c("cell_barcode")]
  }

  tagList(
    selectInput(
      "spatial_projection_to_display",
      label = "Projection",
      choices = grep("^Spatial_", availableProjections(), value = TRUE)
    ),
    selectInput(
      "spatial_projection_point_color",
      label = "Color cells by",
      choices = metadata_cols
    )
  )
})

##----------------------------------------------------------------------------##
## Info box that gets shown when pressing the "info" button.
##----------------------------------------------------------------------------##
observeEvent(input[["spatial_projection_main_parameters_info"]], {
  showModal(
    modalDialog(
      spatial_projection_main_parameters_info[["text"]],
      title = spatial_projection_main_parameters_info[["title"]],
      easyClose = TRUE,
      footer = NULL,
      size = "l"
    )
  )
})
##----------------------------------------------------------------------------##
## Text in info box.
##----------------------------------------------------------------------------##
spatial_projection_main_parameters_info <- list(
  title = "Main parameters for projection",
  text = HTML("
    The elements in this panel allow you to control what and how results are displayed across the whole tab.
    <ul>
      <li><b>Projection:</b> Select here which projection you want to see in the scatter plot on the right.</li>
      <li><b>Color cells by:</b> Select which variable, categorical or continuous, from the meta data should be used to color the cells.</li>
    </ul>
    "
  )
)

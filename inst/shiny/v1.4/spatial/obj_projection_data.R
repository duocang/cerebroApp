##----------------------------------------------------------------------------##
## Cell meta data and position in projection.
##----------------------------------------------------------------------------##
spatial_projection_data <- reactive({
  req(spatial_projection_cells_to_show())
  # message('--> trigger "spatial_projection_data"')
  cells_df <- getMetaData()[spatial_projection_cells_to_show(),]
  # message(str(cells_df))
  return(cells_df)
})

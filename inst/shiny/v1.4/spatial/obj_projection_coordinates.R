##----------------------------------------------------------------------------##
## Coordinates of cells in projection.
##----------------------------------------------------------------------------##
spatial_projection_coordinates <- reactive({
  req(
    spatial_projection_parameters_plot(),
    spatial_projection_cells_to_show()
  )
  # message('--> trigger "spatial_projection_coordinates"')
  parameters <- spatial_projection_parameters_plot()
  cells_to_show <- spatial_projection_cells_to_show()
  req(parameters[["projection"]] %in% availableProjections())
  coordinates <- getProjection(parameters[["projection"]])[cells_to_show,]
#   message(str(coordinates))
  return(coordinates)
})

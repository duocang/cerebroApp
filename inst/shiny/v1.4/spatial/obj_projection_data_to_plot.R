##----------------------------------------------------------------------------##
## Collect data required to update projection.
##----------------------------------------------------------------------------##
spatial_projection_data_to_plot_raw <- reactive({
  req(
    spatial_projection_data(),
    spatial_projection_coordinates(),
    spatial_projection_parameters_plot(),
    reactive_colors(),
    spatial_projection_hover_info(),
    nrow(spatial_projection_data()) == length(spatial_projection_hover_info()) || spatial_projection_hover_info() == "none"
  )
  # message('--> trigger "spatial_projection_data_to_plot"')
  ## get colors for groups (if applicable)
  if ( is.numeric(spatial_projection_parameters_plot()[['color_variable']]) ) {
    color_assignments <- NA
  } else {
    color_assignments <- assignColorsToGroups(
      spatial_projection_data(),
      spatial_projection_parameters_plot()[['color_variable']]
    )
  }
  ## print details for debugging purposes
  # if (
  #   exists('mode_debugging') &&
  #   mode_debugging == TRUE &&
  #   length(spatial_projection_hover_info()) > 1
  # ) {
  #   random_cells <- c(10, 51, 79)
  #   for (i in random_cells) {
  #     current_cell <- spatial_projection_data()$cell_barcode[i]
  #     coordinates_shown <- spatial_projection_coordinates()[i,]
  #     hover_shown <- spatial_projection_hover_info()[i]
  #     position_of_current_cell_in_original_data <- which(getMetaData()$cell_barcode == current_cell)
  #     coordinates_should <- data_set()$projections[[spatial_projection_parameters_plot()$projection]][position_of_current_cell_in_original_data,]
  #     message(
  #       glue::glue(
  #         '{current_cell}: ',
  #         'coords. {round(coordinates_shown[1], digits=2)}/{round(coordinates_should[1], digits=2)} // ',
  #         '{round(coordinates_shown[2], digits=2)}/{round(coordinates_should[2], digits=2)}'
  #       )
  #     )
  #   }
  # }
  ## return collect data
  to_return <- list(
    cells_df = spatial_projection_data(),
    coordinates = spatial_projection_coordinates(),
    reset_axes = isolate(spatial_projection_parameters_other[['reset_axes']]),
    plot_parameters = spatial_projection_parameters_plot(),
    color_assignments = color_assignments,
    hover_info = spatial_projection_hover_info()
  )
  # message(str(to_return))
  return(to_return)
})

spatial_projection_data_to_plot <- debounce(spatial_projection_data_to_plot_raw, 150)

##----------------------------------------------------------------------------##
## Update projection plot when spatial_projection_data_to_plot() changes.
##----------------------------------------------------------------------------##

spatial_projection_last_projection <- reactiveVal(NULL)

observeEvent(spatial_projection_data_to_plot(), {
  req(spatial_projection_data_to_plot())
  # message('update_plot')
  
  data <- spatial_projection_data_to_plot()
  spatial_projection_update_plot(data)
  
  current_projection <- data$plot_parameters$projection
  
  if (is.null(spatial_projection_last_projection()) || spatial_projection_last_projection() != current_projection) {
    updateSliderInput(session, "spatial_projection_rotation", value = 0)
    shinyjs::js$rotateSpatialProjection(0)
    spatial_projection_last_projection(current_projection)
  }
})

##----------------------------------------------------------------------------##
## Update projection plot when spatial_projection_data_to_plot() changes.
##----------------------------------------------------------------------------##
observeEvent(spatial_projection_data_to_plot(), {
  req(spatial_projection_data_to_plot())
  # message('update_plot')
  spatial_projection_update_plot(spatial_projection_data_to_plot())
  updateSliderInput(session, "spatial_projection_rotation", value = 0)
  shinyjs::js$rotateSpatialProjection(0)
})

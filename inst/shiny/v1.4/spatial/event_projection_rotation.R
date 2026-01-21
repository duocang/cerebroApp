##----------------------------------------------------------------------------##
## Update projection rotation when slider changes.
##----------------------------------------------------------------------------##
observeEvent(input$spatial_projection_rotation, {
  shinyjs::js$rotateSpatialProjection(input$spatial_projection_rotation)
})

##----------------------------------------------------------------------------##
## Update projection rotation when slider changes.
##----------------------------------------------------------------------------##
observeEvent(input$spatial_projection_rotation, {
  shinyjs::js$rotateSpatialProjection(input$spatial_projection_rotation)
})

##----------------------------------------------------------------------------##
## Reset projection rotation when Reset button is clicked.
##----------------------------------------------------------------------------##
observeEvent(input$spatial_projection_reset_rotation, {
  updateSliderInput(session, "spatial_projection_rotation", value = 0)
  shinyjs::js$rotateSpatialProjection(0)
})

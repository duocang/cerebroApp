##----------------------------------------------------------------------------##
## Collect parameters for projection plot.
##----------------------------------------------------------------------------##
spatial_projection_parameters_plot_raw <- reactive({
  req(
    input[["spatial_projection_to_display"]],
    input[["spatial_projection_to_display"]] %in% availableProjections(),
    input[["spatial_projection_point_color"]],
    input[["spatial_projection_point_color"]] %in% colnames(getMetaData()),
    input[["spatial_projection_point_size"]],
    input[["spatial_projection_point_opacity"]],
    !is.null(input[["spatial_projection_point_border"]]),
    input[["spatial_projection_scale_x_manual_range"]],
    input[["spatial_projection_scale_y_manual_range"]],
    !is.null(preferences[["use_webgl"]]),
    !is.null(preferences[["show_hover_info_in_projections"]])
  )
  # message('--> trigger "spatial_projection_parameters_plot"')
  parameters <- list(
    projection = input[["spatial_projection_to_display"]],
    n_dimensions = ncol(getProjection(input[["spatial_projection_to_display"]])),
    color_variable = input[["spatial_projection_point_color"]],
    point_size = input[["spatial_projection_point_size"]],
    point_opacity = input[["spatial_projection_point_opacity"]],
    draw_border = input[["spatial_projection_point_border"]],
    group_labels = input[["spatial_projection_show_group_label"]],
    x_range = input[["spatial_projection_scale_x_manual_range"]],
    y_range = input[["spatial_projection_scale_y_manual_range"]],
    webgl = preferences[["use_webgl"]],
    hover_info = preferences[["show_hover_info_in_projections"]]
  )
  # message(str(parameters))
  return(parameters)
})

spatial_projection_parameters_plot <- debounce(spatial_projection_parameters_plot_raw, 150)

##
spatial_projection_parameters_other <- reactiveValues(
  reset_axes = FALSE
)

##
observeEvent(input[['spatial_projection_to_display']], {
  # message('--> set "spatial: reset_axes"')
  spatial_projection_parameters_other[['reset_axes']] <- TRUE
})

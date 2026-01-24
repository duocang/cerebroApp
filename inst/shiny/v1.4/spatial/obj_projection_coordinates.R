##----------------------------------------------------------------------------##
## Coordinates of cells in projection.
##----------------------------------------------------------------------------##
spatial_projection_coordinates <- reactive({
  req(
    spatial_projection_parameters_plot(),
    spatial_projection_cells_to_show()
  )

  parameters    <- spatial_projection_parameters_plot()
  cells_to_show <- spatial_projection_cells_to_show()
  req(parameters[["projection"]] %in% availableProjections())
  coordinates <- getProjection(parameters[["projection"]])[cells_to_show,]

  message(paste0("[Debug] 获取坐标完成: 投影名称=", parameters[["projection"]], ", 细胞数量=", nrow(coordinates)))
  if (nrow(coordinates) > 0) {
    message("[Debug] 坐标前几行:")
    print(head(coordinates))
  } else {
    message("[Debug] 警告: 获取到的坐标为空!")
  }

  return(coordinates)
})

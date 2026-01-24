##----------------------------------------------------------------------------##
## Cell meta data and position in projection.
##----------------------------------------------------------------------------##
spatial_projection_metadata <- reactive({
  req(spatial_projection_cells_to_show())
  # message('--> trigger "spatial_projection_metadata"')
  metadata <- getMetaData()[spatial_projection_cells_to_show(),]

  # if ( !is.null(input[["spatial_projection_feature_to_display"]]) ) {
  #   cells_df[["feature"]] <- getExpressionMatrix()[spatial_projection_cells_to_show(), input[["spatial_projection_feature_to_display"]]]
  # }
  # message(str(cells_df))

  print("打印metadata前五行")
  print(head(metadata))
  return(metadata)
})

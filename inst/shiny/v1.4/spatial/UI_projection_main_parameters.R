##----------------------------------------------------------------------------##
## UI elements to set main parameters for the projection.
##----------------------------------------------------------------------------##
output[["spatial_projection_main_parameters_UI"]] <- renderUI({
  ## determine which metadata columns to include based on exclude_trivial_metadata
  exclude_trivial <- FALSE
  if (exists('Cerebro.options') && !is.null(Cerebro.options[['exclude_trivial_metadata']])) {
    exclude_trivial <- Cerebro.options[['exclude_trivial_metadata']]
  }

  ## build choices based on setting
  if (exclude_trivial == TRUE) {
    ## only include groups from getGroups()
    metadata_cols <- getGroups()
  } else {
    ## include all metadata columns except cell_barcode
    metadata_cols <- colnames(getMetaData())[! colnames(getMetaData()) %in% c("cell_barcode")]
  }

  ## prepare background image choices
  background_choices <- c("No Background")
  if (exists("Cerebro.options") && !is.null(Cerebro.options[["spatial_images"]]) &&
      exists("available_crb_files") && !is.null(available_crb_files$selected)) {
    match_idx <- which(available_crb_files$files == available_crb_files$selected)
    if (length(match_idx) > 0) {
      current_name <- names(available_crb_files$files)[match_idx[1]]
      if (!is.null(current_name) && current_name %in% names(Cerebro.options[["spatial_images"]])) {
        background_choices <- c("No Background", Cerebro.options[["spatial_images"]][[current_name]])
      }
    }
  }

  tagList(
    selectInput(
      "spatial_projection_to_display",
      label = "Projection",
      choices = grep("^Spatial_", availableProjections(), value = TRUE)
    ),
    selectInput(
      "spatial_projection_plot_type",
      label = "Plot type",
      choices = c("ImageDimPlot", "ImageFeaturePlot"),
      selected = "ImageDimPlot"
    ),
    conditionalPanel(
      condition = "input.spatial_projection_plot_type == 'ImageDimPlot'",
      selectInput(
        "spatial_projection_point_color",
        label = "Color cells by",
        choices = metadata_cols
      )
    ),
    conditionalPanel(
      condition = "input.spatial_projection_plot_type == 'ImageFeaturePlot'",
      selectizeInput(
        "spatial_projection_feature_to_display",
        label = "Feature/Gene",
        choices = getGeneNames(),
        multiple = FALSE,
        options = list(
          maxOptions = 1000,
          placeholder = 'Select a gene...',
          create = FALSE,
          loadThrottle = 300
        )
      )
    ),
    if (length(background_choices) > 1) {
      tagList(
        selectInput(
          "spatial_projection_background_image",
          label = "Background image",
          choices = background_choices,
          selected = "No Background"
        ),
        conditionalPanel(
          condition = "input.spatial_projection_background_image && input.spatial_projection_background_image !== 'No Background'",
          tagList(
            tags$style(HTML("
              .flip-btn {
                transition: all 0.4s ease;
                min-width: 100px;
                transform-style: preserve-3d;
                perspective: 500px;
              }
              .flip-btn-x:hover {
                transform: rotateY(180deg);
                box-shadow: 0 2px 8px rgba(0,0,0,0.2);
              }
              .flip-btn-y:hover {
                transform: rotateX(180deg);
                box-shadow: 0 2px 8px rgba(0,0,0,0.2);
              }
              .flip-btn:active {
                transform: scale(0.95);
              }
              .flip-btn.flipped {
                background-color: #46637F !important;
                border-color: #46637F !important;
                color: white !important;
              }
            ")),
            div(
              style = "display: flex; justify-content: center; margin-top: 6px;",
              actionButton(
                inputId = "spatial_projection_background_reset",
                label = "Reset",
                class = "btn-xs"
              )
            ),
            div(
              style = "display: flex; justify-content: center; gap: 6px; margin-top: 6px; perspective: 500px;",
              actionButton(
                inputId = "spatial_projection_background_flip_x",
                label = "Flip Left/Right",
                class = "btn-xs flip-btn flip-btn-x"
              ),
              actionButton(
                inputId = "spatial_projection_background_flip_y",
                label = "Flip Up/Down",
                class = "btn-xs flip-btn flip-btn-y"
              )
            ),
            sliderInput(
              inputId = "spatial_projection_background_scale_x",
              label = "Stretch Left/Right",
              min = 0.5,
              max = 1.5,
              value = 1,
              step = 0.05
            ),
            sliderInput(
              inputId = "spatial_projection_background_scale_y",
              label = "Stretch Up/Down",
              min = 0.5,
              max = 1.5,
              value = 1,
              step = 0.05
            ),
            sliderInput(
              inputId = "spatial_projection_background_opacity",
              label = "Image opacity",
              min = 0,
              max = 1,
              value = 0.6,
              step = 0.05
            )
          )
        )
      )
    }
  )
})

##----------------------------------------------------------------------------##
## Info box that gets shown when pressing the "info" button.
##----------------------------------------------------------------------------##
observeEvent(input[["spatial_projection_main_parameters_info"]], {
  showModal(
    modalDialog(
      spatial_projection_main_parameters_info[["text"]],
      title = spatial_projection_main_parameters_info[["title"]],
      easyClose = TRUE,
      footer = NULL,
      size = "l"
    )
  )
})
##----------------------------------------------------------------------------##
## Text in info box.
##----------------------------------------------------------------------------##
spatial_projection_main_parameters_info <- list(
  title = "Main parameters for projection",
  text = HTML("
    The elements in this panel allow you to control what and how results are displayed across the whole tab.
    <ul>
      <li><b>Projection:</b> Select here which projection you want to see in the scatter plot on the right.</li>
      <li><b>Color cells by:</b> Select which variable, categorical or continuous, from the meta data should be used to color the cells.</li>
    </ul>
    "
  )
)

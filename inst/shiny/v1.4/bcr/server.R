##----------------------------------------------------------------------------##
## Tab: BCR server
##----------------------------------------------------------------------------##

## Helper: safe plot wrapper when scRepertoire is missing or errors occur
.safeRenderPlot <- function(expr, plot_name = "unknown") {
  result <- tryCatch({
    message("[BCR DEBUG] Rendering plot: ", plot_name)
    p <- expr
    message("[BCR DEBUG] Plot '", plot_name, "' rendered successfully")
    p
  }, error = function(e) {
    message("[BCR ERROR] Plot '", plot_name, "' failed: ", e$message)
    plot.new()
    text(0.5, 0.5, paste("Error in", plot_name, ":\n", e$message), cex = 0.8)
  })
  return(result)
}

observeEvent(input$bcr_cloneCall, ignoreInit = TRUE, { })

## Observer to update cloneCall choices based on active tab
observeEvent(input$bcr_tabs, {
  req(.has_scRepertoire())

  if (input$bcr_tabs %in% c("Length", "K-mer")) {
    updateSelectInput(
      session,
      "bcr_cloneCall",
      choices = c("nt", "aa"),
      selected = ifelse(input$bcr_cloneCall %in% c("nt", "aa"), input$bcr_cloneCall, "aa")
    )
  } else if (input$bcr_tabs %in% c("Gene usage", "vizGenes", "percentGenes", "percentVJ", "AA %", "Entropy")) {
    updateSelectInput(
      session,
      "bcr_cloneCall",
      choices = NULL,
      selected = NULL
    )
  } else {
    updateSelectInput(
      session,
      "bcr_cloneCall",
      choices = c("gene", "nt", "aa", "strict"),
      selected = input$bcr_cloneCall
    )
  }

  shinyjs::toggleElement(
    id = "bcr_scatter_x",
    anim = TRUE,
    condition = input$bcr_tabs %in% c("Scatter")
  )
  shinyjs::toggleElement(
    id = "bcr_scatter_y",
    anim = TRUE,
    condition = input$bcr_tabs %in% c("Scatter")
  )
  shinyjs::toggleElement(
    id = "bcr_compare_samples",
    anim = TRUE,
    condition = input$bcr_tabs %in% c("Compare")
  )
})

## BCR settings UI
output$bcr_settings_UI <- renderUI({
  req(.has_scRepertoire())

  bcr <- getBCR()
  available_groups <- c(NULL)
  available_samples <- c()

  if (!is.null(bcr) && is.list(bcr) && length(bcr) > 0) {
    all_groups <- getGroups()
    bcr_cols <- names(bcr[[1]])
    available_groups <- c(NULL, intersect(all_groups, bcr_cols))
    available_samples <- names(bcr)
  }

  tagList(
    fluidRow(
      column(
        width = 6,
        selectInput(
          "bcr_cloneCall",
          label = "Clone call:",
          choices = c("gene", "nt", "aa", "strict"),
          selected = "gene"
        )
      ),
      column(
        width = 6,
        selectInput(
          "bcr_groupBy",
          label = "Group by:",
          choices = available_groups,
          selected = "none"
        )
      )
    ),
    fluidRow(
      column(
        width = 6,
        selectInput(
          "bcr_chain",
          label = "Chain:",
          choices = c("both", "TRA", "TRB", "TRG", "TRD", "IGH", "IGK", "IGL"),
          selected = "both"
        )
      )
    ),
    fluidRow(
      column(
        width = 6,
        selectInput(
          "bcr_scatter_x",
          label = "Sample 1 (for Scatter):",
          choices = available_samples,
          selected = if (length(available_samples) >= 1) available_samples[1] else NULL
        )
      ),
      column(
        width = 6,
        selectInput(
          "bcr_scatter_y",
          label = "Sample 2 (for Scatter):",
          choices = available_samples,
          selected = if (length(available_samples) >= 2) available_samples[2] else if (length(available_samples) >= 1) available_samples[1] else NULL
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        selectInput(
          "bcr_compare_samples",
          label = "Samples for Compare (select at least 2):",
          choices = available_samples,
          selected = if (length(available_samples) >= 2) available_samples[1:2] else available_samples,
          multiple = TRUE
        )
      )
    )
  )
})

## Reactive BCR object
bcr_data <- reactive({
  message("[BCR DEBUG] bcr_data() called")
  bcr <- getBCR()
  if (is.null(bcr)) {
    message("[BCR DEBUG] getBCR() returned NULL")
    return(NULL)
  }
  message("[BCR DEBUG] getBCR() returned data of class: ", paste(class(bcr), collapse = ", "))
  message("[BCR DEBUG] BCR data length: ", length(bcr))
  if (is.list(bcr) && length(bcr) > 0) {
    message("[BCR DEBUG] First element class: ", paste(class(bcr[[1]]), collapse = ", "))
    if (is.data.frame(bcr[[1]])) {
      message("[BCR DEBUG] First element has ", nrow(bcr[[1]]), " rows and ", ncol(bcr[[1]]), " columns")
      message("[BCR DEBUG] Column names: ", paste(head(names(bcr[[1]]), 10), collapse = ", "))
    }
  }
  req(!is.null(bcr))

  return(bcr)
})

## Reactive parameters for BCR visualizations
bcr_params <- reactive({
  list(
    cloneCall = input$bcr_cloneCall,
    groupBy = input$bcr_groupBy
  )
})

## Reactive to check if current tab needs cloneCall parameter
needs_cloneCall <- reactive({
  !input$bcr_tabs %in% c("Gene usage", "vizGenes", "percentGenes", "percentVJ", "AA %", "Entropy")
})

## Visualizations UI ---------------------------------------------------------##
output$bcr_visualizations_UI <- renderUI({
  req(.has_scRepertoire())
  tagList(
    tabsetPanel(
      id = "bcr_tabs",
      tabPanel("Abundance", plotOutput("bcr_plot_clonalAbundance", height = 450)),
      tabPanel("Compare", plotOutput("bcr_plot_clonalCompare", height = 450)),
      tabPanel("Diversity", plotOutput("bcr_plot_clonalDiversity", height = 450)),
      tabPanel("Homeostasis", plotOutput("bcr_plot_clonalHomeostasis", height = 450)),
      tabPanel("Length", plotOutput("bcr_plot_clonalLength", height = 450)),
      tabPanel("Overlap", plotOutput("bcr_plot_clonalOverlap", height = 450)),
      tabPanel("Proportion", plotOutput("bcr_plot_clonalProportion", height = 450)),
      tabPanel("Quant", plotOutput("bcr_plot_clonalQuant", height = 450)),
      tabPanel("Rarefaction", plotOutput("bcr_plot_clonalRarefaction", height = 450)),
      tabPanel("Scatter", plotOutput("bcr_plot_clonalScatter", height = 450)),
      tabPanel("SizeDist", plotOutput("bcr_plot_clonalSizeDistribution", height = 450)),
      tabPanel("Gene usage", plotOutput("bcr_plot_percentGeneUsage", height = 450)),
      tabPanel("vizGenes", plotOutput("bcr_plot_vizGenes", height = 450)),
      tabPanel("percentGenes", plotOutput("bcr_plot_percentGenes", height = 450)),
      tabPanel("percentVJ", plotOutput("bcr_plot_percentVJ", height = 450)),
      tabPanel("AA %", plotOutput("bcr_plot_percentAA", height = 450)),
      tabPanel("Entropy", plotOutput("bcr_plot_positionalEntropy", height = 450)),
      tabPanel("Property", plotOutput("bcr_plot_positionalProperty", height = 450)),
      tabPanel("K-mer", plotOutput("bcr_plot_percentKmer", height = 450))
    )
  )
})

## Renderers for each visualization ------------------------------------------------
output$bcr_plot_clonalAbundance <- renderPlot({
  req(.has_scRepertoire())
  message("[BCR DEBUG] Entering clonalAbundance renderer")
  pars <- bcr_params()
  data <- bcr_data()
  message("[BCR DEBUG] Data for clonalAbundance - class: ", paste(class(data), collapse = ", "))
  message("[BCR DEBUG] Params - cloneCall: ", pars$cloneCall, ", groupBy: ", pars$groupBy)
  .safeRenderPlot({
    scRepertoire::clonalAbundance(data, cloneCall = pars$cloneCall)
  }, plot_name = "clonalAbundance")
})

output$bcr_plot_clonalCompare <- renderPlot({
  req(.has_scRepertoire())
  req(!is.null(input$bcr_compare_samples) && length(input$bcr_compare_samples) >= 2)
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalCompare(
      bcr_data(),
      cloneCall = pars$cloneCall,
      chain = "both",
      samples = input$bcr_compare_samples,
      clones = NULL,
      top.clones = 5,
      highlight.clones = NULL,
      relabel.clones = FALSE,
      group.by = NULL,
      order.by = NULL,
      graph = "alluvial",
      proportion = TRUE,
      exportTable = FALSE,
      palette = "inferno"
    )
  }, plot_name = "clonalCompare")
})

output$bcr_plot_clonalDiversity <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalDiversity(
      bcr_data(),
      cloneCall = pars$cloneCall,
      metric = "shannon",
      chain = "both",
      group.by = NULL,
      order.by = NULL,
      x.axis = NULL,
      exportTable = FALSE,
      palette = "inferno",
      n.boots = 100,
      return.boots = FALSE,
      skip.boots = FALSE)
  }, plot_name = "clonalDiversity")
})

output$bcr_plot_clonalHomeostasis <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalHomeostasis(
      bcr_data(),
      chain = input$bcr_chain,
      cloneCall = pars$cloneCall,
      # group.by = pars$groupBy,
      group.by = NULL,
      order.by = NULL,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalHomeostasis")
})

output$bcr_plot_clonalLength <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalLength(
      bcr_data(),
      chain = input$bcr_chain,
      cloneCall = pars$cloneCall,
      # group.by = pars$groupBy,
      group.by = NULL,
      order.by = NULL,
      scale = FALSE,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalLength")
})

output$bcr_plot_clonalOverlap <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalOverlap(
      bcr_data(),
      cloneCall = pars$cloneCall,
      method = "overlap", # method = c("overlap", "morisita", "jaccard", "cosine", "raw"),
      chain = "both",
      group.by = NULL,
      order.by = NULL,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalOverlap")
})

output$bcr_plot_clonalProportion <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalProportion(
      bcr_data(),
      clonalSplit = c(10, 100, 1000, 10000, 30000, 1e+05),
      chain = input$bcr_chain,
      cloneCall = pars$cloneCall,
      group.by = pars$groupBy,
      order.by = NULL,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalProportion")
})

output$bcr_plot_clonalQuant <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalQuant(
      bcr_data(),
      cloneCall = pars$cloneCall,
      chain = input$bcr_chain,
      scale = FALSE,
      group.by = pars$groupBy,
      order.by = NULL,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalQuant")
})

output$bcr_plot_clonalRarefaction <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalRarefaction(
      bcr_data(),
      cloneCall = pars$cloneCall,
      chain = input$bcr_chain,
      group.by = pars$groupBy,
      plot.type = 1,
      hill.numbers = 0,
      n.boots = 20,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalRarefaction")
})

output$bcr_plot_clonalScatter <- renderPlot({
  req(.has_scRepertoire())
  req(!is.null(input$bcr_scatter_x) && !is.null(input$bcr_scatter_y))
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalScatter(
      bcr_data(),
      cloneCall = pars$cloneCall,
      x.axis = input$bcr_scatter_x,
      y.axis = input$bcr_scatter_y,
      chain = input$bcr_chain,
      dot.size = "total",
      group.by = pars$groupBy,
      graph = "proportion",
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalScatter")
})

output$bcr_plot_clonalSizeDistribution <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::clonalSizeDistribution(
      bcr_data(),
      cloneCall = pars$cloneCall,
      chain = input$bcr_chain,
      method = "ward.D2",
      threshold = 1,
      group.by = pars$groupBy,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "clonalSizeDistribution")
})

output$bcr_plot_percentGeneUsage <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::percentGeneUsage(
      bcr_data(),
      chain = input$bcr_chain,
      genes = "TRBV",
      group.by = pars$groupBy,
      order.by = NULL,
      summary.fun = "percent", # summary.fun = c("percent", "proportion", "count"),
      plot.type = "heatmap",
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "percentGeneUsage")
})

output$bcr_plot_vizGenes <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::vizGenes(
      bcr_data(),
      x.axis = "TRBV",
      y.axis = NULL,
      group.by = pars$groupBy,
      plot = "heatmap",
      order.by = NULL,
      summary.fun = "count", # summary.fun = c("percent", "proportion", "count")
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "vizGenes")
})

output$bcr_plot_percentGenes <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::percentGenes(
      bcr_data(),
      chain = input$bcr_chain,
      gene = "Vgene",
      group.by = pars$groupBy,
      order.by = NULL,
      exportTable = FALSE,
      summary.fun = "percent",  # summary.fun = c("percent", "proportion", "count")
      palette = "inferno")
  }, plot_name = "percentGenes")
})

output$bcr_plot_percentVJ <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::percentVJ(
      bcr_data(),
      chain = input$bcr_chain,
      group.by = pars$groupBy,
      order.by = NULL,
      exportTable = FALSE,
      summary.fun = "percent",  # summary.fun = c("percent", "proportion", "count")
      palette = "inferno")
  }, plot_name = "percentVJ")
})

output$bcr_plot_percentAA <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::percentAA(
      bcr_data(),
      chain = input$bcr_chain,
      group.by = pars$groupBy,
      order.by = NULL,
      aa.length = 20,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "percentAA")
})

output$bcr_plot_positionalEntropy <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::positionalEntropy(
      bcr_data(),
      chain = input$bcr_chain,
      group.by = pars$groupBy,
      order.by = NULL,
      aa.length = 20,
      method = "norm.entropy",
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "positionalEntropy")
})

output$bcr_plot_positionalProperty <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::positionalProperty(
      bcr_data(),
      chain = input$bcr_chain,
      group.by = pars$groupBy,
      order.by = NULL,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "positionalProperty")
})

output$bcr_plot_percentKmer <- renderPlot({
  req(.has_scRepertoire())
  pars <- bcr_params()
  .safeRenderPlot({
    scRepertoire::percentKmer(
      bcr_data(),
      chain = input$bcr_chain,
      cloneCall = pars$cloneCall,
      group.by = pars$groupBy,
      motif.length = 3,
      min.depth = 3,
      top.motifs = 30,
      exportTable = FALSE,
      palette = "inferno")
  }, plot_name = "percentKmer")
})

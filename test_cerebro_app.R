devtools::load_all(".")

# Test authentication functionality with debug output
test_data1 <- system.file("extdata/v1.4/example.crb", package = "cerebroApp")
cerebro_data <- c(`pbmc_10k_1` = test_data1,
                  `pbmc_10k_2` = test_data1)

# Create app with authentication enabled
result_dir <- "test_cerebro_app"

message("Removing existing test_cerebro_app directory...\n")
unlink(result_dir, recursive = TRUE)

colors <-  list(
  `pbmc_10k_1` = list(
    `sample` = c(Ctrl = "black", MS = "#3d70b5", "Sample3" = "#ee756d"),
    `seurat_clusters` = c(
      "0" = "#66c69b",
      "1" = "#ee756d",
      "2" = "#d49005",
      "3" = "#7caee5",
      "4" = "#87be4d",
      "5" = "#3cac57")
  )
)

message("Creating Cerebro app...\n")
tryCatch({
  createTraditionalShinyApp(
    cerebro_data = cerebro_data,
    result_dir = result_dir,
    colors = colors,
    version = "v1.4",
    port = 8080,
    max_request_size = 10000,
    enable_auth = TRUE,
    admin_user = "admin",
    admin_pass = "admin#123",
    users = c("user1", "user2"),
    users_pass = c("pass1", "pass2"),
    auth_passphrase = "test123",
    overwrite = TRUE,
    verbose = TRUE
  )

  cat("\n=== Debug: Checking app.R file ===\n")
  app_file <- file.path(result_dir, "app.R")
  app_lines <- readLines(app_file)

  cat("Total lines in app.R:", length(app_lines), "\n")

  # Find shinyApp call
  shinyapp_idx <- grep("shiny::shinyApp\\(", app_lines)
  cat("Found shinyApp at line(s):", shinyapp_idx, "\n")

  if (length(shinyapp_idx) > 0) {
    cat("Content around shinyApp:\n")
    start <- max(1, shinyapp_idx[1] - 5)
    end <- min(length(app_lines), shinyapp_idx[1] + 5)
    for (i in start:end) {
      cat(sprintf("%3d: %s\n", i, app_lines[i]))
    }
  }

  # Check for secure_ui
  secure_ui_idx <- grep("secure_ui", app_lines)
  cat("\nFound secure_ui at line(s):", secure_ui_idx, "\n")

  # Check for secure_server
  secure_server_idx <- grep("secure_server", app_lines)
  cat("Found secure_server at line(s):", secure_server_idx, "\n")

}, error = function(e) {
  cat("Error:", conditionMessage(e), "\n")
  traceback()
})

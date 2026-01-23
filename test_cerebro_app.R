devtools::load_all(".")

# Test authentication functionality with debug output
test_data <- system.file("extdata/v1.4/example.crb", package = "cerebroApp")

# Create app with authentication enabled
result_dir <- "test_cerebro_app"

message("Removing existing test_cerebro_app directory...\n")
unlink(result_dir, recursive = TRUE)

message("Creating Cerebro app...\n")
tryCatch({
  createTraditionalShinyApp(
    cerebro_data = test_data,
    result_dir = result_dir,
    version = "v1.4",
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

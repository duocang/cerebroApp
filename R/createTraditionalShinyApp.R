

# 添加智能缩进处理函数 Add intelligent indentation processing function
#' Remove Common Leading Whitespace from a String
#'
#' This utility function eliminates the minimal common indentation shared by all
#' non-empty lines of the input string, preserving relative indentation within blocks.
#'
#' @param string A character string containing text with indentation
#'
#' @return A character string with shared indentation removed. Output retains:
#'   - Relative indentation between lines
#'   - Trailing whitespace (after content)
#'   - Purely empty lines
#'
#' @examples
#' code <- "
#'     first line
#'         indented line
#'     last line
#' "
#' dedent(code)
#'
#' @keywords internal
#' @noRd
dedent <- function(string) {
  # Input validation
  if (!is.character(string) || length(string) != 1) {
    stop("Input must be a single character string")
  }

  # Split string into lines
  lines <- strsplit(string, "\n", fixed = TRUE)[[1]]

  # Remove leading and trailing empty lines
  while (length(lines) > 0 && grepl("^\\s*$", lines[1])) {
    lines <- lines[-1]
  }
  while (length(lines) > 0 && grepl("^\\s*$", lines[length(lines)])) {
    lines <- lines[-length(lines)]
  }

  if (length(lines) == 0) return("")

  # Identify minimum indentation from non-empty lines
  non_empty_lines <- lines[!grepl("^\\s*$", lines)]
  if (length(non_empty_lines) == 0) return("")

  # Calculate minimal indentation
  lead_spaces <- vapply(non_empty_lines, function(line) {
    nchar(sub("^(\\s*).*", "\\1", line))
  }, integer(1), USE.NAMES = FALSE)
  min_indent <- min(lead_spaces)

  # Remove common indentation from all lines
  dedented <- vapply(lines, function(line) {
    if (grepl("^\\s*$", line)) {
      ""  # Preserve blank lines as empty strings
    } else if (nchar(line) > min_indent) {
      substring(line, min_indent + 1)
    } else {
      line
    }
  }, character(1), USE.NAMES = FALSE)

  # Reassemble and return
  paste(dedented, collapse = "\n")
}

#' Format R Object to String with Pretty Printing
#'
#' Convert an R object to a nicely formatted string representation.
#'
#' @param obj An R object to format
#' @param indent Number of spaces for base indentation. Default is 0.
#'
#' @return A character string with formatted R code
#'
#' @keywords internal
#' @noRd
formatRObject <- function(obj, indent = 0) {
  indent_str <- strrep(" ", indent)

  if (is.list(obj) && !is.data.frame(obj)) {
    if (length(obj) == 0) {
      return("list()")
    }

    items <- character(length(obj))
    for (i in seq_along(obj)) {
      name <- names(obj)[i]
      value <- obj[[i]]

      # Format value recursively
      if (is.list(value) && !is.data.frame(value)) {
        value_str <- formatRObject(value, indent + 2)
      } else if (is.character(value) && length(value) > 0) {
        # Format named character vectors nicely
        if (!is.null(names(value))) {
          pairs <- paste0('"', names(value), '" = "', value, '"')
          if (length(pairs) > 3) {
            # Multi-line for long vectors
            value_str <- paste0("c(\n",
                               paste0(strrep(" ", indent + 4), pairs, collapse = ",\n"),
                               "\n", strrep(" ", indent + 2), ")")
          } else {
            value_str <- paste0("c(", paste(pairs, collapse = ", "), ")")
          }
        } else {
          value_str <- deparse(value, width.cutoff = 500)
        }
      } else {
        value_str <- deparse(value, width.cutoff = 500)
      }

      # Format the list item
      if (!is.null(name) && nzchar(name)) {
        items[i] <- paste0("`", name, "` = ", value_str)
      } else {
        items[i] <- value_str
      }
    }

    # Assemble list
    if (length(items) > 2 || any(grepl("\n", items))) {
      # Multi-line format
      result <- paste0("list(\n",
                      paste0(strrep(" ", indent + 2), items, collapse = ",\n"),
                      "\n", strrep(" ", indent), ")")
    } else {
      # Single-line format
      result <- paste0("list(", paste(items, collapse = ", "), ")")
    }
    return(result)
  } else {
    return(deparse(obj, width.cutoff = 500))
  }
}


#' Create Traditional Shiny Application
#'
#' This function generates a complete Shiny application structure for visualizing
#' Cerebro data. It copies the necessary Shiny source files, data files, and
#' creates an app.R file configured to launch the Cerebro visualization interface.
#'
#' @param cerebro_data Character vector. Path(s) to the Cerebro .crb file(s) to be visualized.
#'   Can be a single path or a named vector for multiple datasets.
#' @param result_dir Character. Directory where the Shiny app structure will be
#'   created. Default is "result/20_cerebro_shinyapp".
#' @param version Character. Version of the Cerebro Shiny interface to use.
#'   Default is "v1.3".
#' @param max_request_size Numeric. Maximum file upload size in MB. Default is 8000.
#' @param port Numeric. Port number for the Shiny server. Default is 1337.
#' @param host Character. Host address for the Shiny server. Use "0.0.0.0" to
#'   allow external access, or "127.0.0.1" for localhost only. Default is "127.0.0.1".
#' @param launch_browser Logical. If TRUE, automatically open the app in the
#'   default web browser when launched. Default is TRUE.
#' @param quiet Logical. If TRUE, suppress Shiny server startup messages.
#'   Default is FALSE.
#' @param display_mode Character. Display mode for the app: "normal" or "showcase".
#'   Default is "normal".
#' @param colors List. Optional nested list of color schemes for different datasets.
#'   Default is NULL.
#' @param cerebro_options List. Additional options to pass to Cerebro.options.
#'   Default is list(exclude_trivial_metadata = TRUE).
#' @param overwrite Logical. If TRUE, existing result_dir will be deleted before
#'   creating new files. Default is TRUE.
#' @param verbose Logical. If TRUE, prints detailed progress messages. Default is TRUE.
#' @param enable_auth Logical. If TRUE, enables authentication using shinymanager.
#'   Default is FALSE.
#' @param admin_user Character. Admin username. Default is "admin".
#' @param admin_pass Character. Admin password. Default is "admin#123".
#' @param users Character vector. Additional usernames. Default is NULL.
#' @param users_pass Character vector. Passwords for additional users. Default is NULL.
#' @param auth_passphrase Character. Passphrase for encrypting credentials database.
#'   Default is "123123".
#'
#' @return Invisibly returns the path to the result directory.
#'
#' @details
#' The function creates the following directory structure:
#' \itemize{
#'   \item result_dir/shiny/ - Contains Shiny UI and server source files
#'   \item result_dir/data/ - Contains the Cerebro .crb data file(s)
#'   \item result_dir/app.R - Main application file to launch the Shiny app
#' }
#'
#' @examples
#' \dontrun{
#' # Basic usage with single dataset
#' createTraditionalShinyApp(
#'   cerebro_data = "result/cerebro_all.crb"
#' )
#'
#' # Multiple datasets with custom colors
#' createTraditionalShinyApp(
#'   cerebro_data = c(
#'     `All cells` = "result/cerebro_all.crb",
#'     `B cells` = "result/cerebro_Bc.crb"
#'   ),
#'   colors = list(
#'     `All cells` = list(condition = c(Ctrl = "black", MS = "blue")),
#'     `B cells` = list(cluster = c(B1 = "red", B2 = "green"))
#'   ),
#'   port = 8080,
#'   host = "0.0.0.0",  # Allow external access
#'   launch_browser = FALSE
#' )
#' }
#'
#' @export
createTraditionalShinyApp <- function(cerebro_data,
                                      result_dir = NULL,
                                      version = "v1.4",
                                      max_request_size = 8000,
                                      port = 1337,
                                      host = "127.0.0.1",
                                      launch_browser = TRUE,
                                      quiet = FALSE,
                                      display_mode = "normal",
                                      colors = NULL,
                                      cerebro_options = list(exclude_trivial_metadata = TRUE),
                                      overwrite = TRUE,
                                      verbose = TRUE,
                                      enable_auth = FALSE,
                                      admin_user = "admin",
                                      admin_pass = "admin#123",
                                      users = NULL,
                                      users_pass = NULL,
                                      auth_passphrase = "123123") {

  # Validate input parameters ------------------------------------------------##
  if (!all(file.exists(cerebro_data))) {
    missing <- cerebro_data[!file.exists(cerebro_data)]
    stop("Cerebro data file(s) not found: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  if (!all(grepl("\\.crb$", cerebro_data))) {
    warning("Some input files do not have .crb extension. Make sure they are valid Cerebro files.")
  }

  # Enforce named list/vector for cerebro_data
  if (is.null(names(cerebro_data)) || any(names(cerebro_data) == "")) {
    stop("cerebro_data must be a named list or vector, and every element must have a name.", call. = FALSE)
  }

  # Validate colors if provided
  if (!is.null(colors)) {
    if (is.null(names(colors)) || any(names(colors) == "")) {
      stop("colors must be a named list or vector.", call. = FALSE)
    }

    if (length(intersect(names(colors), names(cerebro_data))) == 0) {
      warning("Colors and cerebro_data do not match, random colors will be used.", call. = FALSE)
      colors <- NULL
    }
  }

  # Check if cerebroApp package is available
  if (!requireNamespace("cerebroApp", quietly = TRUE)) {
    stop("Package 'cerebroApp' is required but not installed.", call. = FALSE)
  }

  # Setup directories ---------------------------------------------------------##
  shiny_dir   <- file.path(result_dir, 'shiny')
  data_dir    <- file.path(result_dir, 'data')
  app_file    <- file.path(result_dir, 'app.R')

  # Prepare Shiny files -------------------------------------------------------##
  if (overwrite && dir.exists(result_dir)) {
    if (verbose) cat("Removing existing directory:", result_dir, "\n")
    unlink(result_dir, recursive = TRUE, force = TRUE)
  }

  if (verbose) cat("Creating directory structure...\n")
  dir.create(shiny_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

  # Copy Shiny source files ---------------------------------------------------##
  shiny_source <- system.file('shiny', version, package = 'cerebroApp')
  if (!dir.exists(shiny_source)) {
    stop("Shiny source files for version '", version, "' not found in cerebroApp package.",
         call. = FALSE)
  }

  if (verbose) cat("Copying Shiny source files (version", version, ")...\n")
  copy_result <- file.copy(shiny_source, shiny_dir, recursive = TRUE)
  if (!copy_result) {
    stop("Failed to copy Shiny source files.", call. = FALSE)
  }

  # Copy Cerebro data file(s) -------------------------------------------------##
  if (verbose) cat("Copying Cerebro data file(s)...\n")
  for (file in cerebro_data) {
    if (verbose) cat("  -", basename(file), "\n")
    copy_result <- file.copy(file, data_dir, recursive = TRUE)
    if (!copy_result) {
      stop("Failed to copy Cerebro data file: ", basename(file), call. = FALSE)
    }
  }

  # Copy extdata files (if any) -----------------------------------------------##
  if (verbose) cat("Copying extdata files...\n")
  extdata_source <- system.file('extdata', package = 'cerebroApp')
  if (!dir.exists(extdata_source)) {
    stop("extdata source files not found in cerebroApp package.", call. = FALSE)
  }
  copy_extdata <- file.copy(extdata_source, result_dir, recursive = TRUE)
  if (!copy_extdata) {
    stop("Failed to copy extdata files.", call. = FALSE)
  }

  # Setup authentication (if enabled) ----------------------------------------##
  auth_enabled <- FALSE
  if (enable_auth) {
    if (verbose) cat("Setting up authentication system...\n")

    # Check if shinymanager is available
    if (!requireNamespace("shinymanager", quietly = TRUE)) {
      stop("Package 'shinymanager' is required for authentication but not installed.",
           "Please install it with: install.packages('shinymanager')", call. = FALSE)
    }

    # Validate users and passwords
    if (!is.null(users) && is.null(users_pass)) {
      stop("'users_pass' must be provided when 'users' is specified.", call. = FALSE)
    }
    if (!is.null(users_pass) && is.null(users)) {
      stop("'users' must be provided when 'users_pass' is specified.", call. = FALSE)
    }
    if (!is.null(users) && !is.null(users_pass) && length(users) != length(users_pass)) {
      stop("'users' and 'users_pass' must have the same length.", call. = FALSE)
    }

    # Build users data frame
    users_list <- list(
      user = c(admin_user, users),
      password = c(admin_pass, users_pass),
      admin = c(TRUE, rep(FALSE, length(users)))
    )
    users_df <- do.call(data.frame, c(users_list, stringsAsFactors = FALSE))

    # Set up credentials database path
    sqlite_path <- file.path(result_dir, "credentials.sqlite")

    # Remove existing database if it exists
    if (file.exists(sqlite_path)) {
      if (verbose) cat("  Removing existing credentials database...\n")
      file.remove(sqlite_path)
    }

    # Create credentials database
    tryCatch({
      shinymanager::create_db(
        credentials_data = users_df,
        sqlite_path = sqlite_path,
        passphrase = auth_passphrase
      )
      auth_enabled <- TRUE
      if (verbose) {
        info <- file.info(sqlite_path)
        cat("  Created credentials database:", normalizePath(sqlite_path), "\n")
        cat("  Database size:", info$size, "bytes\n")
        cat("  Admin user:", admin_user, "\n")
        if (!is.null(users)) {
          cat("  Additional users:", paste(users, collapse = ", "), "\n")
        }
      }
    }, error = function(e) {
      stop("Failed to create credentials database: ", conditionMessage(e), call. = FALSE)
    })
  }

  # Create app.R file ---------------------------------------------------------##
  if (verbose) cat("Generating app.R file...\n")

  # Generate colors code if provided
  colors_code <- ""
  if (!is.null(colors)) {
    colors_formatted <- formatRObject(colors, indent = 0)
    colors_code <- paste0("colors <- ", colors_formatted, "\n")
  }

  # Generate crb_file_to_load configuration
  # Multiple files or named vector (names are enforced now)
  file_vector <- sapply(seq_along(cerebro_data), function(i) {
    sprintf('`%s` = "data/%s"', names(cerebro_data)[i], basename(cerebro_data[i]))
  })
  crb_load_code <- paste0("c(", paste(file_vector, collapse = ",\n                          "), ")")
  crb_files_code <- ""

  # Generate additional Cerebro options
  extra_options <- ""
  if (length(cerebro_options) > 0) {
    for (opt_name in names(cerebro_options)) {
      opt_value <- cerebro_options[[opt_name]]
      if (is.logical(opt_value)) {
        extra_options <- paste0(extra_options, ',\n  ', opt_name, ' = ', toupper(as.character(opt_value)))
      } else if (is.character(opt_value)) {
        extra_options <- paste0(extra_options, ',\n  ', opt_name, ' = "', opt_value, '"')
      } else {
        extra_options <- paste0(extra_options, ',\n  ', opt_name, ' = ', deparse(opt_value))
      }
    }
  }

  # Add colors to cerebro_options if provided
  colors_option <- if (!is.null(colors)) ',\n  "colors" = colors' else ''

  # Generate authentication code if enabled
  auth_code <- ""
  auth_wrapper_code <- ""
  app_ui_code <- "ui"
  app_server_code <- "server"

  if (auth_enabled) {
    auth_code <- glue::glue('
# Authentication setup
library(shinymanager)

credentials_path <- file.path(cerebro_root, "credentials.sqlite")
auth_passphrase <- "{auth_passphrase}"

# Check if credentials database exists
if (!file.exists(credentials_path)) {{
  stop("Credentials database not found: ", credentials_path)
}}

# Initialize credentials check
check_credentials <- shinymanager::check_credentials(
  credentials_path,
  passphrase = auth_passphrase
)
')
    auth_wrapper_code <- glue::glue('
# Wrap UI with secure_app
secure_ui <- shinymanager::secure_app(ui)
')
    app_ui_code <- "secure_ui"
    app_server_code <- 'function(input, output, session) {
  res_auth <- shinymanager::secure_server(check_credentials = check_credentials)
  server(input, output, session)
}'
  }

  # Generate app.R content
  app_content <- glue::glue('
#==============================================================================
# Cerebro Shiny App Builder - RStudio 自动生成的应用程序
#==============================================================================

library(dplyr)
library(DT)
library(plotly)
library(shiny)
library(shinydashboard)
library(shinyWidgets)

{colors_code}
# 定义结果保存目录
cerebro_root <- "."
{crb_files_code}

## 设置参数
Cerebro.options <<- list(
  "mode" = "open",
  "crb_file_to_load" = {crb_load_code},
  "cerebro_root" = cerebro_root{colors_option}{extra_options}
)

shiny_options <- list(
  maxRequestSize = {max_request_size} * 1024^2,
  port = {port},
  host = "{host}",
  launch.browser = {toupper(as.character(launch_browser))},
  quiet = {toupper(as.character(quiet))},
  display.mode = "{display_mode}"
)

{auth_code}
## 加载服务器和界面函数
source(file.path(cerebro_root, "shiny/{version}/shiny_UI.R"))
source(file.path(cerebro_root, "shiny/{version}/shiny_server.R"))

## Start Shiny App
{auth_wrapper_code}
shiny::shinyApp(
  ui = {app_ui_code},
  server = {app_server_code},
  options = shiny_options
)
',
    .trim = FALSE
  )

  # 应用智能缩进处理
  processed_content <- dedent(app_content)
  writeLines(processed_content, app_file)

  # Summary -------------------------------------------------------------------##
  if (verbose) {
    cat("\n")
    cat("========================================\n")
    cat("Shiny app successfully created!\n")
    cat("========================================\n")
    cat("App directory:", result_dir, "\n")
    cat("Data file(s):\n")
    for (i in seq_along(cerebro_data)) {
      if (!is.null(names(cerebro_data)[i]) && names(cerebro_data)[i] != "") {
        cat("  -", names(cerebro_data)[i], ":", basename(cerebro_data[i]), "\n")
      } else {
        cat("  -", basename(cerebro_data[i]), "\n")
      }
    }
    cat("Version:", version, "\n")
    cat("Port:", port, "\n")
    cat("Host:", host, "\n")
    cat("Launch browser:", launch_browser, "\n")
    if (auth_enabled) {
      cat("Authentication: ENABLED\n")
      cat("  Admin user:", admin_user, "\n")
      if (!is.null(users)) {
        cat("  Additional users:", paste(users, collapse = ", "), "\n")
      }
    } else {
      cat("Authentication: DISABLED\n")
    }
    cat("\nTo launch the app, run:\n")
    cat("  setwd('", result_dir, "')\n", sep = "")
    cat("  shiny::runApp('app.R')\n")
    cat("========================================\n")
  }

  invisible(result_dir)
}


#' streamable table
#'
#' @param read read function. Arguments should be "`file`" 
#' (must be able to take a [connection()] object) and "`...`" (for)
#' additional arguments.
#' @param write write function. Arguments should be "`data`" (a data.frame),
#' `file` (must be able to take a [connection()] object), and "`omit_header`"
#'  logical, include header (initial write) or not (for appending subsequent
#'  chunks)
#' @param extension file extension to use (e.g. "tsv", "csv")
#' @details 
#' Note several constraints on this design. The write method must be able
#' to take a generic R `connection` object (which will allow it to handle
#' the compression methods used, if any), and the read method must be able
#' to take a `textConnection` object.  `readr` functions handle these cases
#' out of the box, so the above method is easy to write.  Also note that
#' the write method must be able to `omit_header`. See the built-in methods
#' for more examples.
#' @return a `streamable_table` object (S3)
#' @export
#'
#' @examples
#' 
#' streamable_readr_tsv <- function() {
#'   streamable_table(
#'     function(file, ...) readr::read_tsv(file, ...),
#'     function(x, path, omit_header)
#'       readr::write_tsv(x = x, path = path, omit_header = omit_header),
#'     "tsv")
#' }
#' 
streamable_table <- function(read, write, extension) {
  stopifnot(is.function(read),
            is.function(write),
            is.character(extension), 
            length(extension) == 1L, 
            !is.na(extension))
  ## FIXME Assert argument number / names for read/write functions?
  
  ret <- list(read = read,
              write = write,
              extension = extension)
  class(ret) <- "streamable_table"
  ret
}


assert_streamable <- function(x, name = deparse(substitute(x))) {
  if (!inherits(x, "streamable_table") ) {
    stop(sprintf("'%s' must be a streamable_table object", name), call. = FALSE)
  }
}

#' streamable tsv using `readr`
#' 
#' @return a `streamable_table` object (S3)
#' @export
#' @seealso [readr::read_tsv()], [readr::write_tsv()]
#' 
streamable_readr_tsv <- function() {
  
  ## Avoids a hard dependency on readr for this courtesy function
  if (!requireNamespace("readr", quietly = TRUE)) {
    stop("readr package must be installed to use readr-based methods",
         call. = FALSE)
  }
  read_tsv <- getExportedValue("readr", "read_tsv")
  write_tsv <- getExportedValue("readr", "write_tsv")
  
   
   ## actual definitions
    read <- function(file, ...) {
      read_tsv(file, ...)
    }
    write <- function(x, path, omit_header = FALSE) {
      write_tsv(x = x, path = path, append = omit_header)
    }
    
  streamable_table(read, write, "tsv")
}

#' streamable csv using `readr`
#' 
#' @return a `streamable_table` object (S3)
#' @export
#' @seealso [readr::read_csv()], [readr::write_csv()]
streamable_readr_csv <- function() {
  
  ## Avoids a hard dependency on readr for this courtesy function
  if (!requireNamespace("readr", quietly = TRUE)) {
    stop("readr package must be installed to use readr-based methods",
         call. = FALSE)
  }
  read_csv <- getExportedValue("readr", "read_csv")
  write_csv <- getExportedValue("readr", "write_csv")
  
  
  read <- function(file, ...) {
    read_csv(file, ...)
  }
  write <- function(x, path, omit_header = FALSE) {
    write_csv(x = x, path = path, append = omit_header)
  }
  
  streamable_table(read, write, "csv")
}

#' streamable tsv using base R functions
#' 
#' @return a `streamable_table` object (S3)
#' @export
#' 
#' @details
#' Follows the tab-separate-values standard using [utils::read.table()],
#' see IANA specification at:
#' <https://www.iana.org/assignments/media-types/text/tab-separated-values>
#'
#' @seealso [utils::read.table()], [utils::write.table()]
#' 
#' @importFrom utils read.table write.table 
streamable_base_tsv <- function() {
  read_tsv <- function(file, ...) {
    utils::read.table(textConnection(file), 
                      header = TRUE, 
                      sep = "\t", 
                      quote = "",
                      stringsAsFactors = FALSE,
                      ...)
  }
  write_tsv <- function(x, path, omit_header) {
    utils::write.table(x,
                       file = path, 
                       append = omit_header, 
                       sep = "\t",
                       quote = FALSE,
                       row.names = FALSE,
                       col.names = !omit_header)
  }
  streamable_table(read_tsv, write_tsv, "tsv")
}



#' streamable csv using base R functions
#' 
#' @return a `streamable_table` object (S3)
#' @export
#' 
#' @details
#' Follows the comma-separate-values standard using [utils::read.table()]
#'
#' @seealso [utils::read.table()], [utils::write.table()]
#' 
#' @importFrom utils read.table write.table 
#' 
streamable_base_csv <- function() {
  read_csv <- function(file, ...) {
    ## Consider case of header = FALSE...
    utils::read.table(textConnection(file), 
                      header = TRUE, 
                      sep = ",", 
                      quote = "\"",
                      stringsAsFactors = FALSE,
                      ...)
  }
  ## NOTE: write.csv does not permit setting 
  ## `col.names = FALSE``, so cannot omit_header
  write_csv <- function(x, path, omit_header) {
      utils::write.table(x,
                       file = path, 
                       sep = ",", 
                       quote = TRUE,
                       qmethod = "double",
                       row.names = FALSE,
                       col.names = !omit_header,
                       append = omit_header
      )
  }
  streamable_table(read_csv, write_csv, "csv")
}


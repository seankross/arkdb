testthat::context("test-errors")

testthat::test_that("we can detect errors on types", {
  
  x <- NULL
  testthat::expect_warning(assert_files_exist("not-a-file"), "not found")
  testthat::expect_warning(assert_files_exist(c("not-a-file", "not")), "not found")
  testthat::expect_warning(assert_files_exist(x), "no file specified")
  
  testthat::expect_error(assert_dir_exists("not-a-dir"), "not found")
  testthat::expect_error(assert_dbi(x), "DBI")
  testthat::expect_error(assert_connection(x), "connection")
  testthat::expect_error(assert_streamable(x), "streamable")
  
})
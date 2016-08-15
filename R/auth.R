#' Authenticate this session
#'
#' A wrapper for \link[googleAuthR]{gar_auth} and \link[googleAuthR]{gar_auth_service}
#'
#' @param new_user If TRUE, reauthenticate via Google login screen
#'
#' If you have set the environment variable \code{GCS_AUTH_FILE} to a valid file location,
#'   the function will look there for authentication details.
#' Otherwise it will look in the working directory for the `.httr-oauth` file, which if not present
#'   will trigger an authentication flow via Google login screen in your browser.
#'
#' If \code{GCS_AUTH_FILE} is specified, then this function will be called upon loading the package
#'   via \code{library(googleCloudStorageR)},
#'   meaning that calling this function yourself at the start of the session won't be necessary.
#'
#' \code{GCS_AUTH_FILE} can be either a token generated by \link[googleAuthR]{gar_auth} or
#'   service account JSON ending with file extension \code{.json}
#'
#' @return Invisibly, the token that has been saved to the session
#' @import googleAuthR
#' @importFrom tools file_ext
#' @export
gcs_auth <- function(new_user = FALSE){

  if(!any(getOption("googleAuthR.scopes.selected") %in%
          c("https://www.googleapis.com/auth/devstorage.full_control",
            "https://www.googleapis.com/auth/devstorage.read_write"))){
    stop("Cannot authenticate - googleAuthR.scopes.selected needs to be set to include
         https://www.googleapis.com/auth/devstorage.full_control or
         https://www.googleapis.com/auth/devstorage.read_write")
  }

  auth_file <- Sys.getenv("GCS_AUTH_FILE")

  if(auth_file == ""){
    ## normal auth looking for .httr-oauth in working folder or new user
    out <- googleAuthR::gar_auth(new_user = new_user)
  } else {
    ## auth_file specified in GCS_AUTH_FILE
    if(file.exists(auth_file)){
      ## Service JSON file
      if(tools::file_ext(auth_file) == "json"){
        out <- googleAuthR::gar_auth_service(auth_file)
      } else {
      ## .httr-oauth file
        token <- readRDS(auth_file)
        out <- googleAuthR::gar_auth(token = token[[1]])
      }
    } else {
    ## auth_file specified but not present
      stop("GCS_AUTH_FILE specified in environment variables but file not found.")
    }
  }

  invisible(out)
}
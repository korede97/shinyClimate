# Module UI function
downloadUI <- function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  
  tagList(
    # Button
    div(style="width:100%;text-align: center;",
      downloadButton(ns("report"), "Generate Report",width = '100%', 
                   style ='display:inline-block;background:black;border-color:orange;color:white')
  )
  )
}


# Module server function
download <- function(input, output, session, plots, rv) {
  report <- reactiveValues(num = 0) 
  
  observeEvent(plots,{
        report$num <- report$num + 1
    })
  

  output$report <- downloadHandler(
    filename = "report.pdf",
    
    content <- function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("./report.Rmd", tempReport, overwrite = TRUE)

      temp <- tempdir()
      # Set up parameters to pass to Rmd document
      params <- list(dfnew = isolate(rv$dfnew), 
                     count  = isolate(rv$count)
                     )
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      
      out = rmarkdown::render(tempReport, pdf_document(),
                              params = params, output_file = 'report.pdf',
                              envir = new.env(parent = globalenv())
      )
      file.rename(out, file) # move pdf to file for downloading
      
    }
  )
}




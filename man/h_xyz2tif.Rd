% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tool_karim.R
\name{h_xyz2tif}
\alias{h_xyz2tif}
\title{Read and Convert xyz DEM/DSM Data as typically provided by the Authorities}
\usage{
h_xyz2tif(xyzFN = NUL, epsgCode = "25832")
}
\arguments{
\item{txtFn}{ASCII tect file with xyz values}
}
\value{
a geoT
}
\description{
Read xyz data and generate a raster  \code{Raster*} object.
}
\examples{

# get some typical data as provided by the authority
url<-"http://www.ldbv.bayern.de/file/zip/10430/DGM_1_ascii.zip"
res <- curl::curl_download(url, "testdata.zip")
unzip(res,files = grep(".tif", unzip(res,list = TRUE)$Name,value = TRUE),junkpaths = TRUE,overwrite = TRUE)

h_xyz2tif(file.path(getwd(),basename(grep(".g01dgm", unzip(res,list = TRUE)$Name,value = TRUE))))

plot(raster(paste0(getwd(),"/",tools::file_path_sans_ext(basename(file.path(getwd(),basename(grep(".g01dgm", unzip(res,list = TRUE)$Name,value = TRUE))))),".tif")))

}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fa_treeSegementation.R
\name{fa_tree_segementation}
\alias{fa_tree_segementation}
\title{Tree segementation based on a CHM}
\usage{
fa_tree_segementation(x = NULL, minTreeAlt = 5, is0_output = 1,
  is0_join = 1, is0_thresh = 0.09, is3_leafsize = 8, is3_normalize = 1,
  is3_neighbour = 1, is3_method = 0, is3_sig1 = 0.1, is3_sig2 = 3.01,
  is3_threshold = 0.001, is3_param2 = "GLI", is3_param1 = "HI",
  majority_radius = 5, seeding = TRUE)
}
\arguments{
\item{x}{spatial raster object}

\item{is0_output}{default is 0,     # 0=s seed value 1=segment id}

\item{is0_join}{default is 2,     # 0=no join, 1=seed2saddle diff, 2=seed2seed diff}

\item{is0_thresh}{default is 0.05,  # threshold for join difference in m}

\item{is3_leafsize}{default is 8,}

\item{is3_normalize}{default is 1,}

\item{is3_neighbour}{default is 1,}

\item{is3_method}{default is 0,}

\item{is3_sig1}{default is  0.1,}

\item{is3_sig2}{default is 3.01,}

\item{is3_threshold}{default is 0.001,}

\item{is3_param2}{default is HI  GLI next rgb image derived index}

\item{is3_param1}{default is HI first rgb image derived index}

\item{majority_radius}{default is 5.000}

\item{seeding}{default  is TRUE switch if seeding is called}

\item{minTreealt}{default is 5}
}
\value{
basically returns a  vector data sets with the tree crown geometries and a bunch of corresponding indices
}
\description{
Tree segementation based on a CHM
}
\examples{
\dontrun{
# Tree segementation based on a CHM
 fa_tree_segementation(x = rasterobj,  "nameofSAGAFile")
}

}
\author{
Chris Reudenbach
}

# use case canopy height model (chm)
# from an uav derived point cloud data set

# load package for linking  GI tools
require(link2GI)
require(uavRst)

# define project folder
filepath_base <- "~/temp6/GRASS7"

# define uav point cloud data folder 
las_data_dir <- "/home/creu/apps/LAStools/bin/input"

# create project structure and export global pathes
link2GI::initProj(projRootDir = "~/temp6/GRASS7",
                  projFolders = c("data/","output/","run/","las/") )

# set working directory
setwd(path_run)

# clean run dir
# unlink(paste0(path_run,"*"), force = TRUE)

# link SAGA
saga <- link2GI::linkSAGA()


  # create DSM
  dsm <- uavRst::fa_pc2DSM(lasDir = las_data_dir,
                        gisdbase_path = filepath_base,
                        grid_size = "0.05")
  # create DTM
  dtm <- uavRst::fa_pc2DTM(lasDir = las_data_dir,
                        gisdbase_path = filepath_base,
                        thin_with_grid = "0.5",
                        level_max = "5" ,
                        grid_size = "0.05")
  dsmR <- dsm[[1]]
  dtmR <- dtm[[1]]
  
  # adjust dsm to dtm
  dsmR <- raster::resample(dsm[[1]], dtmR <- dtm[[1]], method = 'bilinear')
  
  # calculate CHM
  chmR <- dsmR - dtm[[1]]

  raster::plot(chmR)
  
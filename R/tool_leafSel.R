#' interactive selection of vector features 
#' @description  Simple interactive way to select/deselect features from a vector data set. The selection is exported to geojson format. For control and copy & paste issues the data is pushed to a text box.

#' @param overlay sp object  for selection
#' @param mapcenter c(lat,lon) central point of the leaflet map
#' @param zoom initial zoom level
#' @param line enable/disable the draw tool line tool
#' @param poly enable/disable the draw polygon tool 
#' @param circle enable/disable the draw circle tool
#' @param point enable/disable the draw point tool
#' @param remove enable/disable the remove feature of the draw tool
#' @param position place to put the toolbar (topright, topleft, bottomright, bottomleft)
#' @param intersection enable/disable th possibility to overlay lines or polygons
#' @param maplayer  leaflet-provider maplayers
#' @param cex size of features
#' @param alpha  0.6,
#' @param opacity  0.7,
#' @param color "blue"
#'
#' @examples
#' 
#' # get meuse data
#' data(meuse)
#' coordinates(meuse) <- ~x+y
#' proj4string(meuse) <- CRS("+init=epsg:28992")
#' 
#' 
#' # select some points
#'  sp_sel(overlay = meuse, zoom = 13,position = "bottomright", cex = 2, color = "green")
#'  
#'  # re-import selection saved as "test.json"
#'  import <-rgdal::readOGR(dsn = path.expand("~/test.json"), layer = "OGRGeoJSON")
#'  
#'  # select some polygons
#'  uavRst::sp_sel(overlay = gadmCHE,zoom = 7)
#'  
#'  #'  # re-import selection saved as "ch_sel.json"
#'  import <-rgdal::readOGR(dsn = path.expand("~/ch_sel.json"), layer = "OGRGeoJSON")

#' 
#' @export sp_sel
#'               

sp_sel <- function(mapCenter=c(50.80801,8.72993),
                   zoom=15, 
                   line = TRUE, 
                   rectangle = FALSE, 
                   poly = FALSE, 
                   circle = FALSE, 
                   point = FALSE,
                   remove = TRUE, 
                   hidemenu =TRUE,
                   position= "topright", 
                   maplayer=c("CartoDB.Positron","OpenStreetMap","Esri.WorldImagery","Thunderforest.Landscape","OpenTopoMap"),
                   overlay=NULL,
                   features=NULL,
                   cex = 4,
                   lwd = 1,
                   alpha = 0.6,
                   opacity = 0.7,
                   color="blue") {
  line = line
  rectangle = rectangle
  poly = poly
  circle = circle
  point = point
  remove = remove 
  mapCenter = mapCenter
  zoom = zoom
  line<-line
  maplayer=maplayer
  overlay=overlay
  position<-position
  
  # create tmp path
  tmpPath<- createTempDataTransfer()
  
  if (!is.null(overlay)){
    
    if (class(overlay)  %in% c("SpatialPointsDataFrame","SpatialLinesDataFrame","SpatialLines","SpatialPoints")) {
      #e <- as(raster::extent(overlay), "SpatialPolygons")
      #e <- sp::SpatialPolygonsDataFrame(e, data.frame(ID="overlay"))
      proj4string(overlay) <- sp::proj4string(overlay)
      overlay<-sp::spTransform(overlay,CRSobj = sp::CRS("+init=epsg:4326"))
    } else if  (class(overlay)=="SpatialPolygonsDataFrame") {
      overlay<-sp::spTransform(overlay,CRSobj = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))
      #overlay <- sp::SpatialPolygonsDataFrame(overlay, data.frame(ID="overlay"))
    }
    
    rgdal::writeOGR(overlay, paste(tmpPath, "jsondata", sep=.Platform$file.sep), "OGRGeoJSON", driver="GeoJSON", overwrite_layer = TRUE)
    
    # for fastet json read in a html document we wrap it with var data = {};
    # and we fix the crs item of ogr2json
    # TODO loop a list of data
    
    # main data object
    lns <- data.table::fread(paste(tmpPath, "jsondata", sep=.Platform$file.sep), header = FALSE, sep = "\n", data.table = FALSE)
    
    # do it for main
    lns[1,] <-paste0('var jsondata = {')
    lns[3,]<-paste0('"crs": { "type": "name", "properties": { "name": "EPSG:4326" } },')
    lns[length(lns[,1]),]<- '};'
    write.table(lns, paste(tmpPath, "jsondata", sep=.Platform$file.sep), sep="\n", row.names=FALSE, col.names=FALSE, quote = FALSE)
    features<-names(overlay)
    # correct if only Lines or Polygons (obsolete here?)
    if (class(overlay)[1] == 'SpatialPolygonsDataFrame' | class(overlay)[1] == 'SpatialPolygons'){
      noFeature <- length(overlay@polygons)
    } else if (class(overlay)[1] == 'SpatialLinesDataFrame' | class(overlay)[1] == 'SpatialLines'){
      noFeature <- length(overlay@lines)
    } 
    jsondata<-1
    
    
    
    mapCenter<-c((raster::extent(overlay)[3]+raster::extent(overlay)[4])/2,(raster::extent(overlay)[1]+raster::extent(overlay)[2])/2)
    #features<-overlay
    
  }  else stop("surprise but there is nothing to select from\n")
  
  
  
  ### create the rest of the JS strings
  CRSvarMapCenter<-paste0('var mapCenter = [',mapCenter[1],',',mapCenter[2],'];')
  CRSinitialZoom<-paste('var initialZoom = ',zoom,';')
  
  ### write it to CRS.js
  # assign tmpfilename for CRS definition
  tmpCRS <- paste0(tmpPath,"/crs.js")
  # write the proj4leaflet CRS
  write(CRSinitialZoom,tmpCRS,append = TRUE)
  write(CRSvarMapCenter,tmpCRS,append = TRUE)
 
  
  
  # create parameter list for the widget
  x <- list(data  = 'undefined',
            layer=maplayer,
            zoom = zoom,
            #refpoint=refpoint,
            line=line,
            rectangle=rectangle,
            poly=poly,
            circle=circle,
            point=point,
            remove=TRUE,
            position=position,
            scaleBar=TRUE,
            color=color,
            na.color=mapviewGetOption("na.color"),
            cex = cex,
            alpha = alpha,
            legend = FALSE,
            opacity = opacity,
            overlay=jsondata,
            hidemenu=hidemenu
            
  )
  sp_selInternal(tmpPath, x = x)  
}


# create dependencies
digiDependencies <- function(tmpPath) {
  
  data_dir <- paste0(tmpPath,sep=.Platform$file.sep)
  
  
  list(
    htmltools::htmlDependency(name = "crs",
                              version = "1",
                              src = c(file = tmpPath),
                              script = list("crs.js")),
    
    htmltools::htmlDependency(name = "jsondata",
                              version = "1",
                              src = c(file = tmpPath),
                              script = list("jsondata")),
    
    htmltools::htmlDependency(
      name = "leaflet-draw",
      version= "0.7.3",
      src = c(file = tmpPath),
      script = list("leaflet.draw.js"),
      stylesheet=list("leaflet.draw.css")
    )
    
  )
}

###  creates temporary file structure for data transfer =================================================
createTempDataTransfer <- function (){
  tmpPath <- tempfile(pattern="007")
  dir.create(tmpPath)
  return(tmpPath)
}

sp_selInternal <- function(tmpPath, x = NULL) {
  deps<-digiDependencies(tmpPath) 
  sizing = htmlwidgets::sizingPolicy(
    browser.fill = TRUE,
    viewer.fill = TRUE,
    viewer.padding = 5
  )
  # create widget
  htmlwidgets::createWidget(
    name = 'sp_sel',
    x,
    dependencies = deps,
    sizingPolicy = sizing,
    package = 'uavRst'
  )
}

### Widget output function for use in Shiny =================================================
#
sp_selOutput <- function(outputId, width = '100%', height = '800px') {
  htmlwidgets::shinyWidgetOutput(outputId, 'sp_sel', width, height, package = 'uavRst')
}

### Widget render function for use in Shiny =================================================
#
rendersp_sel<- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, projViewOutput, env, quoted = TRUE)
}
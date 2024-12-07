#' misc functions for ACLIM2
#' 
#' 
length.na <- function(x){length(which(is.na(x)==FALSE))}

date_fun <-function(x,type="yr",seasonsIN = seasons){
  if(type=="yr")
    return(x$year+1900)
  if(type=="mo")
    return(x$mon+1)
  if(type=="jday")
    return(x$yday+1)
  if(type=="wk")
    return(as.numeric(format(x, "%W"))+1)
  if(type=="season")
    return(seasonsIN[x$mon+1,2])
}

getgam <- function ( x =sub$wk, y = sub$mnVal_x, kin = .8,pos=FALSE){
  df <- na.omit(data.frame(x,y))
  nobs <- length(unique(df$x))
  if(dim(df)[1]>2){
    if(pos){
      Gam   <- mgcv::gam( log(y+1e-4) ~ 1 + s(x, k=round(nobs*kin),bs= "cc"),data=df)
      out   <- exp(as.numeric(predict(Gam, newdata=data.frame(x=x), se.fit=FALSE ))-1e-4)
    }else{
      Gam   <- mgcv::gam( y ~ 1 + s(x, k=round(nobs*kin),bs= "cc"),data=df)
      out <- as.numeric(predict(Gam, newdata=data.frame(x=x), se.fit=FALSE ))
    }
  }else{
    out<- y
  }

  return(out)
}

LNmean <-function(x,log_adj=1e-4,na.rm=F){
  df <- data.frame(y =x, x = 0)
  if(na.rm) df <-na.omit(df)
  model <-  glm(y+log_adj ~ x,data=df,family = gaussian(link = "log"))
  mn <- as.numeric(fitted(model)[1])-log_adj
  
  return(mn)
}
LNsd <-function(x,log_adj=1e-4,na.rm=F){
  df <- data.frame(y =x, x = 0)
  model <-  glm(y+log_adj ~ x,data=df,family = gaussian(link = "log"))
  mn <- as.numeric(fitted(model)[1])-log_adj
  if(na.rm) df <-na.omit(df)
  sd <- exp(sqrt(diag(vcov(model)))[1])-log_adj
  return(sd)
}


#' get_mlt
get_mlt <- function(unit_txt){
if(length(grep("seconds", unit_txt)>0))  out <- data.frame(mlt = 1,ntxt = nchar("seconds since "))
if(length(grep("minutes", unit_txt)>0))  out <- data.frame(mlt = 60,ntxt = nchar("minutes since "))
if(length(grep("hours", unit_txt)>0))    out <- data.frame(mlt = 60*60,ntxt = nchar("hours since "))
if(length(grep("days", unit_txt)>0))     out <- data.frame(mlt = 24*60*60,ntxt = nchar("days since "))
return(out)
}

logit<-function(p){
  log(p/(1-p))
}
inv.logit<-function(x){
  exp(x)/(1+exp(x))
}

get_mn_forecast<-function(valIN   = "TempC",
                          strataOut   = F,
                          strataIN    = region_area_name, 
                          basinIN     = c("NEBS","SEBS"),
                          dataIN = subdat ) {
  
  if(!strataOut){
    eval(parse(text = paste0("tmp <- dataIN%>%
        filter(basin%in%basinIN,!is.na(",valIN,"))%>%
        group_by(var,time,jday,mo,yr,species,basin)%>%
        mutate(valArea = ",valIN,"*grid_cell_area)%>%
        summarize(
          tot_val = sum(valArea), 
          sumArea = sum(grid_cell_area))%>%
        mutate(mn_val=tot_val/sumArea) ") ))
    
  }else{
    
    eval(parse(text = paste0("tmp <- dataIN%>%
        filter(strata%in%strataIN,!is.na(",valIN,"))%>%
        group_by(var,time,jday,mo,yr,species,strata,strata_area_km2)%>%
        mutate(valArea = ",valIN,"*grid_cell_area)%>%
        summarize(
          tot_val = sum(valArea), 
          sumArea = sum(grid_cell_area))%>%
        mutate(mn_val=tot_val/sumArea) ") ))

  }

  tmp$plotvar <- valIN
  
  return(tmp)
  
}

get_mn_forecast_old<-function(valIN = "TempC",
                            strataOut = F,
                            strataIN = NEBS_strata, 
                            dataIN = subdat ) {
  eval(parse(text = paste0("tmp <- dataIN%>%
        filter(strata%in%strataIN)%>%
        group_by(var,time,jday,mo,yr,species,strata,strata_area_km2)%>%
        summarize(mn_val = mean(",valIN,",na.rm=T)) ") ))
  tmp$strata <- factor(tmp$strata, levels = region_area_name)
  
  eval(parse(text = paste0("tmp2 <- dataIN%>%
        group_by(var,time,jday,mo,yr,species,basin)%>%
        summarize(mn_val = mean(",valIN,",na.rm=T)) ") ))
  
  tmp$plotvar <- tmp2$plotvar <- valIN
  if(strataOut){
    return(tmp)
  }else{
    return(tmp2)
  }
}


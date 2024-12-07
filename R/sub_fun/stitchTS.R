#'
#'
#'
#'stitchTS
#'


stitchTS <- function(dat,maxD){
  scens  <- unique(dat$scen)
  # GCMs   <- unique(dat$GCM)
  # GCMs   <- GCMs[!GCMs%in%c("hind","hist")]
  # 
  for(s in 1:length(scens)){
      #cat hind to each projection and clip the projection start years
     hnd  <- dat%>%dplyr::filter(sim_type=="hind"&scen==scens[s]&mnDate<=maxD)
     proj <- dat%>%dplyr::filter(sim_type=="proj"&scen==scens[s]&mnDate>maxD)
     GCMs <- unique(proj$GCM)
     for(g in 1:length(GCMs)){
       GCM_scensIN <- paste0(GCMs[g],"_",scens[s])
        fut <- proj%>%dplyr::filter(GCM==GCMs[g])
        tmpd <- rbind(hnd,fut)%>%
          dplyr::mutate(GCM_scen=GCM_scensIN)%>%
          dplyr::arrange(GCM_scen,year)
      
      # tmpd <- rbind(dat%>%
      #                 dplyr::filter(sim_type=="hind"&scen==scens[s]&mnDate<=maxD)%>%
      #                 dplyr::mutate(GCM_scen=GCM_scensIN),
      #               dat%>%
      #                 dplyr::filter(sim_type=="proj"&scen==scens[s]&GCM==GCMs[g]&mnDate>maxD))
      # tmpd <- tmpd%>%dplyr::arrange(GCM_scen,year)
      
      if(s==1&g==1){
        newdat <- tmpd
      }else{
        newdat <- rbind(newdat,tmpd)
      }
      rm(tmpd)
     }
    rm(GCM_scensIN)
    rm(GCMs)
  }
  return(newdat)
}

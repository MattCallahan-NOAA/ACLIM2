#'
#'
#'
#' makeDat_hind.R
#' 
makeDat_hind <- function(datIN   = hind, 
                         makeADMB_chunk = T,
                         NAVal     = "mean", 
                         value2use = "val_use",
                         value2use_scaled = "val_use_scaled",
                         outfile = fndat_hind,
                         nonScaled_covlist = c("temp_bottom5m","temp_surface5m"),
                         Scaled_covlist    = covars,
                         nsppIN    = NULL,
                         overlapIN = NULL){
  
  
   if(is.null(NAVal)){
    myfun <- function(x){
      return(x)
    }}
  
   if(NAVal == "mean"){
    myfun <- function(x){
      if(any(is.na(x))) 
        x[is.na(x)] <- mean(x, na.rm=T) 
      return(x)
    }}
   if(NAVal == "last"){
    myfun <- function(x){
      if(any(is.na(x))) 
        x[is.na(x)] <- rev(x[!is.na(x)])[1]
      return(x)
    }}
   if(NAVal == "5Yrmean"){
      myfun <- function(x){
        if(any(is.na(x))) 
          x[is.na(x)] <- mean(rev(x[!is.na(x)])[1:5])
      return(x)
    }}
    
  eval(parse(text =paste0("datIN <- datIN%>%dplyr::rename(VAL = ",value2use,")") ))
  eval(parse(text = paste0("datIN<- datIN%>%dplyr::rename(covuse = ",value2use_scaled,")")))
  ncovs      <- length(Scaled_covlist)
  ncovs_nonS <- length(nonScaled_covlist)
  
  # longnm     <- gsub("\n             "," ",datIN$long_nam[match(Scaled_covlist,datIN$var)])
  # longnm_nonS<- gsub("\n             "," ",datIN$long_nam[match(nonScaled_covlist,datIN$var)])
  yrs        <- sort(unique(datIN$year))

  cat("#Covars (covariate phase for each covs - do not alter this line)",file=outfile,append=FALSE,sep="\n")
  cat(paste("#",Scaled_covlist),file=outfile,append=TRUE,sep=" ")
  cat("",file=outfile,append=TRUE,sep="\n")
  cat("#nspp2 : ",file=outfile,append=TRUE,sep="\n")
  cat(nsppIN,file=outfile,append=TRUE,sep="\n")
  cat("#nTyrs : number years for the zooplankton hindcast data ",file=outfile,append=TRUE,sep="\n")
  cat(length(yrs),file=outfile,append=TRUE,sep="\n")
  cat("#hind_years : years for covariates ",file=outfile,append=TRUE,sep="\n")
  cat(yrs,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
  cat("#ncov : number of covariates ",file=outfile,append=TRUE,sep="\n")
  cat(ncovs,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
  
  cat("#nEatcovs : DEFUNCT ",file=outfile,append=TRUE,sep="\n")
  cat(1,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
  cat("#Eat_covs : DEFUNCT ",file=outfile,append=TRUE,sep="\n")
  cat(3,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")

  # cat("#ncovs_nonS : number of non-scaled covariates",file=outfile,append=TRUE,sep="\n")
  # cat(ncovs_nonS,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
  
  cat("#COVAR_START ##############################################DO NOT REMOVE THIS LINE OR REC FIT WONT RUN!",file=outfile,append=TRUE,sep="\n")
  for(c in 1:ncovs){
    #eval(parse(text=paste("tmp<-dd$",parmlist[p],sep="")))
    cat(paste("#",Scaled_covlist[c],":",(datIN%>%
                                            dplyr::filter(var==Scaled_covlist[c])%>%
                                            select(long_name))[[1]][1]),file=outfile,append=TRUE,sep="\n")
    dd <- (datIN%>%
             dplyr::filter(var==Scaled_covlist[c])%>%
             dplyr::mutate(covuse = myfun(covuse))%>%
             dplyr::select(covuse))[[1]]
    
    cat(dd,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
    rm(dd)
  }
  cat("#COVAR_END ##########################################################DO NOT REMOVE THIS LINE OR REC FIT WONT RUN!",file=outfile,append=TRUE,sep="\n")
  for(c in 1:ncovs_nonS){
   
    #eval(parse(text=paste("tmp<-dd$",parmlist[p],sep="")))
    cat(paste("#",nonScaled_covlist[c],":",(datIN%>%
                                               dplyr::filter(var==nonScaled_covlist[c])%>%
                                               select(long_name))[[1]][1]),
        
        file=outfile,append=TRUE,sep="\n")
    dd <- (datIN%>%
             dplyr::filter(var==nonScaled_covlist[c])%>%
             dplyr::mutate(VAL = myfun(VAL))%>%
             dplyr::select(VAL))[[1]]
    cat(dd,
        file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
    rm(dd)
  }
 
  cat("########################################################### ",file=outfile,append=TRUE,sep="\n")
  cat("#overlap : pred overlap (2-6/0-6 area)   ",file=outfile,append=TRUE,sep="\n")
  if(!is.null(overlapIN)){
    for(predd in 1:nsppIN){
      for(preyy in 1:nsppIN){
        if(preyy==1){
          cat(paste("# predator",predd,"; prey ",preyy),file=outfile,append=TRUE,sep="\n")
          cat(overlapIN[predd,],file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
        }else{
          cat(paste("# predator",predd,"; prey ",preyy),file=outfile,append=TRUE,sep="\n")
          cat(1+0*overlapIN[predd,],file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
        }
      }
    }
  }
  
  
  cat("#testfile  ",file=outfile,append=TRUE,sep="\n")
  cat(12345,file=outfile,append=TRUE,sep="\n")
  
  if(makeADMB_chunk){
    flnm <- paste0(substr(outfile,1,nchar(outfile)-4),"_ADMB_chunk.txt")
    if(!file.exists(flnm)) 	file.create(flnm)
    cat("GLOBALS_SECTION",file=flnm,append=FALSE,sep="\n")
    cat(" adstring retrofile_name;",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat(" LOCAL_CALCS",file=flnm,append=TRUE,sep="\n")
    cat(paste0("  retrofile_name      = adstring(","\"",outfile,"\"",");"),file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("  dump_rep = 1;",file=flnm,append=TRUE,sep="\n")
    #cat(paste0("futfile_name        = adstring('",outfile,"');"),append=TRUE,sep="\n")
    cat(" END_CALCS",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n") 
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n")
    cat(paste0("// Read in retrospective hindcast data file e.g., ",outfile,""),file=flnm,append=TRUE,sep="\n")
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n") 
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n")   
    cat("",file=flnm,append=TRUE,sep="\n")
      
    cat(" !!                 if(dump_rep) cout << ","\"read in \"<<retrofile_name<<endl;",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat(" !!                 ad_comm::change_datafile_name(retrofile_name);",file=flnm,append=TRUE,sep="\n")   
    cat(" init_int           nspp2",file=flnm,append=TRUE,sep="\n") 
    cat(" !! if(nspp2!=nspp){cout<<","\"number of species does not match\"<<endl;exit(1);}",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat(" init_int           nTyrs                        // number years for the hindcast data",file=flnm,append=TRUE,sep="\n")  
    cat(" !!                 if(dump_rep) cout <<","\"nTyrs= \"<<nTyrs<<endl;",file=flnm,append=TRUE,sep="")    
    cat("",file=flnm,append=TRUE,sep="\n") 
    cat(" int                nyrs_use",file=flnm,append=TRUE,sep="\n") 
    cat(" !!                 nyrs_use=min(nTyrs,nyrs);    // minimum number of years between the two - if hindcast is longer use nyrs, and vise versa",file=flnm,append=TRUE,sep="\n") 
    cat(" init_vector        Tyrs(1,nTyrs)                // years for the hindcast data , doesn't have to match model years",file=flnm,append=TRUE,sep="\n") 
    cat(" !!                 if(dump_rep) cout <<","\"Tyrs= \"<<Tyrs<<endl;",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat(" init_int           ncov                         // number of covariates",file=flnm,append=TRUE,sep="\n") 
    # cat(" //init_int           nEatcovs                   // number of covariates for the food limitation configuration of RS (demand-zoop*Eatcov)",file=flnm,append=TRUE,sep="\n") 
    # cat(" //init_ivector       Eat_covs(1,nEatcovs)       // index of covariates that should be used for the function",file=flnm,append=TRUE,sep="\n") 
    cat(" matrix             rs_cov(1,ncov,1,nTyrs);      // covariate values (may be scaled)",file=flnm,append=TRUE,sep="\n") 
    cat(" LOCAL_CALCS",file=flnm,append=TRUE,sep="\n") 
    cat("               for (int c=1;c<=ncov;c++)",file=flnm,append=TRUE,sep="\n")  
    cat("                  for(int yr=1;yr<=nTyrs;yr++)",file=flnm,append=TRUE,sep="\n") 
    cat("                    *(ad_comm::global_datafile) >> rs_cov(c,yr);  // covariate values",file=flnm,append=TRUE,sep="\n")
    # cat("               for (int c=1;c<=ncovs_nonS;c++)",file=flnm,append=TRUE,sep="\n")  
    # cat("                  for(int yr=1;yr<=nTyrs;yr++)",file=flnm,append=TRUE,sep="\n") 
    # cat("                    *(ad_comm::global_datafile) >> rs_cov(c,yr);  // covariate values",file=flnm,append=TRUE,sep="\n")
    cat(" END_CALCS",file=flnm,append=TRUE,sep="\n") 
    cat("",file=flnm,append=TRUE,sep="\n")  
    cat("  //!! cout<< rs_cov(ncov) <<endl;",file=flnm,append=TRUE,sep="\n")
    cat(" init_vector        BTempC_retro(1,nTyrs)                              // Bottom Temperature (actual values)",file=flnm,append=TRUE,sep="\n")
    cat(" init_vector        SSTempC_retro(1,nTyrs)                             // Sea surface Temperatuer (actual values)",file=flnm,append=TRUE,sep="")
    cat(" !!                 if(dump_rep) cout <<","\"SSTempC_retro= \"<<SSTempC_retro<<endl;",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat(" 3darray            overlap_dat(1,nspp,1,nspp,1,nTyrs)               // pred prey overlap (scenario,pred,prey, yr); pred overlap with prey species (2-6/0-6 area)",file=flnm,append=TRUE,sep="\n")  
    cat(" LOCAL_CALCS",file=flnm,append=TRUE,sep="\n") 
    cat("                 for (int pred=1;pred<=nspp;pred++)",file=flnm,append=TRUE,sep="\n") 
    cat("                    for(int prey=1;prey<=nspp;prey++)",file=flnm,append=TRUE,sep="\n")
    cat("                      for(int yr=1;yr<=nTyrs;yr++)",file=flnm,append=TRUE,sep="\n")
    cat("                        *(ad_comm::global_datafile) >> overlap_dat(pred,prey,yr);          // overlap values",file=flnm,append=TRUE,sep="\n")
    cat(" END_CALCS",file=flnm,append=TRUE,sep="\n")  
    cat(" init_int          test_numZ",file=flnm,append=TRUE,sep="\n")
    cat("   !!               if (test_numZ != 12345) {cout<<","\"Read file error hindcast data\"<<endl<<test_num_projection<<endl;exit(1);}",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")


  }
}

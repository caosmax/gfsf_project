###########################################ProofByPixel####################################################
setwd("//dapadfs/workspace_cluster_3/bid-cc-agricultural-sector/19-BID-reanalysis/Rice/future/final/")
gdr1<- c("//dapadfs/workspace_cluster_3/bid-cc-agricultural-sector/19-BID-reanalysis/Rice/future/final/Rice_irrigation_")
gdr2<- c("//dapadfs/workspace_cluster_3/bid-cc-agricultural-sector/19-BID-reanalysis/Rice/future/final/Rice_rainfed_")
grd3<- c("//dapadfs/workspace_cluster_3/bid-cc-agricultural-sector/08-Cells_toRun/matrices_cultivo/version2017/")
copyfuture<- c("//dapadfs/workspace_cluster_6/Socioeconomia/GF_and_SF/BID_2/Rice_IRR/Rice_Future/")
copyhistorical<- c("//dapadfs/workspace_cluster_6/Socioeconomia/GF_and_SF/BID_2/Rice_IRR/Rice_Historical/")
copyPix<-  c("//dapadfs/workspace_cluster_6/Socioeconomia/GF_and_SF/BID_2/Pixels/Rice/pix/")
grdpix<- c("//dapadfs/workspace_cluster_6/Socioeconomia/GF_and_SF/BID_2/Pixels/Rice/")


##Cargar informaci�n de latitud, longitud, area de spam, fpu, etc.-------------------
load(paste(grd3,"Rice_riego",'.RDat',sep=''))


########### PARTE A

##----------------------------------------------------------------IRRIGATED 
###Future-------------

###GCMs y variedades de trigo
gcm <- c("bcc_csm1_1", "bnu_esm","cccma_canesm2", "gfld_esm2g", "inm_cm4", "ipsl_cm5a_lr",
         "miroc_miroc5", "mpi_esm_mr", "ncc_noresm1_m")

variedades<- c("IR8", "IR64","IR72")
reg<- read.csv("//dapadfs/workspace_cluster_6/Socioeconomia/GF_and_SF/BID_2/ListFPUs.csv",header = T,stringsAsFactors = F )
pots<- reg[,1]


##loop para cargar datos 
for (v in 1:length(variedades)){
      for (g in 1:length(gcm)){
            
            try(load(paste(gdr1,variedades[v],"_",gcm[g],".RDat",sep = ""))) 
            
            #Crear matriz que contenga en sus filas los rendimientos de cada lugar (pixel) en cada a�o (columnas)
            rend<-matrix(nrow=length(Run), ncol=28)
            for (i in 1:length(Run))
            {rend[i,]<- Run[[i]][,"HWAH"][1:28]}  #solo incluir a�os 1 a 28
            
            #descartar pixeles con demasiadas fallas
            rend[rend==-99] = 0  #convertir -99 a 0
            
#             #find areas where consistently failing and discard these from aggregation
#             zeros.wfd.r = apply(rend,1,function(x) sum(x==0,na.rm=T))
#             ind.falla = which(zeros.wfd.r>=14)
#             
            #Convertir rend en un data.frame
            rend<-data.frame(rend)
            
            #Asignar nombres a el data frame de rendimientos
            colnames(rend)<-paste0("20",22:49)
            
            
            #Creo un dataframe
            eval(parse(text=paste('md<-data.frame(long=crop_riego[,"x"],lat=crop_riego[,"y"],
                                  Area=crop_riego[,"riego.area"],FPU=crop_riego[,"New_FPU"],
                                  v=variedades[v],sce=gcm[g],sys="IRRI", rend)',sep='')))
            
#             # Descartar pixeles con m�s de 13 a�os con fallas en la linea base
#             if(sum(ind.falla) == 0)
#             {
#                   md<-md
#             } else {
#                   md<-md[-ind.falla,]
#             }
            
            md$pix<- NA
            for (row in 1:nrow(md)){
                  md$pix<- paste("Pix_" ,"long", md$long,"_","lat", md$lat, sep = "")
            }
            
            md<- md[,c("long","lat","pix","Area","FPU","v","sys","sce", paste0("X20",22:49))]
            
            #Computador personal
            write.csv(md,paste(grdpix,"IRRI",'_',variedades[v],'_',gcm[g],".csv",sep=''),row.names=T)
            cat(paste("Running RICE IRRI ", variedades[v], " of gcm ", gcm[g], " Done!!\n", sep = "" ))
            
            
      } 
}



# ########### PARTE B
# #cargar files
# crops<- c("Rice")  #, "Rice", "Rice", "Rice" "Rice", "SoyRice"
# c_files <- list.files(path=grdpix, pattern = "IRRI",full.names = T)
# c_files <- lapply(c_files, read.csv, stringsAsFactors = F)
# c_files <- do.call(rbind,c_files)
# c_files$X<- NULL
# 
# for(p in 1:length(pots)){
#       by_pots <- list()
#       
#       #### filter
#       by_pots[[p]] <- c_files[which(c_files$FPU==pots[[p]]),]
#       
#       if(nrow(by_pots[[p]]) >= 1){
#             ##### reshape
#             require(plyr)
#             require(tidyr)
#             by_pots[[p]]<- by_pots[[p]] %>% 
#                   gather(year,val, 9:36) 
#             #### tratamiento para a�os
#             by_pots[[p]]$year<- sub(pattern = "X", replacement = "", x = by_pots[[p]]$year, ignore.case = T)
#             
#             #hacer graficas
#             png(filename = paste(copyPix,"Rice","_","IRR_",pots[p],"_","trend",".png",sep=""), 
#                 width = 20, height = 12, units = 'in', res = 100)
#             require(ggplot2)
#             n<-ggplot(data=by_pots[[p]], aes(x=year,y=val,colour=pix))+ 
#                   geom_line(aes(group=pix))+
#                   geom_point()+ facet_grid(v~sce)+
#                   ylab("Yield ") + ggtitle("Scatter plot")+
#                   xlab("Years") +
#                   theme(axis.text.x=element_text(size=7, angle=90))+
#                   guides(color=guide_legend("Varieties"))+theme(legend.position="none")
#             plot(n)
#             dev.off()
#       } else {
#             cat(paste(" RICE IRRI FPU: ", pots[[p]], " does not have varieties\n", sep = ""))
#       }
#       
# }
# 


##----------------------------------------------------------------RAINFED 

###GCMs y variedades de trigo
##Cargar informaci�n de latitud, longitud, area de spam, fpu, etc.-------------------
load(paste(grd3,"Rice_secano",'.RDat',sep=''))


##loop para cargar datos 
for (v in 1:length(variedades)){
      for (g in 1:length(gcm)){
            
            load(paste(gdr2,variedades[v],"_",gcm[g],".RDat",sep = ""))
            
            #Crear matriz que contenga en sus filas los rendimientos de cada lugar (pixel) en cada a�o (columnas)
            rend<-matrix(nrow=length(Run), ncol=28)
            for (i in 1:length(Run))
            {rend[i,]<- Run[[i]][,"HWAH"][1:28]}  #solo incluir a�os 1 a 28
            
            #descartar pixeles con demasiadas fallas
            rend[rend==-99] = 0  #convertir -99 a 0
            
#             #find areas where consistently failing and discard these from aggregation
#             zeros.wfd.r = apply(rend,1,function(x) sum(x==0,na.rm=T))
#             ind.falla = which(zeros.wfd.r>=14)
            
            #Convertir rend en un data.frame
            rend<-data.frame(rend)
            
            #Asignar nombres a el data frame de rendimientos
            colnames(rend)<-paste0("20",22:49)
            
            
            #Creo un dataframe
            eval(parse(text=paste('md<-data.frame(long=crop_secano[,"x"],lat=crop_secano[,"y"],
                                  Area=crop_secano[,"secano.area"],FPU=crop_secano[,"New_FPU"],
                                  v=variedades[v],sce=gcm[g],sys="RA", rend)',sep='')))
            
#             # Descartar pixeles con m�s de 13 a�os con fallas en la linea base
#             if(sum(ind.falla) == 0)
#             {
#                   md<-md
#             } else {
#                   md<-md[-ind.falla,]
#             }
            
            md$pix<- NA
            for (row in 1:nrow(md)){
                  md$pix<- paste("Pix_" ,"long", md$long,"_","lat", md$lat, sep = "")
            }
            
            md<- md[,c("long","lat","pix","Area","FPU","v","sys", "sce", paste0("X20",22:49))]
            
            #Save
            write.csv(md,paste(grdpix,"RA",'_',variedades[v],'_',gcm[g],".csv",sep=''),row.names=T)
            cat(paste("Running RICE RA ", variedades[v], " of gcm ", gcm[g], " Done!!\n", sep = "" ))
            
            
      } 
}



# ########## PARTE B
# #cargar files
# crops<- c("Rice")  
# c_files <- list.files(path=grdpix, pattern = "RA",full.names = T)
# c_files <- lapply(c_files, read.csv, stringsAsFactors = F)
# c_files <- do.call(rbind,c_files)
# c_files$X<- NULL
# 
# for(p in 1:length(pots)){
#       by_pots <- list()
#       
#       #### filter
#       by_pots[[p]] <- c_files[which(c_files$FPU==pots[[p]]),]
#       
#       if(nrow(by_pots[[p]]) >= 1){
#             ##### reshape
#             require(plyr)
#             require(tidyr)
#             by_pots[[p]]<- by_pots[[p]] %>% 
#                   gather(year,val, 8:35) 
#             #### tratamiento para a�os
#             by_pots[[p]]$year<- sub(pattern = "X", replacement = "", x = by_pots[[p]]$year, ignore.case = T)
#             
#             #hacer graficas
#             png(filename = paste(copyPix,"Rice","_","RA_",pots[p],"_","trend",".png",sep=""), 
#                 width = 20, height = 12, units = 'in', res = 100)
#             require(ggplot2)
#             n<-ggplot(data=by_pots[[p]], aes(x=year,y=val,colour=pix))+ 
#                   geom_line(aes(group=pix))+
#                   geom_point()+ facet_grid(v~sce)+
#                   ylab("Yield ") + ggtitle("Scatter plot")+
#                   xlab("Years") +
#                   theme(axis.text.x=element_text(size=7, angle=90))+
#                   guides(color=guide_legend("Varieties"))+ theme(legend.position="none")
#             plot(n)
#             dev.off()
#       } else {
#             cat(paste(" RICE RA FPU: ", pots[[p]], " does not have varieties\n", sep = ""))
#       }
#       
# }

g=gc;rm(list = ls())



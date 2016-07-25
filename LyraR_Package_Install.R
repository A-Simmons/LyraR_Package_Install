getDependencies <- function(packages.toinstall,dest="C:/R_Library_Source_Files/") {
  
  # Make list of dependencies
  pack.df <- data.frame(package=packages.toinstall,rank=0)
  for (package in packages.toinstall) {
    pack.df <- addPackagesToInstallList(package,pack.df,1)
  }
  
  # Order descending by rank
  pack.df<-pack.df[with(pack.df, order(-rank)),]
  # Download Files and append a filename column
  pack.df$fileName <- NA
  pack.df<-downloadSourceFile(pack.df,dest=dest)
  
  cat(sprintf("\nList of downloaded packages:\n"))
  print(pack.df)
  
  # Make Install Script String
  install.string <- "R CMD INSTALL --configure-args='--disable-pkg-config' --library=<your_personal_library_location> "
  for (file in pack.df$fileName) {
    install.string <- paste(install.string,file)
  }
  
  cat(sprintf("\nInstall string. CD to the location you store the source files and add the lcoation of your personal library.\n\n"))
  print(install.string)
}

addPackagesToInstallList <- function(package,pack.df,rank) {
  # Get list of missing dependencies
  Dependencies <- dependenciesMissing(package,pack.df)
  
  if (length(Dependencies) > 0) {
    Dependencies <- data.frame(package=Dependencies[!(Dependencies %in% pack.df$package)],rank=rank)
    # Append list of missing dependencies
    pack.df<-rbind(pack.df,Dependencies)
    # Search these dependencies for their own missing dependencies
    for (packageD in Dependencies$package) {
      pack.df<-addPackagesToInstallList(packageD,pack.df,rank+1)
    }
    
  }
  return(pack.df)
}

downloadSourceFile <- function(pack.df,dest,repository="https://cran.r-project.org/web/packages/",repository.dl="https://cran.r-project.org/src/contrib/") {
  for (count in (1:nrow(pack.df))) {
    package<-pack.df[count,"package"]
    IsException <- exceptionList(package,dest)
    if (IsException != FALSE) {
      pack.df[count,"fileName"] <- IsException
    } else {
      ### GET FILE NAME
      thepage = readLines(paste(repository,package,'/index.html',sep=""))
      index<-grep("Package&nbsp;source:",thepage)+1
      filename<-gsub(" <.*$","",gsub("^.*\"> ","",thepage[index]))
      pack.df[count,"fileName"] <- filename
      ### DOWNLOAD FILE
      download.file(paste(repository.dl,filename,sep=""),dest=paste(dest,filename,sep=""))
    }
  }
  return(pack.df)
}

getDependsAndImports <- function(package,type,repository="https://cran.r-project.org/web/packages/",repository.dl="https://cran.r-project.org/src/contrib/") {
  thepage = readLines(paste(repository,package,'/index.html',sep=""))
  
  ### GET Imports/Depends
  index<-grep(type,thepage)+1
  if (length(index) >0 ) {
    package.imports<-gsub("^.*>","",strsplit(thepage[index],"</a")[[1]])
    package.imports<-package.imports[nchar(package.imports)>0]
  } else {
    package.imports = c()
  }
  return(package.imports)
}

dependenciesMissing <- function(package,pack.df) {
  Imports<-getDependsAndImports(package,"Imports")
  Depends<-getDependsAndImports(package,"Depends")
  Dependencies<-c(Imports,Depends)
  Dependencies<-Dependencies[!(Dependencies %in% pack.df$package)]
}

exceptionList <- function(package,dest) {
  packages<-c("stringi")
  URL<-c("https://github.com/gagolews/stringi/archive/master.zip")
  fileName<-c("stringi-master.zip")
  unzip<-c(TRUE)
  exception.df <- data.frame(packages,URL,fileName,unzip)
  
  if (package %in% exception.df$packages) {
    package.details <- exception.df[packages==package,]
    download.file(as.character(package.details$URL),dest=paste(dest,package.details$fileName,sep=""))
    
    # If file needs unzipping
    if (package.details$unzip == TRUE) {
      
      print(paste("Unzipping",fileName))
      unzip(paste(dest,package.details$fileName,sep=""),exdir=gsub("/{1}$","",dest))
      print(paste("Cleaning up",fileName))
      file.remove(paste(dest,package.details$fileName,sep=""))
      fileName<-gsub("\\..*$","",fileName)
    }
    
    return(as.character(fileName))
  } else {
    return(FALSE)
  }
  
}
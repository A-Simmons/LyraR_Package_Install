# Copyright (c) <2016> <Alex Simmons>
  
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
# and associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
  
#The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Version: 0.1b
# Repository: https://github.com/A-Simmons/LyraR_Package_Install
# Submit any and all issues or sugesstions to: https://github.com/A-Simmons/LyraR_Package_Install/issues
# Any packages not included in the exception list 

#


getDependencies <- function(packages.toinstall,dest="C:/R_Library_Source_Files/") {
  
  # Make list of dependenciesUsing the
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
  
  # Make module load string
  module.load.string <- getModulesToLoad(pack.df$package)
  
  cat(sprintf("\nLoad the required modules with this line. Note, this line will be needed in your .pbs or .sub file to ensure all modules are loaded for code execution, not just installation!\n\n"))
  print(module.load.string)
  
  # Make Install Script String
  install.string <- "R CMD INSTALL --library=<your_personal_library_location> "
  for (file in pack.df$fileName) {
    install.string <- paste(install.string,file)
  }
  
  cat(sprintf("\nInstall string. CD to the location you store the source files and add the location of your personal library.\n\n"))
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
  # Load Exception List
  exception.df <- read.csv("https://raw.githubusercontent.com/A-Simmons/LyraR_Package_Install/master/LyraR_Package_Exception_List.csv",header=TRUE,stringsAsFactors=FALSE)
  
  if (package %in% exception.df$packages) {
    package.details <- exception.df[exception.df$packages==package,]
    fileName<-package.details$fileName
    
    download.file(as.character(package.details$URL),dest=paste(dest,fileName,sep=""))
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

getModulesToLoad <- function(packages) {
  exception.df <- read.csv("https://raw.githubusercontent.com/A-Simmons/LyraR_Package_Install/master/LyraR_Package_Exception_List.csv",header=TRUE,stringsAsFactors=FALSE)
  string <- "module load R/3.2.4_gcc"
  for (package in packages) {
    string<-paste(string,exception.df[exception.df$packages %in% package,"module"])
  }
  return(gsub(" +"," ",string))
}
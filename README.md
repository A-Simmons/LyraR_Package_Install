# LyraR_Package_Install

This script partially automates the installation of packages to a personal library of the HPC (Lyra). The primary power of this script is the automated recursive determining and fetching a package's dependencies. 

Inputs:
+ packages.toinstall: A vector of the package names you wish to install.
+ dest: Path to location to store all the downloaded source files locally (Default="C:/R_Library_Source_Files/"). 

As an example, consider the need for the packages `dplyr` and `ssh.utils`. `dplyr` requires `assertthat`, `R6`, `Rcpp`, `tibble`, `magrittr`, `lazyeval`, and `DBI`. Quite a few packages but no particular issues. On the other hand, `ssh.utils` requires `stringr` which itself requires `stringi` and `magrittr`. If you needed to install even just 5 packages manually, you might be required to keep track of over 20 dependencies which will need a specific installation order.

This script automates this recursive search and even specifies a specific package install order to compensate for these dependency trees. It will also identify when a particular module is needed in addition to R to install a package (support for this feature is limited to my knowldege of particular packages. Submit an issue if you find a package that needs an additional module).

Taking a look at the script in action loading rjags and ssh.utils:
```R
getDependencies(c("rjags","ssh.utils"))
trying URL 'https://cran.r-project.org/src/contrib/lattice_0.20-33.tar.gz'
Content type 'application/x-gzip' length 353706 bytes (345 KB)
downloaded 345 KB

trying URL 'https://github.com/gagolews/stringi/archive/master.zip'
Content type 'application/zip' length 26388563 bytes (25.2 MB)
downloaded 25.2 MB

[1] "Unzipping stringi-master.zip"
[1] "Cleaning up stringi-master.zip"
trying URL 'https://cran.r-project.org/src/contrib/magrittr_1.5.tar.gz'
Content type 'application/x-gzip' length 200504 bytes (195 KB)
downloaded 195 KB

trying URL 'https://cran.r-project.org/src/contrib/coda_0.18-1.tar.gz'
Content type 'application/x-gzip' length 73289 bytes (71 KB)
downloaded 71 KB

trying URL 'https://cran.r-project.org/src/contrib/stringr_1.0.0.tar.gz'
Content type 'application/x-gzip' length 34880 bytes (34 KB)
downloaded 34 KB

trying URL 'https://cran.r-project.org/src/contrib/rjags_4-6.tar.gz'
Content type 'application/x-gzip' length 71719 bytes (70 KB)
downloaded 70 KB

trying URL 'https://cran.r-project.org/src/contrib/ssh.utils_1.0.tar.gz'
Content type 'application/x-gzip' length 112881 bytes (110 KB)
downloaded 110 KB


List of downloaded packages:
    package rank               fileName
4   lattice    2 lattice_0.20-33.tar.gz
6   stringi    2         stringi-master
7  magrittr    2    magrittr_1.5.tar.gz
3      coda    1     coda_0.18-1.tar.gz
5   stringr    1   stringr_1.0.0.tar.gz
1     rjags    0       rjags_4-6.tar.gz
2 ssh.utils    0   ssh.utils_1.0.tar.gz

Load the required modules with this line.

[1] "module load R/3.2.4_gcc jags/4.2.0  "

Install string. CD to the location you store the source files and add the location of your personal library.

[1] "R CMD INSTALL --library=<your_personal_library_location>  lattice_0.20-33.tar.gz stringi-master magrittr_1.5.tar.gz coda_0.18-1.tar.gz stringr_1.0.0.tar.gz rjags_4-6.tar.gz ssh.utils_1.0.tar.gz"
```



# Usage:
1. Create a local folder to store all the package source files 
2. Run `getDependencies()` giving a vector of package names and the path to the local folder created.
3. Create a directory on the HPC file server for your R library
4. Create a directory on the HPC file server to store the package source files
  * Copy the source files in your local folder to this new folder on the HPC file server
5. Run `module load R/3.2.4_gcc`
6. Run the install script outputted at the end of script e.g., `R CMD INSTALL --library=...`
  * Change `<your_personal_library_location>` to be the path to the directory of the R library you created in step 3


# Issues:
This script is not by means perfect. If there exist system requirements for the package this script can not automatically determine and attempt to meet these requirements. An example of this is the `stringi` package where the version from CRAN requires ICU4C. To remedy this, an exception list exists to fix these cases if possible and when known about.

If you know about a package that has other system requirements please lodge an issue [here](https://github.com/A-Simmons/LyraR_Package_Install/issues)

## Module Support
At present the following packages call for particular modules to be loaded
  * rjags: jags/4.2.0
  * rgdal: gdal/1.8.1
  
Again, lodge an issue [here](https://github.com/A-Simmons/LyraR_Package_Install/issues) if you would like support extended to other packages.  

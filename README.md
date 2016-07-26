# LyraR_Package_Install

This script partially automates the installation of packages to a personal library of the HPC (Lyra). The primary power of this script is the automated recursive determining and fetching a package's dependencies. 

Inputs:
+ packages.toinstall: A vector of the package names you wish to install.
+ dest: Path to location to store all the downloaded source files locally (Default="C:/R_Library_Source_Files/"). 

As an example, consider the need for the packages `dplyr` and `ssh.utils`. `dplyr` requires `assertthat`, `R6`, `Rcpp`, `tibble`, `magrittr`, `lazyeval`, and `DBI`. Quite a few packages but no particular issues. On the other hand, `ssh.utils` requires `stringr` which itself requires `stringi` and `magrittr`. If you needed to install even just 5 packages manually, you might be required to keep track of over 20 dependencies which will need a specific installation order.

This script automates this recursive search and even specifies a specific package install order to compensate for these dependency trees. 

Taking a look at the script in action:
```R
getDependencies(c("dplyr","ssh.utils"))
trying URL 'https://github.com/gagolews/stringi/archive/master.zip'
Content type 'application/zip' length 200 bytes
downloaded 25.2 MB

[1] "Unzipping stringi-master.zip"
[1] "Cleaning up stringi-master.zip"
trying URL 'https://cran.r-project.org/src/contrib/assertthat_0.1.tar.gz'
Content type 'application/x-gzip' length 10187 bytes
downloaded 10187 bytes

trying URL 'https://cran.r-project.org/src/contrib/R6_2.1.2.tar.gz'
Content type 'application/x-gzip' length 270461 bytes (264 KB)
downloaded 264 KB

trying URL 'https://cran.r-project.org/src/contrib/Rcpp_0.12.6.tar.gz'
Content type 'application/x-gzip' length 2415707 bytes (2.3 MB)
downloaded 2.3 MB

trying URL 'https://cran.r-project.org/src/contrib/tibble_1.1.tar.gz'
Content type 'application/x-gzip' length 46526 bytes (45 KB)
downloaded 45 KB

trying URL 'https://cran.r-project.org/src/contrib/magrittr_1.5.tar.gz'
Content type 'application/x-gzip' length 200504 bytes (195 KB)
downloaded 195 KB

trying URL 'https://cran.r-project.org/src/contrib/lazyeval_0.2.0.tar.gz'
Content type 'application/x-gzip' length 317272 bytes (309 KB)
downloaded 309 KB

trying URL 'https://cran.r-project.org/src/contrib/DBI_0.4-1.tar.gz'
Content type 'application/x-gzip' length 141644 bytes (138 KB)
downloaded 138 KB

trying URL 'https://cran.r-project.org/src/contrib/stringr_1.0.0.tar.gz'
Content type 'application/x-gzip' length 34880 bytes (34 KB)
downloaded 34 KB

trying URL 'https://cran.r-project.org/src/contrib/dplyr_0.5.0.tar.gz'
Content type 'application/x-gzip' length 708476 bytes (691 KB)
downloaded 691 KB

trying URL 'https://cran.r-project.org/src/contrib/ssh.utils_1.0.tar.gz'
Content type 'application/x-gzip' length 112881 bytes (110 KB)
downloaded 110 KB


List of downloaded packages:
      package rank              fileName
11    stringi    2        stringi-master
3  assertthat    1 assertthat_0.1.tar.gz
4          R6    1       R6_2.1.2.tar.gz
5        Rcpp    1    Rcpp_0.12.6.tar.gz
6      tibble    1     tibble_1.1.tar.gz
7    magrittr    1   magrittr_1.5.tar.gz
8    lazyeval    1 lazyeval_0.2.0.tar.gz
9         DBI    1      DBI_0.4-1.tar.gz
10    stringr    1  stringr_1.0.0.tar.gz
1       dplyr    0    dplyr_0.5.0.tar.gz
2   ssh.utils    0  ssh.utils_1.0.tar.gz

Install string. CD to the location you store the source files and add the lcoation of your personal library.

[1] "R CMD INSTALL --library=<your_personal_library_location>  stringi-master assertthat_0.1.tar.gz R6_2.1.2.tar.gz Rcpp_0.12.6.tar.gz tibble_1.1.tar.gz magrittr_1.5.tar.gz lazyeval_0.2.0.tar.gz DBI_0.4-1.tar.gz stringr_1.0.0.tar.gz dplyr_0.5.0.tar.gz ssh.utils_1.0.tar.gz"
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

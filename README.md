# Text prediction

![R](https://img.shields.io/badge/R-4.0.x-blue)
![MIT license](https://img.shields.io/badge/License-MIT-green.svg)

Below can be found the steps to re-run the paper: **Micro loan funding speed: Predicting loan speed from qualitative data**.

# Prerequisites

The following packages need to be installed.
You can use any method to install the prerequisites.
If you work in Windows, I recommend using [Chocolatey](https://chocolatey.org/install).
If you decide to use Chocolatey, open an _admin_ PowerShell prompt and run the code snipet below.

* [7zip](https://www.7-zip.org/)
* [R](https://cran.r-project.org/bin/windows/base/)
* [R Studio](https://www.rstudio.com/products/rstudio/download/)
  
```{ps1}
if('Unrestricted' -ne (Get-ExecutionPolicy)) { Set-ExecutionPolicy Bypass -Scope Process -Force }
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
refreshenv
choco install 7zip -y
choco install r.project -y
choco install r.studio -y
```
# Steps

Below is a brief summary of each of the steps needed to re-produce the research.
The pathing can be changed to any desired location.

01. Copy the [results](https://github.com/KivaAnalysis/data/releases/download/v1.0/loans.tar.gz) from the [data repository](https://github.com/KivaAnalysis/data) in GitHub into the `~/data` folder.
    This data is common accross all papers in this project.
02. Open a PowerShell prompt and un-zip and un-tar the file `loans.tar.gz`.
    Get rid of all the stuff we don't need.
    ```{ps1}
    cd "d:/repos/KivaAnalysis/paper-textprediction/data"
    . "C:/Program Files/7-Zip/7z.exe" x *.gz
    . "C:/Program Files/7-Zip/7z.exe" x *.tar
    del loans.*
    ```
03. Double click on `~/code/model_data.rmd`.
    This will open up RStudio.
04. Click the _Run All_ (Ctrl + Alt + R) button.
    This will (re)run the modeling process.
    A working `csv` will be placed into the `~/data` folder and overall results into the `~/results` folder
05. Close RStudio.
06. Double click on `~/code/analyse_data.rmd`.
    This will open up RStudio.
07. Click the _Run All_ (Ctrl + Alt + R) button.
    This will (re)run the analysis process and put the results into the `~/results` folder.
08. Close RStudio.
09. Double click on `~/paper/index.rmd`.
    This will open up RStudio.
10. Click the _Knit_ (Ctrl + Shift + K) button.
    This will knit the paper to PDF.

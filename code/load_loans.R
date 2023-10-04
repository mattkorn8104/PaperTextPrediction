require(jsonlite)
require(dplyr)
require(lubridate)

load_loans <- function(folder) {
  load_loan_file <- function(file) {
    obj <- fromJSON(file, flatten = T)
    df <- obj[["data"]][["lend"]][["loans"]][["values"]]
    df <- ensure_columns(df)
    t1 <- strsplit(file, fixed = T, '.')[[1]]
    if(!is.null(ncol(df))) {
      df$country <- t1[length(t1)-3]
      df$runid <- t1[length(t1)-2]
      df$file <- as.integer(t1[length(t1)-1])
      df <- df[!is.na(df$id),]
    }
    rm(obj, t1)
    df
  }
  ensure_columns <-  function(df) {
    expected <-
      c('__typename','activity.id','borrowerCount','businessDescription',
        'businessName','delinquent','description','disbursalDate',
        'distributionModel','endorsement','fundraisingDate','gender',
        'geocode.city','geocode.state','geocode.postalCode','id',
        'image.height','image.id','image.url','image.width','inPfp',
        'isMatchable','lenderRepaymentTerm','lenders.totalCount',
        'loanAmount','loanFundraisingInfo.fundedAmount',
        'loanFundraisingInfo.reservedAmount','name','originalLanguage.id',
        'paidAmount','partnerId','plannedExpirationDate','purpose',
        'raisedDate','repaymentInterval','status','sector.id','tags',
        'teams.totalCount','terms.currencyFullName','terms.disbursalAmount',
        'terms.disbursalDate','terms.flexibleFundraisingEnabled',
        'themes','trusteeId','use','whySpecial')
    actual <- colnames(df)
    if (!is.null(actual)) {
      for (ex in expected) {
        if ((!ex %in% actual)) {
          df[, ex] <- NA
        }
      }
      rm(ex)
    }
    rm(expected, actual)
    df
  }
  
  if (!dir.exists(folder)) {
    stop('folder does not exist')
  }
  
  files <-
    list.files(
      path = folder,
      pattern = '*.json',
      full.names = T,
      recursive = T
    )
  pb <- txtProgressBar(max = length(files), style = 3)
  t1 <- vector(mode = 'list', length = length(files))
  for (i in 1:length(files)) {
    setTxtProgressBar(pb, i)
    file <- files[i]
    df <- load_loan_file(file)
    t1[[i]] <- df
    rm(file, df)
  }
  close(pb)
  t1 <- do.call(rbind, t1)
  rm(load_loan_file, ensure_columns, files, pb, i)
  
  t1$loanAmount <- as.numeric(t1$loanAmount)
  t1$paidAmount <- as.numeric(t1$paidAmount)
  t1$terms.disbursalAmount  <- as.numeric(t1$terms.disbursalAmount)
  t1$loanFundraisingInfo.fundedAmount <- as.numeric(t1$loanFundraisingInfo.fundedAmount)
  t1$loanFundraisingInfo.reservedAmount <- as.numeric(t1$loanFundraisingInfo.reservedAmount)
  
  t1$disbursalDate <- ymd_hms(t1$disbursalDate)
  t1$fundraisingDate <- ymd_hms(t1$fundraisingDate)
  t1$plannedExpirationDate <- ymd_hms(t1$plannedExpirationDate)
  t1$raisedDate <- ymd_hms(t1$raisedDate)
  t1$terms.disbursalDate <- ymd_hms(t1$terms.disbursalDate)
  
  t1 %>%
    group_by(id) %>%
    mutate(rank = rank(-1*as.numeric(runid))) %>%
    filter(rank == 1) %>%
    select(-rank) %>%
    as.data.frame()
}
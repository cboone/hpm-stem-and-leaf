stem.and.leaf <- function(data, unit, m, Min, Max, 
                      rule.line = c("Dixon", "Velleman", "Sturges"), style = c("Tukey", "bare"),
                      trim.outliers = TRUE, depths = TRUE, reverse.negative.leaves = TRUE, sort = FALSE,
                      na.rm = FALSE) {
  if (0 < length(h <- find("debug.cond")) && ".GlobalEnv" %in% h) {
    debug.cond <- get("debug.cond", env = .GlobalEnv)
  } else {
    debug.cond <- ""
  }
  
  debug.show <- function(name, object = NULL) {
    if (debug.cond == "all" || (name %in% debug.cond)) {
      cat(name, ":\n")
      if (is.null(object)) {
        object <- eval(parse(text = name))
      }
      show(object)
      return()
    }
  }
  
  if (missing(data)) {
    cat("Author:  Peter Wolf 05/2003,", 
        "(modified slightly by J. Fox, 20 July 03)",
        "03/2006 additional rounding to prevent misclasification",
        "07/2008 counting of NA's, 04/2009 improvement of rounding",
        "syntax: stem.leaf(data.set)\n", sep = "\n")
    return("Warning: no data set found by stem.leaf")
  }        
  
  rule.line <- match.arg(rule.line)
  style <- match.arg(style)
  
  data.na.count <- sum(is.na(data))
  if (data.na.count > 0) {
    data <- data[!is.na(data)]
    if (na.rm) {
      # data <- data[!is.na(data)]
      print("Warning: NA elements have been removed!")
    } else {
      # data[is.na(data)] <- mean(data, na.rm = TRUE)
      # print("Warning: NA elements have been exchanged by the mean value!")
    }
  }
  
  if (sort) {
    data <- sort(data)
  } else {
    data <- as.numeric(data)
  }
  debug.show("data", data)
  
  n <- length(data)
  
  row.max <- floor(c(Dixon = 10 * log(n, 10), Velleman = 2 * sqrt(n), Sturges = 1 + log(n, 2)))[rule.line]
  
  stats <- boxplot(data, plot = FALSE)
  if (missing(Min)) {
    if (trim.outliers) {
      Min <- stats$stats[1, 1]
    } else {
      Min <- min(data, na.rm = TRUE)
    }
  }
  if (missing(Max)) {
    if (trim.outliers) {
      Max <- stats$stats[5, 1]
    } else {
      Max <- max(data, na.rm = TRUE)
    }
  }
  spannweite.red <- Max - Min
  
  zeilen.intervall.laenge<-spannweite.red / row.max
  if(missing(unit)){
         factor <- 10^ceiling(log(zeilen.intervall.laenge,10))
  } else factor <- 10^round(log(unit*10,10))
  debug.show("factor")
  
  z<-zeilen.intervall.laenge/factor  # z in (0.1 ,1]
  delta.tick<-c(.2,.2,.5,1)[sum(z>c(0,.1,.2,.5))]
  
  if(missing(m)) m<-round(1/delta.tick) else delta.tick<-1/m
  debug.show("delta.tick")
  debug.show("m")
  
  data.tr<-data/factor
  Min.tr <- Min/factor
  Max.tr <- Max/factor
  
  spannweite.red<-Max.tr - Min.tr
  sk.min<-  floor(Min.tr)
  sk.max<-ceiling(Max.tr)
  skala <- seq(sk.min,sk.max,by=delta.tick)
  if(sk.min<0) skala<-c(sk.min-delta.tick,skala)
  if(sk.max<0) skala<-skala[-length(skala)]
  debug.show("skala")
  
  
  lo.limit <- if (trim.outliers) skala[1] else -Inf
  lo.log   <- if(skala[1   ] <  0) data.tr <= lo.limit else data.tr <  lo.limit
  n.sk <- length(skala)
  hi.limit <- if (trim.outliers) skala[n.sk] + delta.tick else Inf
  hi.log   <- if(skala[n.sk] >= 0) data.tr >= hi.limit else data.tr >  hi.limit
  
  n.lower.extr.values <- sum(lo.log); n.upper.extr.values <- sum(hi.log)
  if(0<n.lower.extr.values){
    lower.line<- paste("LO:", paste(data[lo.log],collapse=" "))
  }
  if(0<n.upper.extr.values){
    upper.line<- paste("HI:", paste(data[hi.log],collapse=" "))
  }
  data.tr.red <-data.tr[(!lo.log)&(!hi.log)]
  
  
  stem <- ifelse(data.tr.red<0, ceiling(data.tr.red), floor(data.tr.red) )
  # eps<-1e-12; leaf <- floor(abs(data.tr.red*10-stem*10)+eps)
  leaf <- floor(10*abs(signif(data.tr.red-stem,10)))
  debug.show("leaf"); debug.show("stem")
  
  class.of.data.tr<-unlist(c(
     sapply(signif(data.tr.red[data.tr.red< 0],10),
       function(x,sk)length(sk)-sum(-sk<=-x),signif(skala,10))
    ,sapply(signif(data.tr.red[data.tr.red>=0],10),
       function(x,sk)sum( sk<= x),signif(skala,10))
  ))
  debug.show("class.of.data.tr")
  class.of.data.tr  <- c(1:length(skala),class.of.data.tr)
  leaf.grouped      <- split(c(rep(-1,length(skala)),leaf),class.of.data.tr)
  # debug.show("leaf.grouped")
  if (sort) {
    leaf.grouped <- lapply(leaf.grouped, function(x) { sort(x[-1]) })
  } else {
    leaf.grouped <- lapply(leaf.grouped, function(x) { x[-1] })
  }
  # debug.show("leaf.grouped")
  
  leaf.grouped.ch <- paste("|",unlist(lapply(leaf.grouped,paste,collapse="")))
  # debug.show("leaf.grouped")
  
  class.negative <- skala < 0
  class.neg.zero <- floor(skala) == -1
  
  if (reverse.negative.leaves){
          for (i in seq(class.negative))
              if (class.negative[i]) leaf.grouped[[i]] <- rev(leaf.grouped[[i]])
  }
  
  line.names <- skala
  line.names[class.negative] <- line.names[class.negative]+1
  line.names <- as.character(floor(line.names))
  line.names[class.neg.zero] <- "-0"
  
  
  if(style=="Tukey"){
    switch(as.character(m),
    "1"={},
    "2"={
          h<-round(2*(skala%%1)) #; line.names[h!=0] <- ""
          line.names<-paste(line.names,
                  ifelse(skala<0,c(".","*")[1+h],c("*",".")[1+h]),sep="")
        },
    "5"={
          h<-round(5*(skala%%1)); line.names[h>0 & h<4] <- ""
          line.names<-paste(line.names, ifelse(skala<0,
                           c(".","s","f","t","*")[1+h],
                           c("*","t","f","s",".")[1+h]), sep="")
        }
    )
  }
  ragged.left<-function(ch.lines){
    max.n <-max(n.lines<-nchar(ch.lines))
    h     <-paste(rep(" ",max.n),collapse="")
    ch.lines <-paste( substring(h,1,1+max.n-n.lines), ch.lines)
    ch.lines
  }
  
  line.names <- ragged.left(line.names)
  
  
  n.class<-unlist(lapply(leaf.grouped,length))
  select <- (cumsum(n.class) > 0) & rev((cumsum(rev(n.class)) > 0))
  depth    <-    cumsum(n.class)          + n.lower.extr.values
  depth.rev<-rev(cumsum(rev(n.class))     + n.upper.extr.values)
  debug.show("depth")
  
  uplow<-depth>=depth.rev
  pos.median<-which(uplow)[1] + (-1:0)
  h <- abs(depth[pos.median]-depth.rev[pos.median])
  pos.median<-pos.median[1]+(h[1]>h[2])
  debug.show("pos.median")
  
  depth[uplow]<-depth.rev[uplow]
  depth<-paste(depth,"")
  depth[pos.median]<-paste("(",n.class[pos.median],")",sep="")
  depth[n.class==0]<-" "
  depth <- if (depths) ragged.left(depth) else ""
  
  
  info<-     c(  paste("1 | 2: represents",1.2*factor),
             #  paste("    m:",m     ),
                 paste(" leaf unit:",factor/10),
                 paste("            n:",n     ))
  
  
  stem <- paste(depth, line.names, leaf.grouped.ch)
  stem <- if((m!=5)||sum(select)>4) stem[select] else stem
  result<-list( stem=stem)
  if(exists("lower.line")) result<-c(lower=lower.line,result)
  if(exists("upper.line")) result<-c(result,upper=upper.line)
  if(0<data.na.count&&!na.rm) result<-c(result,NAs=paste("NA's:",data.na.count,collapse=" "))
  result<-c(list( info=info), result)
  for(i in seq(result)) cat(result[[i]],sep="\n")
  invisible(result)
  
}

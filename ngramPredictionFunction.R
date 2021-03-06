ngramPredictionFunction <- function(input, ngram1, ngram2, ngram3, ngram4, ngram5) { 
  
  out <- data.table(y = c(" ", "  ", "   ", "    ", "     ", "      "), freq = rep(0,6)) # dummy output
  LastChar <- substring(input, nchar(input), nchar(input))    
  input <- NGramTokenizer(input, Weka_control(min = 1, max = 1, delimiters = " \\r\\n\\t,;:\"()?!"))
  
  # lastChar is space?
  
  if (LastChar==" ") { # new word
    LastWord = paste("^",  character(0) , sep="")
  } else { # filter
    LastWord <- paste("^",  input[length(input)] , sep="")      
    input <- input[-length(input)]
  }
  
  # 5-gram
  if (length(input)>3) {
    txt <- paste(input[(length(input)-3):length(input)], collapse=" ")
    wd.list <- ngram5[ngram5$x==txt, c(2,3)]
    wd.list <- wd.list[grep(LastWord, wd.list$y),]
    wd.list$freq <- wd.list$freq /sum(wd.list$freq)*0.8
    out <- rbind(out, wd.list)
  }
  
  # 4-gram
  if (length(input)>2) {
    txt <- paste(input[(length(input)-2):length(input)], collapse=" ")
    wd.list <- ngram4[ngram4$x==txt, c(2,3)]
    wd.list <- wd.list[grep(LastWord, wd.list$y),]
    wd.list$freq <- wd.list$freq /sum(wd.list$freq)*0.6
    out <- rbind(out, wd.list)
    temp<-unlist(strsplit(txt,"[ ]"))
    temp[1]<-paste(temp[1],temp[2])
    if(temp[1]%in%ngram3$x&temp[3]%in%ngram3$y) {
      ngram3$freq[temp[1]%in%ngram3$x&temp[3]%in%ngram3$y] = ngram3$freq[temp[1]%in%ngram3$x&temp[3]%in%ngram3$y] + 10
      save(ngram3,file = "ngram3.RData")
    } else {
      ngram3[nrow(ngram3) + 1,] = list(temp[1],temp[3],10)
      save(ngram3,file = "ngram3.RData")
    }
  }
  
  # 3-gram
  if (length(input)>1) {
    txt <- paste(input[(length(input)-1):length(input)], collapse=" ")
    wd.list <- ngram3[ngram3$x==txt, c(2,3)]
    wd.list <-  wd.list[grep(LastWord, wd.list$y),]
    wd.list$freq <- wd.list$freq /sum(wd.list$freq)*0.3
    out <- rbind(out, wd.list)
    temp<-unlist(strsplit(txt,"[ ]"))
    if(temp[1]%in%ngram2$x&temp[2]%in%ngram2$y) {
      ngram2$freq[temp[1]%in%ngram2$x&temp[2]%in%ngram2$y] = ngram2$freq[temp[1]%in%ngram2$x&temp[2]%in%ngram2$y] + 10
      save(ngram2,file = "ngram2.RData")
    } else {
      ngram2[nrow(ngram2) + 1,] = list(temp[1],temp[2],10)
      save(ngram2,file = "ngram2.RData")
    }
  }
  
  # 2-gram
  if (length(input)>0) {
    txt <- input[length(input)]
    wd.list <- ngram2[ngram2$x==txt, c(2,3)]
    if (LastWord != "^") {wd.list <-  wd.list[grep(LastWord, wd.list$y),]}
    wd.list$freq <- wd.list$freq /sum(wd.list$freq )*0.08
    wd.list <- wd.list[min(1,nrow(wd.list)):min(100,nrow(wd.list)),]          
    out <- rbind(out, wd.list)
    if(txt%in%ngram1$y) {
      ngram1$freq[ngram1$y == txt] = ngram1$freq[ngram1$y == txt] + 10
      save(ngram1,file = "ngram1.RData")
    } else {
        ngram1[nrow(ngram1) + 1,] = list(txt,10)
        save(ngram1,file = "ngram1.RData")
      }
  }
  
  # 1-gram
  wd.list <- ngram1[grep(LastWord, ngram1$y),]
  wd.list$freq <- wd.list$freq /sum(wd.list$freq)*0.02
  wd.list <- wd.list[min(1,nrow(wd.list)):min(100,nrow(wd.list)),]
  out <- rbind(out, wd.list)
  
  out <- out[, lapply(.SD, sum), by = c("y")]
  out <- out[order(-out$freq),]
  rownames(out) <- NULL
  
  return(head(out, n=5))
  
}
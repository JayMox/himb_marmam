##Frustum calc, Fabi way 
##JHMoxley, May 31 2019
library(xlsx)
library(tidyverse)
files <- list.files(path = 'data', pattern = "*lengths.csv", 
                    recursive = T, full.names = T)
#batch load dat
dat <- sapply(files[-9], read_csv, skip=1, simplify=F) %>% 
  set_names(files[-9]) %>% 
  bind_rows(.id = "Filename")
dat %>% 
  select(file = "Filename", 
         contains("%"), #grab widths
         length = "Total Length (m)", 
         alt = "Corrected height (m)") %>% 
  gather(field, width, -file, -length, -alt)
  

# 
# dat <- sapply(files[-9], read.xlsx, startRow=2, header=T, sheetIndex=1) %>% 
#   set_names(files[-9]) %>% 
#   bind_rows(.id = "Filename")

sc <- read.xlsx(files[1], startRow=2, header=T, sheetIndex=1)

totvol <- NULL
vol_allInds <- NULL

for(i in 1:length(dirs)){
  
}
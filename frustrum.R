##frustum calcs, JHMoxley, May 30 2019
spp <- data.frame(species = rbind("Southern_Right_Whales",
                          "Humpback_Whales",
                          "Gray_Whales", 
                          "Bottlenose_Dolphin"), 
                  start = c(25, 25,20, 10),
                  end = c(90, 90, 90, 90))
spp$species <- as.character(spp$species)
require(tidyverse)
require(zoo) #for rollapply
frustVol <- function(r1, r2, h){
  #SELECTION OF SPP DIMS HERE
  
  r1 = r1/2; r2 <- r2/2 #calc r from width dim
  print(paste("r1 is ", r1, "& r2 is ", r2))
  #calc vol of cone
  vol <- ((pi*h)/3)*((r1^2) + (r1*lead(r1)) + (lead(r1)^2))
  return(vol)
}


#create files log
(files <- list.files(path = "data/", pattern = "* lengths.csv", recursive = T))
#needs batch conver of .xlsx
print(paste("found", length(files), "length data file to scrape"))
#get dat, ignore row 1 field

data <- data.frame(NULL)
for(i in 1:length(files)){
  print(i)
  dat <- read_csv(file.path("data", files[i]), skip = 1)
  
  ests <- dat %>% 
    mutate(start = spp$start[str_detect(Folder, spp$species)],
           end = spp$end[str_detect(Folder, spp$species)]) %>% 
    select(file = "Filename", 
           contains("%"), #grab widths
           length = "Total Length (m)", 
           alt = "Corrected height (m)", 
           start, end) %>% 
    gather(field, width, -file, -length, -alt, -start, -end) %>%
    #remove unneded 10
    filter(!is.na(width)) %>% 
    #grab the loc of slice
    mutate(loc = stringr::str_extract(field, "\\d+"), 
           width = as.numeric(width), 
           h = length * 0.05, 
           vol = frustVol(width, lead(width), h),
           indi = files[i])
  
 data <- rbind(data, ests %>% 
                 select(file, length, alt, width, loc, vol,indi, start, end))
}



vols <- data %>% 
  group_by(indi) %>% 
  summarize(
    length = unique(length), 
    alt = unique(alt),
    #start = unique(start), end = unique(end),
    tvol = sum(vol, na.rm = T),
    vol = sum(vol[loc >= start & loc <= end], na.rm = T)
  )
  
  

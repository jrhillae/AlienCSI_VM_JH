#library(rglobi)
library(stringr)


#read in input
species_list <- read_excel("Iguana's/species list for secondary interactions (1).xlsx", 
                           +     sheet = "all taxons", col_names = FALSE)
#clean up input
names(species_list)[1] <- "input_list"

#create vector with all types of interactions occurring in GLobI
all_interactions <- c("eats",
                      "eatenBy",
                      "preysOn",
                      "preyedUponBy",
                      "kills",
                      "killedBy",
                      "parasiteOf",
                      "hasParasite",
                      "hasEndoparasite",
                      "hasEctoparasite",
                      "hasParasitoid",
                      "hasHost",
                      "pollinatedBy",
                      "hasPathogen",
                      "hasVector",
                      "hasDispersalVector",
                      "createsHabitatFor",
                      "hasEpiphyte",
                      "acquiresNutrientsFrom",
                      "mutualistOf",
                      "flowersVisitedBy",
                      #"ecologicallyRelatedTo",
                      "coRoostsWith",
                      "adjacentTo")

 
#looping over all species within species list
for (species_name in species_list$input_list[1]) {
  
  #replace white space with '%20', which is necessary for API
  species_name <- str_replace_all(species_name, ' ', '%20')
  print(species_name)
  
    #loop over all types of interactions within GloBI
    for (interaction_type in all_interactions){
      
      #load all interactions of a certain type and species and store in temporary file 
      temp_download <- read.csv(paste0("https://api.globalbioticinteractions.org/taxon/",
                              species_name,
                              "/",
                              interaction_type,
                              "?type=csv"))
      
      #in case at least one interaction was downloaded: write interactions in output file
      if (dim(temp_download)[1]>0) {
        
        #if output file does not yet exist, create one
        if (file.exists("download_globi.txt")==FALSE) {
        write.table(temp_download,
                    file="./Iguana's/download_globi.txt",
                    row.names=FALSE,
                    sep=";")}
        
        #add interactions to output file in case it already exists
        else {write.table(temp_download, 
                          file="./Iguana's/download_globi.txt",
                          col.names = FALSE,
                          append=TRUE,
                          row.names=FALSE,
                          sep=";")}
      }
      print(dim(temp_download)[1])
      
      #generate warning in case temporary download contained more than 1042 interactions
      #1042 was mentioned as limit in API documentation but this seems not to be the case here
      if (dim(temp_download)[1]>1042) {
        warning(paste0(
        species_name,
        ' has ',
        as.character(dim(temp_download)[1]),
        ' interactions for interaction type ',
        interaction_type
        ))
        }
    }
}
print("Finished!")



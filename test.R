#library(rglobi)
library(stringr)

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
                      "ecologicallyRelatedTo",
                      "coRoostsWith",
                      "adjacentTo")

 

for (species_name in species_list$input_list) {
  
  species_name <- str_replace_all(species_name, ' ', '%20')
  print(species_name)
  
    for (interaction_type in all_interactions){
      
      temp_download <- read.csv(paste0("https://api.globalbioticinteractions.org/taxon/",
                              species_name,
                              "/",
                              interaction_type,
                              "?type=csv"))
      
      if (dim(temp_download)[1]>0) {
      if (file.exists("download_globi.txt")==FALSE) {
      write.table(temp_download, file="download_globi.txt")}
      else {write.table(temp_download, file="download_globi.txt", col.names = FALSE, append=TRUE)}
      }
        
      print(dim(temp_download)[1])
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

#Some tests of rglobi and the API
#test <- get_interactions(taxon ="Vespa velutina")
#predators <- get_predators_of("Vespa velutina")
#preys <- get_prey_of("Vespa velutina") 
#b <- read.csv("https://api.globalbioticinteractions.org/taxon/Vespa%20velutina/eats?type=csv")
#b2 <- read.csv("https://api.globalbioticinteractions.org/taxon/Vespa%20velutina/eats?type=csv&includeObservations=true")
#b$target_taxon_name

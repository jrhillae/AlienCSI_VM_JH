#library(rglobi)
library(stringr)


#read in input
species_list <- c('Vespa velutina')


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
                      "ecologicallyRelatedTo",
                      "coRoostsWith",
                      "adjacentTo")

 
#looping over all species within species list
for (species_name in species_list) {
  
  #replace white space with '%20', which is necessary for API
  species_name <- str_replace_all(species_name, ' ', '%20')
  print(species_name)
  
    #loop over all types of interactions within GloBI
    for (interaction_type in all_interactions){
      
      #load all interactions of a certain type and species and store in temporary file 
      temp_download_source <- read.csv(paste0("https://api.globalbioticinteractions.org/taxon/",
                              species_name,
                              "/",
                              interaction_type,
                              "?type=csv"))
      
      #in case at least one interaction was downloaded: write interactions in output file
      if (dim(temp_download_source)[1]>0) {
        
        #if output file does not yet exist, create one
        if (file.exists("download_globi_source.txt")==FALSE) {
        write.table(temp_download_source,
                    file="download_globi_source.txt",
                    row.names=FALSE,
                    sep=";")}
        
        #add interactions to output file in case it already exists
        else {write.table(temp_download_source, 
                          file="download_globi_source.txt",
                          col.names = FALSE,
                          append=TRUE,
                          row.names=FALSE,
                          sep=";")}
      }
      print(dim(temp_download_source)[1])
      
      #generate warning in case temporary download contained more than 1042 interactions
      #1042 was mentioned as limit in API documentation but this seems not to be the case here
      if (dim(temp_download_source)[1]>1042) {
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
print("Finished sources!")

list_of_Phyla <- c("Porifera",
                  "Coelenterata",
                  "Ctenophora",
                  "Platyhelminthes",
                  "Aschelminthes",
                  "Arthropoda",
                  "Mollusca",
                  "Echinodermata",
                  "Hemichordata",
                  "Chordata")

all_interactions <- c("eats",
                      "eatenBy",
                      "preysOn",
                      "preyedUponBy",
                      "kills",
                      "killedBy",
                      "pollinatedBy",
                      "flowersVisitedBy",
                      "Angiospermorphyta",
                      )

for (species_name in species_list) {
  
  #replace white space with '%20', which is necessary for API
  species_name <- str_replace_all(species_name, ' ', '%20')
  print(species_name)
  
  for (interaction_type in all_interactions) {

    for (order in list_of_Phyla) {
    print(order)
    
  
          temp_download_target <- read.csv(paste0(
                          "https://api.globalbioticinteractions.org/taxon/",
                          order,
                          "/",
                          interaction_type,
                          "/",
                          species_name,
                          "?type=csv"))
          
            if (dim(temp_download_target)[1]>0) {
              
              #if output file does not yet exist, create one
              if (file.exists("./download_globi_target.txt")==FALSE) {
                write.table(temp_download_target,
                            file="./download_globi_target.txt",
                            row.names=FALSE,
                            sep=";")}
              
              #add interactions to output file in case it already exists
              else {write.table(temp_download_target, 
                                file="./download_globi_target.txt",
                                col.names = FALSE,
                                append=TRUE,
                                row.names=FALSE,
                                sep=";")}
          }
          print(dim(temp_download_target)[1])
    }
  }
}

print('Finished targets!')
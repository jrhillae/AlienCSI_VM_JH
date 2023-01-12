---
title: "Untitled"
author: "jasmijn_hillaert"
date: "2022-12-20"
output: html_document
---

```{r}
#empty environment
rm(list=ls())
```

```{r}
library(dplyr)
library(stringr)
library(tidyr)
library(rglobi)
library(tidyverse)
library(purrr)
```

```{r setup, include=FALSE}

header <- c('sourceTaxonID','sourceTaxonIDs','sourceTaxonName', 'sourceTaxonLevel', 'sourceSpeciesName', 'sourcePhylum', 'sourceKingdom', 'interactionType','targetTaxonIDs','targetTaxonName', 'targetTaxonLevel', 'targetSpeciesName', 'targetSpeciesNameID','targetPhylum', 'targetKingd')

#reading in GLOBI output
interactions_sources <- read.csv("secundary_interactions_sources_light.tsv", sep = "\t", header=FALSE, col.names=header)

interactions_targets <- read.csv("secundary_interactions_targets_light.tsv", sep = "\t", quote="\"", header=FALSE, col.names=header) 
 
primary_interactions <- read.csv("vespa-velutina-interactions-light.tsv", sep = "\t", quote="\"", header=FALSE, col.names=header) 

raw_interactions <- rbind(interactions_sources,
                          interactions_targets,
                          primary_interactions)

#todo: delete refute interactions
```


```{r}
#which interactions are occurring in dataset?
unique(raw_interactions$interactionType)

#only select relevant interactions
interactions_to_include <- c("hasHost",
                             "eats",
                             "pathogenOf",
                             "interactsWith",
                             "parasiteOf",
                             "endoparasiteOf",       
                             "ectoparasiteOf",
                             "visitsFlowersOf",
                             "preysOn",
                             "visits",
                             "endoparasitoidOf",
                             "mutualistOf",
                             "pollinates",
                             "parasitoidOf",
                             "guestOf",
                             "kills",
                             "ectoParasitoid")

interactionsCleaned <- raw_interactions %>% filter(interactionType %in% interactions_to_include) %>% 
  mutate(interactionType = str_replace(interactionType, "kills", "preyson"))%>%
  filter(sourceSpeciesName!="")%>%
  filter(targetSpeciesName!="")%>%
  select(sourceSpeciesName, 
         sourcePhylum,
         sourceKingdom,
         interactionType,
         targetSpeciesName,
         targetPhylum,
         targetKingdom)%>%
  mutate(sourcePhylum=str_replace(sourcePhylum, 'Metazoa', 'Animalia'))%>%
  mutate(targetPhylum=str_replace(targetPhylum, 'Metazoa', 'Animalia'))%>%
  distinct()
  

```

```{r}
#calculate total number of unique species in network
all_species <- sort(
            unique(
              c(interactionsCleaned$sourceSpeciesName,
                interactionsCleaned$targetSpeciesName)
              )
            )

#Find accepted name, usageKey and kingdom per species and add to dataframe
                     
df <- map_dfr(all_species, function(x) {
  
       print(x)
  
       GBIFi <- name_backbone(x, strict=TRUE)
       
       if (dim(GBIFi)[2]>7) {
       tibble(speciesName_globi = x,
              canonicalName_GBIF = GBIFi[3],
              kingdom=GBIFi[8],
              usageKey= GBIFi[1])
       }
       else tibble(speciesName_globi = x,
                  canonicalName_GBIF = NA,
                  kingdom=NA,
                  usageKey= NA)
})

write.csv(df, 'df.csv')


#todo: add strict=TRUE & kingdom from Globi within name_backbone to reduce mistakes
```

```{r}
#exploring output 
table(is.na(df$usageKey))
```
```{r}
#which species names are not found?
not_found_GBIF <- df %>%filter(is.na(df$usageKey$usageKey))
write.csv(not_found_GBIF, 'not_found_GBIF.csv')

#delete these from df
df <- df%>%filter(!is.na(df$usageKey$usageKey))
```

```{r}
#what is the distribution of kingdom and how exact is it?
table(df$kingdom$kingdom)
```
```{r}
#import the species cube after downloading it into working directory

#determine year after which observations are considered relevant

year <- 2000

cube_BE <- read_csv('be_species_cube.csv')%>%
  filter(year>=2000)

info_BE <- read.csv('be_species_info.csv')
```
```{r}
#Which species from the network occur in the cube?
df_cube <- df %>% filter(
  usageKey$usageKey%in%cube_BE$speciesKey)

#explore df_cube
unique(df_cube$kingdom$kingdom)

table(df_cube$speciesName_globi==df_cube$canonicalName_GBIF$canonicalName)

#check for strange mapping in GBIF, for the moment still included
possible_issues <- df_cube %>% filter(df_cube$speciesName_globi!=df_cube$canonicalName_GBIF$canonicalName)

write.csv(possible_issues, 'possible_issues.csv')

#clean up df_cube
df_cube_BE_clean <- df_cube%>%(
                      rename(
                        speciesName_globi2 = df_cube$speciesName_globi,
                        canonicalName_GBIF2 = df_cube$canoncinalName_GBIF$canonicalName_GBIF,
                        kingdom2 = df_cube$kingdom$kingdom,
                        usageKey2 = df_cube$usagekey$usagekey
                      )
                    )
```

```{r}

edges_cube_BE <- interactionsCleaned%>%
  filter(sourceSpeciesName %in% df_cube$speciesName_globi)%>%
  filter(targetSpeciesName %in% df_cube$speciesName_globi)
```


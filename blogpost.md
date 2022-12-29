# Getting started with GloBI to create networks

[GloBI](https://www.globalbioticinteractions.org/data) aggregates data on species interactions. It also offers the possibility to visualise species interactions. However, if you want to dive into the world of GloBI and explore its valuable data for research, it is worth the effort to learn how to work with the complete GloBI database. Within this blogpost, I offer a starting guide (set up with the help of Jorrit Poelen) on how to access the complete GloBI database to create networks. The flow presented below is largely based on [interactIAS](https://github.com/AgentschapPlantentuinMeise/interactias/blob/master/notebook/interactias.ipynb), a jupyter notebook created by Quentin Groom. This blogpost is the outcome of a virtual mobility event, supported by [Alien CSI](https://alien-csi.eu/).

## Install & setup WSL
The fastest way to perform data wrangling on large datafiles is by the linux command line. If you have a Windows laptop (like me) the best way to get started is by installing [WSL](https://learn.microsoft.com/en-us/windows/wsl/) (Windows subsystem for Linux) following [this instruction guide](https://learn.microsoft.com/en-us/windows/wsl/install). I choose to install Ubuntu as Linux distribution. 

After installation, open the Linux distribution by the start Menu: a Linux terminal will appear. The first time you open this terminal you will be asked to create a Linux username and password. 

Now, use the pwd command to find out your current working directory. 

```shell   
  $ pwd
```
You can create a new folder by:

```shell 
  $ mkdir /home/username/newfolder
```
Turn this new folder into your working directory:
```shell 
  $ cd /home/username/newfolder
```
## Data filtering from entire GloBi database 
Now, go to the GloBI website and download [the entire GloBI database](https://zenodo.org/record/7348355/files/interactions.tsv.gz). The database of GloBI is available in [many formats](https://www.globalbioticinteractions.org/data). For the following, you are advised to download a stable (citable) version of the database in tsv format. Place the download into the working directory after downloading. 

In this example, we are interested in creating a network for _Vespa velutina_, containing both direct and indirect interactions. Therefore, we now search the database for all lines containing *Vespa velutina*. This outcome is saved into a the file vespa_velutina_interactions.tsv by:
```shell  
  $ zgrep "Vespa velutina" interactions.tsv.gz >>vespa_velutina_interactions.tsv   
```
Herein, zgrep allows searching within zipped files. As such, a file does not not need to be unpacked beforehand.

Check the file vespa_velutina_interactions.tsv by printing its header within the terminal: 
 ```shell 
  $ cat vespa_velutina_interactions.tsv | head
```
Check the number of lines within vespa_velutina_interactions.tsv by:
```shell
  $ cat vespa_velutina_interactions.tsv | wc -l  
```
Before we continue it is important to highlight that an interaction always consists out of a source species, an interaction type and a target species. In the file vespa_velutina_interactions.tsv, _Vespa velutina_ might occur both as source or target species. In the following we want to list all unique source and target species with which _Vespa velutina_ is interacting. To do this, we filter all unique species names from column 8 and 48 within the file vespa_velutina_interactions.tsv. Both columns refer to the [mapped species name](https://www.globalbioticinteractions.org/process) of the source species and target species, respectively, within the interaction.

```shell
 $ cat vespa_velutina_interactions.tsv| cut -f8 | sort | uniq > vespa_velutina_sources.tsv 
 $ cat vespa_velutina_interactions.tsv| cut -f48 | sort | uniq > vespa_velutina_targets.tsv 
```
Manually remove the first row of the files in case it represents an empty line. Now we loop over each of these species within these files and write out all interactions containing these species into an output file (secundary_interactions_sources.tsv and secundary_interactions_targets.tsv, respectively)

```shell
$ while read line; do zgrep "$line" interactions.tsv.gz >>secundary_interactions_sources.tsv; done <vespa_velutina_sources.tsv
$ while read line; do zgrep "$line" interactions.tsv.gz >>secundary_interactions_targets.tsv; done <vespa_velutina_targets.tsv
```

Finally, we simplify the dataoutput to the columns we are interested in and delete any duplicate rows. The following columns are included in this output:
  - column 2: taxonids of the source species
  - column 3: taxon name
  - column 4: taxonomic level of source species
  - column 8: mapped source species name
  - column 20: phylum name source species
  - column 22: kingdom name source species
  - column 39: interaction type
  - column 42: taxonids of the target species
  - column 43: taxon name 
  - column 44: taxonomic level of target species
  - column 48: mapped target species name
  - column 60: phylum name target species
  - column 62: kingdom name target species 
 
```shell
$cat vespa_velutina_interactions.tsv| cut -f2,3,4,8,20,22,39,42,43,44,48,60,62 | sort | uniq -c | sort -nr | tee vespa_velutina_interactions-light.tsv
$cat secundary_interactions_sources.tsv| cut -f2,3,4,8,20,22,39,42,43,44,48,60,62 | sort | uniq -c | sort -nr | tee secundary_interactions_sources_light.tsv
$cat secundary_interactions_targets.tsv| cut -f2,3,4,20,22,39,42,43,44,48,60,62 | sort | uniq -c | sort -nr | tee secundary_interactions_targets_light.tsv
```
## Fine tuning of network within R

## Intermetzo: taxonomic allignment with Nomer

## Finalizing network

## Network visualisation in Gephi

## How to correctly cite your work?



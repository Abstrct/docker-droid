# docker-droid

Docker container for running a rough Coindroids bot
[Coindroids](https://coindroids.com/) with [Docker](https://www.docker.com).


# Before you begin
## Install docker
> Have to install 'docker.io' not 'docker'
```
sudo apt install docker.io
```
## Create a Coindroids account and make a droid. Do not activate the droid.



# WARNING
<del>If you close the script and shutdown the container, you'll likely lose any keys you haven't backed up. Keep in mind that as transactions are made, you'll be creating new change addresses which, even if you backed up the original key, means you've now backed up nothing. Honestly, I'd only really send this bot ~1dfc until we improve the backup process.</del>

This should be persistent, but it is still a rudamentary droid with basic logic. Still better off just sending it a few dfc max, topping it off as needed.


# container name
If you are only running 1 droid, this shouldn't matter at all to you. If you are running more than 1 droid on the same machine, each needs a unique name. The file container_name.txt is where you should put the name you want for the conttainer for this droid.
> Could have made it increment defaultdroidname001/002/003..., but decided not to because then it would make container administration more difficult.
For all of the commands listed here, you would need to manually substitute the chosen container name. Pointing it out for troubleshooting purposes.


# Simple Mode
## Build your droid and start it
```
git clone https://github.com/Abstrct/docker-droid
cd docker-droid

##########################################
# If you want to adjust the attack filters, do it now before running the next command.
##########################################

./start.sh



##########################################
# ignore this. Once updates are finished, Abstrct's readme will point to his repo and mine to mine
##########################################
git clone https://github.com/G4te-Keep3r/docker-droid.git
```
## Start your droid again
```
#navigate to docker-droid
./start_droid.sh
```
## Administration
```
./admin_droid.sh
```

> Refer to below for how to tweak your droid



# Manual Mode
> If you want to run multiple droids, you will need to change "defaultdroidname" as each docker needs a unique name
## How to Build
```
git clone https://github.com/G4te-Keep3r/docker-droid.git
cd docker-droid
sudo docker volume create defaultdroidname
##########################################
# If you want to adjust the attack filters, do it now before running the next command.
##########################################
sudo docker build .
```

## How to Use this Image
### Quickstart
The following will run a crappy Coindroids bot that, by default, will constantly attack the weakest droid. Consider changing the logic with your own strategy. Using the additional attack filters you can improve it, but it will still be a simple strategy.


This will run the docker in interactive mode (-it) but if you rather not watch the process then change this to daemon (-d). 

> Hint: You're going to want to run this as -it
```
./start_droid.sh
```
or
```
sudo docker run -it --mount source=defaultdroidname,target=/src --name=defaultdroidname -e PLAYER_USERNAME="<Your Coindroids Username>" -e PLAYER_PASSWORD="<Your Coindroids Password>" <the build image identifier from the build step (12 digit hex string) > 
```

## Administration
Administering the bot is most easily done within the container. After starting the container you can perform the following to attach to its terminal:

```
sudo docker ps
# ps is more for formality just to show you what all you have running

sudo docker exec -it defaultdroidname /bin/bash
```

## Start droid again
```
sudo docker restart defaultdroidname
```
And to get output
```
sudo docker exec -it defaultdroidname tail -f /src/droid/logs.txt
```

# Additional Attack Filters
> Refer to https://coindroids.github.io/Coindroids-Documentation/ for api info
## Before building docker
Edit the 3 files (or 1 or 2 of them) according to the Files info below.
## After the docker is built
You must modify the files from within the volume, or inside the docker if you want to go that route.
```
sudo docker volume inspect defaultdroidname
```
From this you can see the mountpoint you can edit the files. For me, sudo ls /var/lib/docker/volumes/defaultdroidname/_data/droid listed the directory the files are in.
> Being in var, everything will need to be run as root/sudo

## Files
> id_ignore.txt and other_filters.txt need their stuff prefixed with & or it wont work. With order.txt, do not prefix it with one.
### order.txt
If left blank, will default to health_current.asc
### id_ignore.txt
To not attack your other droids if you have multiple and dont want them to attack each other, ex: &id=neq.#### or &id=neq.####&id=neq.####
### other_filters.txt
For other filters you want to apply, must be prefixed with &
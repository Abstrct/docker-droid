# docker-droid

Docker container for running a rough Coindroids bot
[Coindroids](https://coindroids.com/) for [Docker](https://www.docker.com).


# Before you begin
## Install docker
> Have to install 'docker.io' not 'docker'
```
sudo apt install docker.io
```
## Create a Coindroids account and make a droid



# WARNING
<del>If you close the script and shutdown the container, you'll likely lose any keys you haven't backed up. Keep in mind that as transactions are made, you'll be creating new change addresses which, even if you backed up the original key, means you've now backed up nothing. Honestly, I'd only really send this bot ~1dfc until we improve the backup process.</del>
This should be persistent, but it is still a rudamentary droid with basic logic. Still better off just sending it a few dfc max, topping it off as needed.




# Simple Mode
## Build your droid and start it
> If you want to run multiple, you will need to change "defaultdroidname" in start.sh as each docker needs a unique name
```
git clone git@github.com:abstrct/docker-droid.git
cd docker-droid
./start.sh
```
## To restart your droid
```
#navigate to docker-droid
./start_droid.sh
```
> Refer to below for how to tweak your droid



# Manual Mode
> If you want to run multiple, you will need to change "defaultdroidname" as each docker needs a unique name
## How to Build
```
git clone git@github.com:abstrct/docker-droid.git
cd docker-droid
sudo docker volume create defaultdroidname
sudo docker build .
```

## How to Use this Image
### Quickstart
The following will run a crappy Coindroids bot that, by default, will constantly attack the weakest droid. Consider changing the logic with your own strategy.
> order.txt if you want it sorted in a way other than health_current.asc
> id_ignore.txt to not attack your other droids if you have multiple and dont want them to attack each other, ex: &id=neq.#### or &id=neq.####&id=neq.####
> other_filters.txt for other filters you want to apply


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
sudo docker exec -it droid /bin/bash
```
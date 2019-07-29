# docker-droid

Docker container for running a rough Coindroids bot
[Coindroids](https://coindroids.com/) for [Docker](https://www.docker.com).


# How to Build
```
git clone git@github.com:abstrct/docker-droid.git
cd docker-droid
docker build .
```

# How to Use this Image
## Quickstart
The following will run a crappy Coindroids bot that, by default, will constantly attack the weakest droid. Consider changing the logic with your own strategy.

This will run the docker in interactive mode (-it) but if you rather not watch the process then change this to daemon (-d). 

> Hint: You're going to want to run this as -it
```
sudo docker run -it --name=droid -e PLAYER_USERNAME="<Your Coindroids Username>" -e PLAYER_PASSWORD="<Your Coindroids Password>" <the build image identifier from the build step ex: > 
```

# Administration
Administering the bot is most easily done within the container. After starting the container you can perform the following to attach to its terminal:

```
docker ps
docker exec -it droid /bin/bash
```


# WARNING
If you close the script and shutdown the container, you'll likely lose any keys you haven't backed up. Keep in mind that as transactions are made, you'll be creating new change addresses which, even if you backed up the original key, means you've now backed up nothing. Honestly, I'd only really send this bot ~1dfc until we improve the backup process. 


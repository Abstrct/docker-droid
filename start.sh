container_name="`cat container_name.txt`"

sudo docker volume create ${container_name}

# If you want to access any of the files from the docker from the host, you can see where it is located by inspecting the volume
#sudo docker volume inspect defaultdroidname

sudo docker build .
./start_droid.sh
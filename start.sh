sudo docker volume create defaultdroidname

# If you want to access any of the files from the docker from the host, you can see where it is located by inspecting the volume
#sudo docker volume inspect defaultdroidname

sudo docker build .
./start_droid.sh
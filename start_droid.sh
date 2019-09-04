# There is probably a much shorter way to phrase this
read -p "Look above for 'Successfully built'. This is the build image identifier. Type it here (12 numbers and letters)" img_iden
# This way you have an easy way to get a copy of the image identifier in the future
echo ${img_iden} > /src/img_iden.txt

read -p 'Coindroids Username' cd_user
read -sp 'Coindroids Password' cd_pass
sudo docker run -it --mount source=defaultdroidname,target=/src --name=defaultdroidname -e PLAYER_USERNAME=${cd_user} -e PLAYER_PASSWORD=${cd_pass} ${img_iden}




# If you would rather your login creds be saved, you can enter them below and comment out everything up top
#sudo docker run -it --mount source=defaultdroidname,target=/src --name=defaultdroidname -e PLAYER_USERNAME="<Your Coindroids Username>" -e PLAYER_PASSWORD="<Your Coindroids Password>" <the build image identifier from the build step >
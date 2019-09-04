if [ -f "img_iden.txt" ]; then
	# Restarting droid, so should have identifier saved
	img_iden="`cat img_iden.txt`"
else
	# First time so human must retype (or copy paste) string
	# There is probably a much shorter way to phrase this
	read -p "Look above for 'Successfully built'. This is the build image identifier. Type it here (12 numbers and letters):  " img_iden
	# This way you have an easy way to get a copy of the image identifier in the future
	echo ${img_iden} > img_iden.txt
fi

read -p 'Coindroids Username:  ' cd_user
read -sp 'Coindroids Password:  ' cd_pass
sudo docker run -it --mount source=defaultdroidname,target=/src --name=defaultdroidname -e PLAYER_USERNAME=${cd_user} -e PLAYER_PASSWORD=${cd_pass} ${img_iden}




# If you would rather your login creds be saved, you can enter them below (and the image identifier) and comment out everything up top
#sudo docker run -it --mount source=defaultdroidname,target=/src --name=defaultdroidname -e PLAYER_USERNAME="<Your Coindroids Username>" -e PLAYER_PASSWORD="<Your Coindroids Password>" <the build image identifier from the build step >
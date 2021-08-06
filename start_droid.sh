container_name="`cat container_name.txt`"

if [ ! -f "first_run_done.txt" ]; then
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
	# If you would rather not have to type the Coindroids cred in, you can hardcode them in below ("user" and "pass" as they need to be in quotes)
	sudo docker run -it --mount source=${container_name},target=/src --name=${container_name} -e PLAYER_USERNAME=${cd_user} -e PLAYER_PASSWORD=${cd_pass} ${img_iden}
	echo "run done, should be able to just restart now" > first_run_done.txt
else
	sudo docker restart ${container_name}
	# Comment out the following line if you want it to run in the background
	sudo docker exec -it ${container_name} tail -f /src/droid/logs.txt
fi
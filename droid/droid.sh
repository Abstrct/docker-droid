#!/bin/sh

# droid.sh
# Totes stolen from DETH-MASHENE, thnx robo-bro

echo 'Droid started but waiting while defcoind boots' >> /src/droid/logs.txt
sleep 15s
# This line might need to be updated as the new average should be lower with it not indexing everything
# might mean removing all the "takes long time, looks like going backwards stuff"


deposit_address=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getaddressesbyaccount "" | jq -r '.[0]'`
while [ ${deposit_address} -le 5 ]
do
	sleep 15s
	deposit_address=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getaddressesbyaccount "" | jq -r '.[0]'`
done


#-> now print something like 
echo ""  >> /src/droid/logs.txt
echo "While defcoind is syncing, you can go ahead and load funds into it if you have not already (or know it is empty). Send funds to ${deposit_address}. if you would rather wait for sync to finish, this will check the balance of this wallet after it has finished. If there is not a useable balance, it will ask for funds to be sent and wait for them (do not worry about forgetting the addr as it will be printed again)." >> /src/droid/logs.txt
echo ""  >> /src/droid/logs.txt
#-> this is more useful for when importing the bootstrap.dat as that takes a long time

#add a line or 2 of blank space (or maybe even -------/======= line) between items to make it not display as a giant blob of text and instead as "steps"
echo ""  >> /src/droid/logs.txt
echo "##########################################"  >> /src/droid/logs.txt
echo ""  >> /src/droid/logs.txt



# Check to see if the wallet is finally sync'd
###############################################################
# prob need a diff print out for when not importing bootstrap but just catching up
###############################################################
echo 'Defcoind started with a snapshot, so it will sync a lot faster than normal but still might take 30-60min' >> /src/droid/logs.txt
progress=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getblockchaininfo | jq -r '.verificationprogress'`
progress=`awk "BEGIN { print ${progress} + 0.01 }"`
echo 'Checking on wallet status, must be up to date before starting bot' >> /src/droid/logs.txt
echo "Current Defcoin Sync progress: ${progress}" >> /src/droid/logs.txt
while (( $(echo "${progress} < 0.98" | bc -l ) ))
do
	progress=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getblockchaininfo | jq -r '.verificationprogress'`
	progress=`awk "BEGIN { print ${progress} + 0.01 }"`
	echo "Sync Progress: ${progress} (This takes a long time and may even look like it's going backwards)" >> /src/droid/logs.txt
	sleep 1m
done
echo 'Sync complete' >> /src/droid/logs.txt

# If conf is seet to txindex=1, needs to be sed out after import or it will take a long time every time it is restarted
#sed '/txindex=1/ s/^/#/' /src/droid/client/data/defcoin.conf

echo ""  >> /src/droid/logs.txt
echo "##########################################"  >> /src/droid/logs.txt
echo ""  >> /src/droid/logs.txt



# Check to see if there is a usable balance
balance=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getbalance`
###deposit_address=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getaddressesbyaccount "" | jq -r '.[0]'`
echo 'Checking on wallet status, balance needed before starting bot' >> /src/droid/logs.txt
while (( $(echo "${balance} == 0.0" | bc -l ) ))
do
	balance=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getbalance`
	echo "waiting for deposit to ${deposit_address}" >> /src/droid/logs.txt
	sleep 1m
done
echo "Wallet now has a balance of ${balance}, battle can begin..." >> /src/droid/logs.txt

echo ""  >> /src/droid/logs.txt
echo "##########################################"  >> /src/droid/logs.txt
echo ""  >> /src/droid/logs.txt


# Doing something super insecure and just telling you the wallet priv key
TEMP_KEY=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf dumpprivkey "${deposit_address}"`
echo "Wallet private key is ${TEMP_KEY}" >> /src/droid/logs.txt
echo 'Maybe write that down or something...' >> /src/droid/logs.txt
TEMP_KEY="null" #if there is access to this, they have access to the log file...but "shouldn't" we null out the variable?

echo ""  >> /src/droid/logs.txt
echo "##########################################"  >> /src/droid/logs.txt
echo ""  >> /src/droid/logs.txt


# Initiating Droid Session
echo 'Attempting to get new session token' >> /src/droid/logs.txt
CD_TOKEN=`curl -sS -X "POST" "https://api.coindroids.com/rpc/identify" -H 'Content-Type: application/json; charset=utf-8' --data "{\"username\": \"${PLAYER_USERNAME}\",\"password\":\"${PLAYER_PASSWORD}\" }" | jq -r '.[0].token'`
while [ "$CD_TOKEN" = "null" ]
do
  CD_TOKEN=`curl -sS -X "POST" "https://api.coindroids.com/rpc/identify" -H 'Content-Type: application/json; charset=utf-8' --data "{\"username\": \"${PLAYER_USERNAME}\",\"password\":\"${PLAYER_PASSWORD}\" }" | jq -r '.[0].token'`
done
echo "${CD_TOKEN}"

echo 'Finding Defcoin droid for player' >> /src/droid/logs.txt
DROID_ID=`curl -sS "https://api.coindroids.com/droid?currency_id=eq.2&select=id&username%20=eq.${PLAYER_USERNAME}" | jq -r '.[0].id'`
while [ "$DROID_ID" = "null" ]
do
  DROID_ID=`curl -sS "https://api.coindroids.com/droid?currency_id=eq.2&select=id&username%20=eq.${PLAYER_USERNAME}" | jq -r '.[0].id'`
done
echo "Found Droid ID #${DROID_ID}" >> /src/droid/logs.txt

echo ""  >> /src/droid/logs.txt
echo "##########################################"  >> /src/droid/logs.txt
echo ""  >> /src/droid/logs.txt


# Sync wallet to droid
if [ ! -f "/src/droid/droid_synced.txt" ]; then
	SYNC_ADDRESS=`curl -sS -X "POST" "https://api.coindroids.com/rpc/get_droid_registration_address"  -H "Authorization: Bearer ${CD_TOKEN}" -H 'Content-Type: application/json; charset=utf-8' --data "{ \"droid_id\": \"${DROID_ID}\"}"  | jq -r '.[0].get_droid_registration_address'`
	while [ "$SYNC_ADDRESS" = "null" ]
	do
	  SYNC_ADDRESS=`curl -sS -X "POST" "https://api.coindroids.com/rpc/get_droid_registration_address"  -H "Authorization: Bearer ${CD_TOKEN}" -H 'Content-Type: application/json; charset=utf-8' --data "{ \"droid_id\": \"${DROID_ID}\"}"  | jq -r '.[0].get_droid_registration_address'`
	done
	/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf sendtoaddress $SYNC_ADDRESS 0.01
	echo "Sent Sync tx to ${SYNC_ADDRESS}" >> /src/droid/logs.txt
	echo "Droid ID #${DROID_ID} is synced" > /src/droid/droid_synced.txt
fi

echo ""  >> /src/droid/logs.txt
echo "##########################################"  >> /src/droid/logs.txt
echo ""  >> /src/droid/logs.txt


# INIT
OGBLOCK=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getblockcount`


##################################
# get filters from text files
##################################

ORDER="`cat /src/droid/order.txt`"
if [ "$ORDER" = "null" ]; then
	ORDER="health_current.asc"
fi

ID_IGNORE="`cat /src/droid/id_ignore.txt`"

OTHER_FILTERS="`cat /src/droid/other_filters.txt`"

while [ 1 ]
do
	# is it a new block?
	NEWBLOCK=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getblockcount`

	if [ $OGBLOCK != $NEWBLOCK ]; then
		# find my target
		TARGET=`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?select=name,id,attack_address&order=${ORDER}&health_current=gt.0&is_active=eq.true&currency_id=eq.2&id=neq.${DROID_ID}${ID_IGNORE}${OTHER_FILTERS}" | jq ".[] | .attack_address" | tr -d '"'`
		echo Target Address: $TARGET >> /src/droid/logs.txt

		echo =`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?select=name,id,attack_address&order=${ORDER}&health_current=gt.0&is_active=eq.true&currency_id=eq.2&id=neq.${DROID_ID}${ID_IGNORE}${OTHER_FILTERS}"`

		# who is this anyways
		NAME=`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?attack_address=eq."$TARGET"&select=name" | jq ".[] | .name" | tr -d '"'`

		# find my clip size
		CLIPSIZE=`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?id=eq.${DROID_ID}&select=attribute.clip_size" | jq ".[] | .[] | .clip_size"`
		echo Clip Size: $CLIPSIZE >> /src/droid/logs.txt

		# shoot the target
		echo FIRING AT $NAME !!! $CLIPSIZE at $TARGET >> /src/droid/logs.txt
		/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf sendtoaddress $TARGET 0.0$CLIPSIZE

	fi

	OGBLOCK=$NEWBLOCK
	echo sleepin\'
	sleep 1m

	balance=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getbalance`
	while (( $(echo "${balance} == 0.0" | bc -l ) ))
	do
		balance=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getbalance`
		echo "Funds too low. Waiting for deposit to ${deposit_address}" >> /src/droid/logs.txt
		sleep 1m
	done
	echo "Wallet balance of ${balance}" >> /src/droid/logs.txt

done

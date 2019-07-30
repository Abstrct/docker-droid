#!/bin/sh

# droid.sh
# Totes stolen from DETH-MASHENE, thnx robo-bro

echo 'Droid started but waiting while defcoind boots' >> /src/droid/logs.txt
echo 'Defcoind started with a snapshot, so it will sync a lot faster than normal but still might take 30-60min' >> /src/droid/logs.txt 


# Check to see if the wallet is finally sync'd
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



# Check to see if there is a usable balance 
balance=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getbalance`
deposit_address=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getaddressesbyaccount "" | jq -r '.[]'`
echo 'Checking on wallet status, balance needed before starting bot' >> /src/droid/logs.txt
while (( $(echo "${balance} == 0.0" | bc -l ) ))
do
    balance=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getbalance`
    echo "waiting for deposit to ${deposit_address}" >> /src/droid/logs.txt
    sleep 1m
done
echo "Wallet now has a balance of ${balance}, battle can begin..." >> /src/droid/logs.txt


# Doing something super insecure and just telling you the wallet priv key
TEMP_KEY=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf dumpprivkey "${deposit_address}"`
echo "Wallet private key is ${TEMP_KEY}" >> /src/droid/logs.txt
echo 'Maybe write that down or something...' >> /src/droid/logs.txt



# Initiating Droid Session
echo 'Attempting to get new session token' >> /src/droid/logs.txt
while [ -z "$CD_TOKEN" ]
do
  CD_TOKEN=`curl -sS -X "POST" "https://api.coindroids.com/rpc/identify" -H 'Content-Type: application/json; charset=utf-8' --data "{\"username\": \"${PLAYER_USERNAME}\",\"password\":\"${PLAYER_PASSWORD}\" }" | jq -r '.[0].token'`
done
echo "${CD_TOKEN}"

echo 'Finding Defcoin droid for player' >> /src/droid/logs.txt
while [ -z "$DROID_ID" ]
do
  DROID_ID=`curl -sS "https://api.coindroids.com/droid?currency_id=eq.2&select=id&username%20=eq.${PLAYER_USERNAME}" | jq -r '.[0].id'`
done
echo "Found Droid ID #${DROID_ID}" >> /src/droid/logs.txt

# Sync wallet to droid
while [ -z "$SYNC_ADDRESS" ]
do
  SYNC_ADDRESS=`curl -sS -X "POST" "https://api.coindroids.com/rpc/get_droid_registration_address"  -H "Authorization: Bearer ${CD_TOKEN}" -H 'Content-Type: application/json; charset=utf-8' --data "{ \"droid_id\": \"${DROID_ID}\"}"  | jq -r '.[0].get_droid_registration_address'`
done
/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf sendtoaddress $SYNC_ADDRESS 0.01
echo "Sent Sync tx to ${SYNC_ADDRESS}" >> /src/droid/logs.txt


# INIT
OGBLOCK=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getblockcount`

while [ 1 ]
do
	# is it a new block?
	NEWBLOCK=`/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf getblockcount`

	if [ $OGBLOCK != $NEWBLOCK ]; then
		# find my target
		TARGET=`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?select=name,id,attack_address&order=bounty.desc&health_current=gt.0&currency_id=eq.2&id=neq.${DROID_ID}" | jq ".[] | .attack_address" | tr -d '"'`
		echo Target Address: $TARGET

		echo =`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?select=name,id,attack_address&order=health_current.asc&health_current=gt.0&currency_id=eq.2&id=neq.${DROID_ID}"`

		# who is this anyways
		NAME=`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?attack_address=eq."$TARGET"&select=name" | jq ".[] | .name" | tr -d '"'`

		# find my clip size
		CLIPSIZE=`curl -s -H "Range: 0-0" -X "GET" "https://api.coindroids.com/droid?id=eq.${DROID_ID}&select=attribute.clip_size" | jq ".[] | .[] | .clip_size"`
		echo Clip Size: $CLIPSIZE

		# shoot the target
		echo FIRING AT $NAME !!! $CLIPSIZE at $TARGET
		/src/droid/client/bin/defcoin-cli -conf=/src/droid/client/data/defcoin.conf sendtoaddress $TARGET 0.0$CLIPSIZE

	fi

	OGBLOCK=$NEWBLOCK
	echo sleepin\'
	sleep 10m
done

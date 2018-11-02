#! /bin/sh
#
# prepare.sh
# Copyright (C) 2018 lijiaocn <lijiaocn@foxmail.com>
#
# Distributed under terms of the GPL license.
#

CHANNEL_NAME="mychannel"
BIN_PATH=`pwd`"/output/bin"
DOWNLOAD_PATH=`pwd`"/output"
ORG_NAME="freeexchange.cn"

function generateCerts (){
  config=$1
  output=$2
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"
  if [ -d "$output" ]; then
    rm -Rf $output
  fi
  $BIN_PATH/cryptogen generate --config=$config --output=$output
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}

function generateChannelArtifacts() {
  workdir=$1
  output=$2
  pushd $workdir
  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  $BIN_PATH/configtxgen -profile OrdererGenesis -outputBlock $output/genesisblock  -channelID genesis 
  
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  $BIN_PATH/configtxgen -profile Channel -outputCreateChannelTx $output/channel.tx -channelID $CHANNEL_NAME
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for org1.freeexchange.cn  ##########"
  echo "#################################################################"
  $BIN_PATH/configtxgen -profile Channel -outputAnchorPeersUpdate $output/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg org1.freeexchange.cn
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for org1.freeexchange.cn..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for org2.freeexchange.cn   ##########"
  echo "#################################################################"
  $BIN_PATH/configtxgen -profile Channel -outputAnchorPeersUpdate $output/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg org2.freeexchange.cn

    if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for org2.freeexchange.cn..."
    exit 1
  fi
  echo
  popd
}

if [ ! -d $BIN_PATH ];then
	set -x
	download=`pwd`/download.sh
	mkdir -p $BIN_PATH
	pushd $DOWNLOAD_PATH
		bash $download 
	popd
	set +x
fi

case $1 in
	$ORG_NAME)
	generateCerts `pwd`/inventories/$ORG_NAME/crypto-config.yaml `pwd`/output/$ORG_NAME/crypto-config
	if [ ! -d  `pwd`/output/$ORG_NAME/channel-artifacts ];then
		mkdir -p  `pwd`/output/$ORG_NAME/channel-artifacts
	fi
	generateChannelArtifacts `pwd`/inventories/$ORG_NAME/ `pwd`/output/$ORG_NAME/channel-artifacts
	;;
	* )
	echo "usage: $0 $ORG_NAME"
	;;
esac

#!/bin/bash

# USAGE:
# clone ds-group and run `dapp build`
# export ETH_ACCOUNT=0xYOUR_ADDRESS_HERE
# update the member address and quorum count
# !!! call from ds-group repo

SETH_CHAIN=rinkeby \
ETH_KEYSTORE=$HOME/Library/Ethereum/keystore \
ETH_FROM=$ETH_ACCOUNT \
ETH_GAS=2000000 \
ETH_GAS_PRICE=$(seth --to-wei 2 gwei) \
    dapp create DSGroup \
    '[ e092b1fa25df5786d151246e492eed3d15ea4daa, c0d8f541ab8b71f20c10261818f2f401e8194049 ]' \
    2 86400

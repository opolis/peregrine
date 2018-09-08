#!/bin/bash

# USAGE:
# clone ds-group and run `dapp build`
# create a .env in root folder of package
# .env should look like:

# export ETH_ACCOUNT=0xYOUR_ADDRESS_HERE
# export ETH_KEYSTORE=~/secrets/ethereum
# export ETH_PASSWORD=~/secrets/ethereum/216f-password

# update the member address and quorum count
# !!! call from ds-group repo

source .env

# amy = 0xA7146b507aD43a0Ab0531E4b4c2567352BA57923
# coury = 0x0152c6eeeaae52Dca7AC07e69433a9fc9390329B
# nick = 0x41D9A79694006a9C657AFB8480148afC7bf105dB
# wes = 0xBDff7f485b45F6d5546C14A00bcf3C11BF322a09

SETH_CHAIN=rinkeby \
ETH_FROM=$ETH_ACCOUNT \
ETH_GAS=2000000 \
ETH_GAS_PRICE=$(seth --to-wei 3 gwei) \
    dapp create DSGroup \
    '[ A7146b507aD43a0Ab0531E4b4c2567352BA57923, 0152c6eeeaae52Dca7AC07e69433a9fc9390329B, 41D9A79694006a9C657AFB8480148afC7bf105dB, BDff7f485b45F6d5546C14A00bcf3C11BF322a09 ]' \
    3 156400

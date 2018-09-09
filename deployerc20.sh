
source .env

#Tons of tokens
export TOKEN_SUPPLY=$(seth --to-uint256 $(seth --to-wei 100000000 ether))
export SETH_CHAIN=rinkeby
export ETH_FROM=$ETH_ACCOUNT
export ETH_GAS=2000000
export ETH_GAS_PRICE=$(seth --to-wei 3 gwei)

# Deploy ERC Token Contract (DAI Simulator)
echo "Deploying ERC20..."
TOKEN_CONTRACT=$(dapp create DSTokenBase $TOKEN_SUPPLY)
echo ""
# Transfer Coins to SmartOp
echo "Transfering ERC20 to Multisig"
seth send $TOKEN_CONTRACT "transfer(address,uint)" $MULTISIG_CONTRACT $TOKEN_SUPPLY
echo ""

echo "Token Contract: $TOKEN_CONTRACT"


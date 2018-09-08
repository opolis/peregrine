# It seems you must clone ds-group and run this within the context of that directory for it to work.
# After cloning it, run `make link` to get ds-group cli.

SETH_CHAIN=rinkeby \
ETH_GAS=2000000 \
ETH_GAS_PRICE=$(seth --to-wei 3 gwei) \
ETH_GROUP_CONTRACT=0x8a6c28475af5b9fd6a2f53170602fd37318a1321 \
ETH_FROM=0x0152c6eeeaae52Dca7AC07e69433a9fc9390329B \
    ds-group propose $ETH_GROUP_CONTRACT \
        0x8a6c28475af5b9fd6a2f53170602fd37318a1321 \
        $(seth --to-uint256 $(seth --to-wei 0.1 eth)) \
        0x00000000000000000000000000000000 # <--- CALLDATA must be a multiple of 2
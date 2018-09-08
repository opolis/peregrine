module Contract.ERC20
    exposing
        ( Approval
        , Transfer
        , allowance
        , approvalDecoder
        , approvalEvent
        , approve
        , balanceOf
        , totalSupply
        , transfer
        , transferDecoder
        , transferEvent
        , transferFrom
        )

import Abi.Decode as AbiDecode exposing (abiDecode, andMap, data, toElmDecoder, topic)
import Abi.Encode as AbiEncode exposing (Encoding(..), abiEncode)
import BigInt exposing (BigInt)
import Eth.Types exposing (..)
import Eth.Utils as U
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, decode)


{-
   This file was generated by https://github.com/cmditch/elm-ethereum-generator
-}


{-| "allowance(address,address)" function
-}
allowance : Address -> Address -> Address -> Call BigInt
allowance contractAddress src guy =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "allowance(address,address)" [ AbiEncode.address src, AbiEncode.address guy ]
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.uint
    }


{-| "approve(address,uint256)" function
-}
approve : Address -> Address -> BigInt -> Call Bool
approve contractAddress guy wad =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "approve(address,uint256)" [ AbiEncode.address guy, AbiEncode.uint wad ]
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.bool
    }


{-| "balanceOf(address)" function
-}
balanceOf : Address -> Address -> Call BigInt
balanceOf contractAddress guy =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "balanceOf(address)" [ AbiEncode.address guy ]
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.uint
    }


{-| "totalSupply()" function
-}
totalSupply : Address -> Call BigInt
totalSupply contractAddress =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "totalSupply()" []
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.uint
    }


{-| "transfer(address,uint256)" function
-}
transfer : Address -> Address -> BigInt -> Call Bool
transfer contractAddress dst wad =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "transfer(address,uint256)" [ AbiEncode.address dst, AbiEncode.uint wad ]
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.bool
    }


{-| "transferFrom(address,address,uint256)" function
-}
transferFrom : Address -> Address -> Address -> BigInt -> Call Bool
transferFrom contractAddress src dst wad =
    { to = Just contractAddress
    , from = Nothing
    , gas = Nothing
    , gasPrice = Nothing
    , value = Nothing
    , data = Just <| AbiEncode.functionCall "transferFrom(address,address,uint256)" [ AbiEncode.address src, AbiEncode.address dst, AbiEncode.uint wad ]
    , nonce = Nothing
    , decoder = toElmDecoder AbiDecode.bool
    }


{-| "Approval(address,address,uint256)" event
-}
type alias Approval =
    { src : Address
    , guy : Address
    , wad : BigInt
    }


approvalEvent : Address -> Maybe Address -> Maybe Address -> LogFilter
approvalEvent contractAddress src guy =
    { fromBlock = LatestBlock
    , toBlock = LatestBlock
    , address = contractAddress
    , topics =
        [ Just <| U.keccak256 "Approval(address,address,uint256)"
        , Maybe.map (abiEncode << AbiEncode.address) src
        , Maybe.map (abiEncode << AbiEncode.address) guy
        ]
    }


approvalDecoder : Decoder Approval
approvalDecoder =
    decode Approval
        |> custom (topic 1 AbiDecode.address)
        |> custom (topic 2 AbiDecode.address)
        |> custom (data 0 AbiDecode.uint)


{-| "Transfer(address,address,uint256)" event
-}
type alias Transfer =
    { src : Address
    , dst : Address
    , wad : BigInt
    }


transferEvent : Address -> Maybe Address -> Maybe Address -> LogFilter
transferEvent contractAddress src dst =
    { fromBlock = LatestBlock
    , toBlock = LatestBlock
    , address = contractAddress
    , topics =
        [ Just <| U.keccak256 "Transfer(address,address,uint256)"
        , Maybe.map (abiEncode << AbiEncode.address) src
        , Maybe.map (abiEncode << AbiEncode.address) dst
        ]
    }


transferDecoder : Decoder Transfer
transferDecoder =
    decode Transfer
        |> custom (topic 1 AbiDecode.address)
        |> custom (topic 2 AbiDecode.address)
        |> custom (data 0 AbiDecode.uint)
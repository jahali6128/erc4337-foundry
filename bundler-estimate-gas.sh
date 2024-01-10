#!/bin/bash


curl --request POST \
     --url http://127.0.0.1:4337 \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "id": 1,
  "jsonrpc": "2.0",
  "method": "eth_estimateUserOperationGas",
  "params": [
    {
      "sender": "0x7504953e83d83fa54353d9dabcbf0068b2dac45a",
      "nonce": "0x0",
      "initCode": "0x",
      "callData": "0xb61d27f6000000000000000000000000cf7ed3acca5a467e9e704c703e8d87f634fb0fc9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000064a413686200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000006576f726c6421000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      "callGasLimit": "0x88b8",
      "verificationGasLimit": "0x011170",
      "preVerificationGas": "0x5208",
      "maxFeePerGas": 0,
      "maxPriorityFeePerGas": 0,
      "signature": "0xfffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c",
      "paymasterAndData": "0x"
    },
    "0x5FbDB2315678afecb367f032d93F642f64180aa3" 
  ]
}
'

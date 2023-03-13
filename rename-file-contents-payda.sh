#!/bin/sh
find ./ -type f -readable -writable -exec sed -i "s/bitcoin/paydacoin/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/Bitcoin/Paydacoin/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/BitCoin/PaydaCoin/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/BITCOIN/PAYDACOIN/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/bitcoind/paydacoind/g" {} ";"

find ./ -type f -readable -writable -exec sed -i "s/BTC/PDC/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/btc/pdc/g" {} ";"

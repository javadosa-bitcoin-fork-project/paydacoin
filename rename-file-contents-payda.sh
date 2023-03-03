#!/bin/sh
find ./ -type f -readable -writable -exec sed -i "s/paydacoin/paydacoin/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/Paydacoin/Paydacoin/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/PaydaCoin/PaydaCoin/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/PAYDACOIN/PAYDACOIN/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/paydacoind/paydacoind/g" {} ";"

find ./ -type f -readable -writable -exec sed -i "s/PDC/PDC/g" {} ";"
find ./ -type f -readable -writable -exec sed -i "s/pdc/pdc/g" {} ";"

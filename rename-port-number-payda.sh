#!/bin/sh

#Main Net
#P2P Port
find ./ -type f -readable -writable -exec sed -i "s/8333/7333/g" {} ";"
#RPC Port
find ./ -type f -readable -writable -exec sed -i "s/8332/7332/g" {} ";"

#Test Net
#P2P Port
find ./ -type f -readable -writable -exec sed -i "s/18333/17333/g" {} ";"
#RPC Port
find ./ -type f -readable -writable -exec sed -i "s/18332/17332/g" {} ";"

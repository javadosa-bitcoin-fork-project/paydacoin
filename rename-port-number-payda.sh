#Main Net
#P2P Port
find ./ -type f -readable -writable -exec sed -i "s/7333/7333/g" {} ";"
#RPC Port
find ./ -type f -readable -writable -exec sed -i "s/7332/7332/g" {} ";"

#Test Net
#P2P Port
find ./ -type f -readable -writable -exec sed -i "s/17333/17333/g" {} ";"
#RPC Port
find ./ -type f -readable -writable -exec sed -i "s/17332/17332/g" {} ";"

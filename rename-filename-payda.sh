#!/bin/sh
find . -exec rename 's/bitcoin/paydacoin/' {} ";"
find . -exec rename 's/btc/pdc/' {} ";"

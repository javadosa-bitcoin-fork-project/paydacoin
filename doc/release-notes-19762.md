JSON-RPC
---

All JSON-RPC methods accept a new [named
parameter](JSON-RPC-interface.md#parameter-passing) called `args` that can
contain positional parameter values. This is a convenience to allow some
parameter values to be passed by name without having to name every value. The
python test framework and `paydacoin-cli` tool both take advantage of this, so
for example:

```sh
paydacoin-cli -named createwallet wallet_name=mywallet load_on_startup=1
```

Can now be shortened to:

```sh
paydacoin-cli -named createwallet mywallet load_on_startup=1
```

Shared Libraries
================

## paydacoinconsensus

The purpose of this library is to make the verification functionality that is critical to Paydacoin's consensus available to other applications, e.g. to language bindings.

### API

The interface is defined in the C header `paydacoinconsensus.h` located in `src/script/paydacoinconsensus.h`.

#### Version

`paydacoinconsensus_version` returns an `unsigned int` with the API version *(currently `1`)*.

#### Script Validation

`paydacoinconsensus_verify_script` returns an `int` with the status of the verification. It will be `1` if the input script correctly spends the previous output `scriptPubKey`.

##### Parameters
- `const unsigned char *scriptPubKey` - The previous output script that encumbers spending.
- `unsigned int scriptPubKeyLen` - The number of bytes for the `scriptPubKey`.
- `const unsigned char *txTo` - The transaction with the input that is spending the previous output.
- `unsigned int txToLen` - The number of bytes for the `txTo`.
- `unsigned int nIn` - The index of the input in `txTo` that spends the `scriptPubKey`.
- `unsigned int flags` - The script validation flags *(see below)*.
- `paydacoinconsensus_error* err` - Will have the error/success code for the operation *(see below)*.

##### Script Flags
- `paydacoinconsensus_SCRIPT_FLAGS_VERIFY_NONE`
- `paydacoinconsensus_SCRIPT_FLAGS_VERIFY_P2SH` - Evaluate P2SH ([BIP16](https://github.com/paydacoin/bips/blob/master/bip-0016.mediawiki)) subscripts
- `paydacoinconsensus_SCRIPT_FLAGS_VERIFY_DERSIG` - Enforce strict DER ([BIP66](https://github.com/paydacoin/bips/blob/master/bip-0066.mediawiki)) compliance
- `paydacoinconsensus_SCRIPT_FLAGS_VERIFY_NULLDUMMY` - Enforce NULLDUMMY ([BIP147](https://github.com/paydacoin/bips/blob/master/bip-0147.mediawiki))
- `paydacoinconsensus_SCRIPT_FLAGS_VERIFY_CHECKLOCKTIMEVERIFY` - Enable CHECKLOCKTIMEVERIFY ([BIP65](https://github.com/paydacoin/bips/blob/master/bip-0065.mediawiki))
- `paydacoinconsensus_SCRIPT_FLAGS_VERIFY_CHECKSEQUENCEVERIFY` - Enable CHECKSEQUENCEVERIFY ([BIP112](https://github.com/paydacoin/bips/blob/master/bip-0112.mediawiki))
- `paydacoinconsensus_SCRIPT_FLAGS_VERIFY_WITNESS` - Enable WITNESS ([BIP141](https://github.com/paydacoin/bips/blob/master/bip-0141.mediawiki))

##### Errors
- `paydacoinconsensus_ERR_OK` - No errors with input parameters *(see the return value of `paydacoinconsensus_verify_script` for the verification status)*
- `paydacoinconsensus_ERR_TX_INDEX` - An invalid index for `txTo`
- `paydacoinconsensus_ERR_TX_SIZE_MISMATCH` - `txToLen` did not match with the size of `txTo`
- `paydacoinconsensus_ERR_DESERIALIZE` - An error deserializing `txTo`
- `paydacoinconsensus_ERR_AMOUNT_REQUIRED` - Input amount is required if WITNESS is used
- `paydacoinconsensus_ERR_INVALID_FLAGS` - Script verification `flags` are invalid (i.e. not part of the libconsensus interface)

### Example Implementations
- [NPaydacoin](https://github.com/MetacoSA/NPaydacoin/blob/5e1055cd7c4186dee4227c344af8892aea54faec/NPaydacoin/Script.cs#L979-#L1031) (.NET Bindings)
- [node-libpaydacoinconsensus](https://github.com/bitpay/node-libpaydacoinconsensus) (Node.js Bindings)
- [java-libpaydacoinconsensus](https://github.com/dexX7/java-libpaydacoinconsensus) (Java Bindings)
- [paydacoinconsensus-php](https://github.com/Bit-Wasp/paydacoinconsensus-php) (PHP Bindings)

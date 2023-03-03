# Libraries

| Name                     | Description |
|--------------------------|-------------|
| *libpaydacoin_cli*         | RPC client functionality used by *paydacoin-cli* executable |
| *libpaydacoin_common*      | Home for common functionality shared by different executables and libraries. Similar to *libpaydacoin_util*, but higher-level (see [Dependencies](#dependencies)). |
| *libpaydacoin_consensus*   | Stable, backwards-compatible consensus functionality used by *libpaydacoin_node* and *libpaydacoin_wallet* and also exposed as a [shared library](../shared-libraries.md). |
| *libpaydacoinconsensus*    | Shared library build of static *libpaydacoin_consensus* library |
| *libpaydacoin_kernel*      | Consensus engine and support library used for validation by *libpaydacoin_node* and also exposed as a [shared library](../shared-libraries.md). |
| *libpaydacoinqt*           | GUI functionality used by *paydacoin-qt* and *paydacoin-gui* executables |
| *libpaydacoin_ipc*         | IPC functionality used by *paydacoin-node*, *paydacoin-wallet*, *paydacoin-gui* executables to communicate when [`--enable-multiprocess`](multiprocess.md) is used. |
| *libpaydacoin_node*        | P2P and RPC server functionality used by *paydacoind* and *paydacoin-qt* executables. |
| *libpaydacoin_util*        | Home for common functionality shared by different executables and libraries. Similar to *libpaydacoin_common*, but lower-level (see [Dependencies](#dependencies)). |
| *libpaydacoin_wallet*      | Wallet functionality used by *paydacoind* and *paydacoin-wallet* executables. |
| *libpaydacoin_wallet_tool* | Lower-level wallet functionality used by *paydacoin-wallet* executable. |
| *libpaydacoin_zmq*         | [ZeroMQ](../zmq.md) functionality used by *paydacoind* and *paydacoin-qt* executables. |

## Conventions

- Most libraries are internal libraries and have APIs which are completely unstable! There are few or no restrictions on backwards compatibility or rules about external dependencies. Exceptions are *libpaydacoin_consensus* and *libpaydacoin_kernel* which have external interfaces documented at [../shared-libraries.md](../shared-libraries.md).

- Generally each library should have a corresponding source directory and namespace. Source code organization is a work in progress, so it is true that some namespaces are applied inconsistently, and if you look at [`libpaydacoin_*_SOURCES`](../../src/Makefile.am) lists you can see that many libraries pull in files from outside their source directory. But when working with libraries, it is good to follow a consistent pattern like:

  - *libpaydacoin_node* code lives in `src/node/` in the `node::` namespace
  - *libpaydacoin_wallet* code lives in `src/wallet/` in the `wallet::` namespace
  - *libpaydacoin_ipc* code lives in `src/ipc/` in the `ipc::` namespace
  - *libpaydacoin_util* code lives in `src/util/` in the `util::` namespace
  - *libpaydacoin_consensus* code lives in `src/consensus/` in the `Consensus::` namespace

## Dependencies

- Libraries should minimize what other libraries they depend on, and only reference symbols following the arrows shown in the dependency graph below:

<table><tr><td>

```mermaid

%%{ init : { "flowchart" : { "curve" : "basis" }}}%%

graph TD;

paydacoin-cli[paydacoin-cli]-->libpaydacoin_cli;

paydacoind[paydacoind]-->libpaydacoin_node;
paydacoind[paydacoind]-->libpaydacoin_wallet;

paydacoin-qt[paydacoin-qt]-->libpaydacoin_node;
paydacoin-qt[paydacoin-qt]-->libpaydacoinqt;
paydacoin-qt[paydacoin-qt]-->libpaydacoin_wallet;

paydacoin-wallet[paydacoin-wallet]-->libpaydacoin_wallet;
paydacoin-wallet[paydacoin-wallet]-->libpaydacoin_wallet_tool;

libpaydacoin_cli-->libpaydacoin_util;
libpaydacoin_cli-->libpaydacoin_common;

libpaydacoin_common-->libpaydacoin_consensus;
libpaydacoin_common-->libpaydacoin_util;

libpaydacoin_kernel-->libpaydacoin_consensus;
libpaydacoin_kernel-->libpaydacoin_util;

libpaydacoin_node-->libpaydacoin_consensus;
libpaydacoin_node-->libpaydacoin_kernel;
libpaydacoin_node-->libpaydacoin_common;
libpaydacoin_node-->libpaydacoin_util;

libpaydacoinqt-->libpaydacoin_common;
libpaydacoinqt-->libpaydacoin_util;

libpaydacoin_wallet-->libpaydacoin_common;
libpaydacoin_wallet-->libpaydacoin_util;

libpaydacoin_wallet_tool-->libpaydacoin_wallet;
libpaydacoin_wallet_tool-->libpaydacoin_util;

classDef bold stroke-width:2px, font-weight:bold, font-size: smaller;
class paydacoin-qt,paydacoind,paydacoin-cli,paydacoin-wallet bold
```
</td></tr><tr><td>

**Dependency graph**. Arrows show linker symbol dependencies. *Consensus* lib depends on nothing. *Util* lib is depended on by everything. *Kernel* lib depends only on consensus and util.

</td></tr></table>

- The graph shows what _linker symbols_ (functions and variables) from each library other libraries can call and reference directly, but it is not a call graph. For example, there is no arrow connecting *libpaydacoin_wallet* and *libpaydacoin_node* libraries, because these libraries are intended to be modular and not depend on each other's internal implementation details. But wallet code is still able to call node code indirectly through the `interfaces::Chain` abstract class in [`interfaces/chain.h`](../../src/interfaces/chain.h) and node code calls wallet code through the `interfaces::ChainClient` and `interfaces::Chain::Notifications` abstract classes in the same file. In general, defining abstract classes in [`src/interfaces/`](../../src/interfaces/) can be a convenient way of avoiding unwanted direct dependencies or circular dependencies between libraries.

- *libpaydacoin_consensus* should be a standalone dependency that any library can depend on, and it should not depend on any other libraries itself.

- *libpaydacoin_util* should also be a standalone dependency that any library can depend on, and it should not depend on other internal libraries.

- *libpaydacoin_common* should serve a similar function as *libpaydacoin_util* and be a place for miscellaneous code used by various daemon, GUI, and CLI applications and libraries to live. It should not depend on anything other than *libpaydacoin_util* and *libpaydacoin_consensus*. The boundary between _util_ and _common_ is a little fuzzy but historically _util_ has been used for more generic, lower-level things like parsing hex, and _common_ has been used for paydacoin-specific, higher-level things like parsing base58. The difference between util and common is mostly important because *libpaydacoin_kernel* is not supposed to depend on *libpaydacoin_common*, only *libpaydacoin_util*. In general, if it is ever unclear whether it is better to add code to *util* or *common*, it is probably better to add it to *common* unless it is very generically useful or useful particularly to include in the kernel.


- *libpaydacoin_kernel* should only depend on *libpaydacoin_util* and *libpaydacoin_consensus*.

- The only thing that should depend on *libpaydacoin_kernel* internally should be *libpaydacoin_node*. GUI and wallet libraries *libpaydacoinqt* and *libpaydacoin_wallet* in particular should not depend on *libpaydacoin_kernel* and the unneeded functionality it would pull in, like block validation. To the extent that GUI and wallet code need scripting and signing functionality, they should be get able it from *libpaydacoin_consensus*, *libpaydacoin_common*, and *libpaydacoin_util*, instead of *libpaydacoin_kernel*.

- GUI, node, and wallet code internal implementations should all be independent of each other, and the *libpaydacoinqt*, *libpaydacoin_node*, *libpaydacoin_wallet* libraries should never reference each other's symbols. They should only call each other through [`src/interfaces/`](`../../src/interfaces/`) abstract interfaces.

## Work in progress

- Validation code is moving from *libpaydacoin_node* to *libpaydacoin_kernel* as part of [The libpaydacoinkernel Project #24303](https://github.com/paydacoin/paydacoin/issues/24303)
- Source code organization is discussed in general in [Library source code organization #15732](https://github.com/paydacoin/paydacoin/issues/15732)

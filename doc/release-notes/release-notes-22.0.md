22.0 Release Notes
==================

Paydacoin Core version 22.0 is now available from:

  <https://paydacoincore.org/bin/paydacoin-core-22.0/>

This release includes new features, various bug fixes and performance
improvements, as well as updated translations.

Please report bugs using the issue tracker at GitHub:

  <https://github.com/paydacoin/paydacoin/issues>

To receive security and update notifications, please subscribe to:

  <https://paydacoincore.org/en/list/announcements/join/>

How to Upgrade
==============

If you are running an older version, shut it down. Wait until it has completely
shut down (which might take a few minutes in some cases), then run the
installer (on Windows) or just copy over `/Applications/Paydacoin-Qt` (on Mac)
or `paydacoind`/`paydacoin-qt` (on Linux).

Upgrading directly from a version of Paydacoin Core that has reached its EOL is
possible, but it might take some time if the data directory needs to be migrated. Old
wallet versions of Paydacoin Core are generally supported.

Compatibility
==============

Paydacoin Core is supported and extensively tested on operating systems
using the Linux kernel, macOS 10.14+, and Windows 7 and newer.  Paydacoin
Core should also work on most other Unix-like systems but is not as
frequently tested on them.  It is not recommended to use Paydacoin Core on
unsupported systems.

From Paydacoin Core 22.0 onwards, macOS versions earlier than 10.14 are no longer supported.

Notable changes
===============

P2P and network changes
-----------------------
- Added support for running Paydacoin Core as an
  [I2P (Invisible Internet Project)](https://en.wikipedia.org/wiki/I2P) service
  and connect to such services. See [i2p.md](https://github.com/paydacoin/paydacoin/blob/22.x/doc/i2p.md) for details. (#20685)
- This release removes support for Tor version 2 hidden services in favor of Tor
  v3 only, as the Tor network [dropped support for Tor
  v2](https://blog.torproject.org/v2-deprecation-timeline) with the release of
  Tor version 0.4.6.  Henceforth, Paydacoin Core ignores Tor v2 addresses; it
  neither rumors them over the network to other peers, nor stores them in memory
  or to `peers.dat`.  (#22050)

- Added NAT-PMP port mapping support via
  [`libnatpmp`](https://miniupnp.tuxfamily.org/libnatpmp.html). (#18077)

New and Updated RPCs
--------------------

- Due to [BIP 350](https://github.com/paydacoin/bips/blob/master/bip-0350.mediawiki)
  being implemented, behavior for all RPCs that accept addresses is changed when
  a native witness version 1 (or higher) is passed. These now require a Bech32m
  encoding instead of a Bech32 one, and Bech32m encoding will be used for such
  addresses in RPC output as well. No version 1 addresses should be created
  for mainnet until consensus rules are adopted that give them meaning
  (as will happen through [BIP 341](https://github.com/paydacoin/bips/blob/master/bip-0341.mediawiki)).
  Once that happens, Bech32m is expected to be used for them, so this shouldn't
  affect any production systems, but may be observed on other networks where such
  addresses already have meaning (like signet). (#20861)

- The `getpeerinfo` RPC returns two new boolean fields, `bip152_hb_to` and
  `bip152_hb_from`, that respectively indicate whether we selected a peer to be
  in compact blocks high-bandwidth mode or whether a peer selected us as a
  compact blocks high-bandwidth peer. High-bandwidth peers send new block
  announcements via a `cmpctblock` message rather than the usual inv/headers
  announcements. See BIP 152 for more details. (#19776)

- `getpeerinfo` no longer returns the following fields: `addnode`, `banscore`,
  and `whitelisted`, which were previously deprecated in 0.21. Instead of
  `addnode`, the `connection_type` field returns manual. Instead of
  `whitelisted`, the `permissions` field indicates if the peer has special
  privileges. The `banscore` field has simply been removed. (#20755)

- The following RPCs:  `gettxout`, `getrawtransaction`, `decoderawtransaction`,
  `decodescript`, `gettransaction`, and REST endpoints: `/rest/tx`,
  `/rest/getutxos`, `/rest/block` deprecated the following fields (which are no
  longer returned in the responses by default): `addresses`, `reqSigs`.
  The `-deprecatedrpc=addresses` flag must be passed for these fields to be
  included in the RPC response. This flag/option will be available only for this major release, after which
  the deprecation will be removed entirely. Note that these fields are attributes of
  the `scriptPubKey` object returned in the RPC response. However, in the response
  of `decodescript` these fields are top-level attributes, and included again as attributes
  of the `scriptPubKey` object. (#20286)

- When creating a hex-encoded paydacoin transaction using the `paydacoin-tx` utility
  with the `-json` option set, the following fields: `addresses`, `reqSigs` are no longer
  returned in the tx output of the response. (#20286)

- The `listbanned` RPC now returns two new numeric fields: `ban_duration` and `time_remaining`.
  Respectively, these new fields indicate the duration of a ban and the time remaining until a ban expires,
  both in seconds. Additionally, the `ban_created` field is repositioned to come before `banned_until`. (#21602)

- The `setban` RPC can ban onion addresses again. This fixes a regression introduced in version 0.21.0. (#20852)

- The `getnodeaddresses` RPC now returns a "network" field indicating the
  network type (ipv4, ipv6, onion, or i2p) for each address.  (#21594)

- `getnodeaddresses` now also accepts a "network" argument (ipv4, ipv6, onion,
  or i2p) to return only addresses of the specified network.  (#21843)

- The `testmempoolaccept` RPC now accepts multiple transactions (still experimental at the moment,
  API may be unstable). This is intended for testing transaction packages with dependency
  relationships; it is not recommended for batch-validating independent transactions. In addition to
  mempool policy, package policies apply: the list cannot contain more than 25 transactions or have a
  total size exceeding 101K virtual bytes, and cannot conflict with (spend the same inputs as) each other or
  the mempool, even if it would be a valid BIP125 replace-by-fee. There are some known limitations to
  the accuracy of the test accept: it's possible for `testmempoolaccept` to return "allowed"=True for a
  group of transactions, but "too-long-mempool-chain" if they are actually submitted. (#20833)

- `addmultisigaddress` and `createmultisig` now support up to 20 keys for
  Segwit addresses. (#20867)

Changes to Wallet or GUI related RPCs can be found in the GUI or Wallet section below.

Build System
------------

- Release binaries are now produced using the new `guix`-based build system.
  The [/doc/release-process.md](/doc/release-process.md) document has been updated accordingly.

Files
-----

- The list of banned hosts and networks (via `setban` RPC) is now saved on disk
  in JSON format in `banlist.json` instead of `banlist.dat`. `banlist.dat` is
  only read on startup if `banlist.json` is not present. Changes are only written to the new
  `banlist.json`. A future version of Paydacoin Core may completely ignore
  `banlist.dat`. (#20966)

New settings
------------

- The `-natpmp` option has been added to use NAT-PMP to map the listening port.
  If both UPnP and NAT-PMP are enabled, a successful allocation from UPnP
  prevails over one from NAT-PMP. (#18077)

Updated settings
----------------

Changes to Wallet or GUI related settings can be found in the GUI or Wallet section below.

- Passing an invalid `-rpcauth` argument now cause paydacoind to fail to start.  (#20461)

Tools and Utilities
-------------------

- A new CLI `-addrinfo` command returns the number of addresses known to the
  node per network type (including Tor v2 versus v3) and total. This can be
  useful to see if the node knows enough addresses in a network to use options
  like `-onlynet=<network>` or to upgrade to this release of Paydacoin Core 22.0
  that supports Tor v3 only.  (#21595)

- A new `-rpcwaittimeout` argument to `paydacoin-cli` sets the timeout
  in seconds to use with `-rpcwait`. If the timeout expires,
  `paydacoin-cli` will report a failure. (#21056)

Wallet
------

- External signers such as hardware wallets can now be used through the new RPC methods `enumeratesigners` and `displayaddress`. Support is also added to the `send` RPC call. This feature is experimental. See [external-signer.md](https://github.com/paydacoin/paydacoin/blob/22.x/doc/external-signer.md) for details. (#16546)

- A new `listdescriptors` RPC is available to inspect the contents of descriptor-enabled wallets.
  The RPC returns public versions of all imported descriptors, including their timestamp and flags.
  For ranged descriptors, it also returns the range boundaries and the next index to generate addresses from. (#20226)

- The `bumpfee` RPC is not available with wallets that have private keys
  disabled. `psbtbumpfee` can be used instead. (#20891)

- The `fundrawtransaction`, `send` and `walletcreatefundedpsbt` RPCs now support an `include_unsafe` option
  that when `true` allows using unsafe inputs to fund the transaction.
  Note that the resulting transaction may become invalid if one of the unsafe inputs disappears.
  If that happens, the transaction must be funded with different inputs and republished. (#21359)

- We now support up to 20 keys in `multi()` and `sortedmulti()` descriptors
  under `wsh()`. (#20867)

- Taproot descriptors can be imported into the wallet only after activation has occurred on the network (e.g. mainnet, testnet, signet) in use. See [descriptors.md](https://github.com/paydacoin/paydacoin/blob/22.x/doc/descriptors.md) for supported descriptors.

GUI changes
-----------

- External signers such as hardware wallets can now be used. These require an external tool such as [HWI](https://github.com/paydacoin-core/HWI) to be installed and configured under Options -> Wallet. When creating a new wallet a new option "External signer" will appear in the dialog. If the device is detected, its name is suggested as the wallet name. The watch-only keys are then automatically imported. Receive addresses can be verified on the device. The send dialog will automatically use the connected device. This feature is experimental and the UI may freeze for a few seconds when performing these actions.

Low-level changes
=================

RPC
---

- The RPC server can process a limited number of simultaneous RPC requests.
  Previously, if this limit was exceeded, the RPC server would respond with
  [status code 500 (`HTTP_INTERNAL_SERVER_ERROR`)](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#5xx_server_errors).
  Now it returns status code 503 (`HTTP_SERVICE_UNAVAILABLE`). (#18335)

- Error codes have been updated to be more accurate for the following error cases (#18466):
  - `signmessage` now returns RPC_INVALID_ADDRESS_OR_KEY (-5) if the
    passed address is invalid. Previously returned RPC_TYPE_ERROR (-3).
  - `verifymessage` now returns RPC_INVALID_ADDRESS_OR_KEY (-5) if the
    passed address is invalid. Previously returned RPC_TYPE_ERROR (-3).
  - `verifymessage` now returns RPC_TYPE_ERROR (-3) if the passed signature
    is malformed. Previously returned RPC_INVALID_ADDRESS_OR_KEY (-5).

Tests
-----

22.0 change log
===============

A detailed list of changes in this version follows. To keep the list to a manageable length, small refactors and typo fixes are not included, and similar changes are sometimes condensed into one line.

### Consensus
- paydacoin/paydacoin#19438 Introduce deploymentstatus (ajtowns)
- paydacoin/paydacoin#20207 Follow-up extra comments on taproot code and tests (sipa)
- paydacoin/paydacoin#21330 Deal with missing data in signature hashes more consistently (sipa)

### Policy
- paydacoin/paydacoin#18766 Disable fee estimation in blocksonly mode (by removing the fee estimates global) (darosior)
- paydacoin/paydacoin#20497 Add `MAX_STANDARD_SCRIPTSIG_SIZE` to policy (sanket1729)
- paydacoin/paydacoin#20611 Move `TX_MAX_STANDARD_VERSION` to policy (MarcoFalke)

### Mining
- paydacoin/paydacoin#19937, paydacoin/paydacoin#20923 Signet mining utility (ajtowns)

### Block and transaction handling
- paydacoin/paydacoin#14501 Fix possible data race when committing block files (luke-jr)
- paydacoin/paydacoin#15946 Allow maintaining the blockfilterindex when using prune (jonasschnelli)
- paydacoin/paydacoin#18710 Add local thread pool to CCheckQueue (hebasto)
- paydacoin/paydacoin#19521 Coinstats Index (fjahr)
- paydacoin/paydacoin#19806 UTXO snapshot activation (jamesob)
- paydacoin/paydacoin#19905 Remove dead CheckForkWarningConditionsOnNewFork (MarcoFalke)
- paydacoin/paydacoin#19935 Move SaltedHashers to separate file and add some new ones (achow101)
- paydacoin/paydacoin#20054 Remove confusing and useless "unexpected version" warning (MarcoFalke)
- paydacoin/paydacoin#20519 Handle rename failure in `DumpMempool(…)` by using the `RenameOver(…)` return value (practicalswift)
- paydacoin/paydacoin#20749, paydacoin/paydacoin#20750, paydacoin/paydacoin#21055, paydacoin/paydacoin#21270, paydacoin/paydacoin#21525, paydacoin/paydacoin#21391, paydacoin/paydacoin#21767, paydacoin/paydacoin#21866 Prune `g_chainman` usage (dongcarl)
- paydacoin/paydacoin#20833 rpc/validation: enable packages through testmempoolaccept (glozow)
- paydacoin/paydacoin#20834 Locks and docs in ATMP and CheckInputsFromMempoolAndCache (glozow)
- paydacoin/paydacoin#20854 Remove unnecessary try-block (amitiuttarwar)
- paydacoin/paydacoin#20868 Remove redundant check on pindex (jarolrod)
- paydacoin/paydacoin#20921 Don't try to invalidate genesis block in CChainState::InvalidateBlock (theStack)
- paydacoin/paydacoin#20972 Locks: Annotate CTxMemPool::check to require `cs_main` (dongcarl)
- paydacoin/paydacoin#21009 Remove RewindBlockIndex logic (dhruv)
- paydacoin/paydacoin#21025 Guard chainman chainstates with `cs_main` (dongcarl)
- paydacoin/paydacoin#21202 Two small clang lock annotation improvements (amitiuttarwar)
- paydacoin/paydacoin#21523 Run VerifyDB on all chainstates (jamesob)
- paydacoin/paydacoin#21573 Update libsecp256k1 subtree to latest master (sipa)
- paydacoin/paydacoin#21582, paydacoin/paydacoin#21584, paydacoin/paydacoin#21585 Fix assumeutxo crashes (MarcoFalke)
- paydacoin/paydacoin#21681 Fix ActivateSnapshot to use hardcoded nChainTx (jamesob)
- paydacoin/paydacoin#21796 index: Avoid async shutdown on init error (MarcoFalke)
- paydacoin/paydacoin#21946 Document and test lack of inherited signaling in RBF policy (ariard)
- paydacoin/paydacoin#22084 Package testmempoolaccept followups (glozow)
- paydacoin/paydacoin#22102 Remove `Warning:` from warning message printed for unknown new rules (prayank23)
- paydacoin/paydacoin#22112 Force port 0 in I2P (vasild)
- paydacoin/paydacoin#22135 CRegTestParams: Use `args` instead of `gArgs` (kiminuo)
- paydacoin/paydacoin#22146 Reject invalid coin height and output index when loading assumeutxo (MarcoFalke)
- paydacoin/paydacoin#22253 Distinguish between same tx and same-nonwitness-data tx in mempool (glozow)
- paydacoin/paydacoin#22261 Two small fixes to node broadcast logic (jnewbery)
- paydacoin/paydacoin#22415 Make `m_mempool` optional in CChainState (jamesob)
- paydacoin/paydacoin#22499 Update assumed chain params (sriramdvt)
- paydacoin/paydacoin#22589 net, doc: update I2P hardcoded seeds and docs for 22.0 (jonatack)

### P2P protocol and network code
- paydacoin/paydacoin#18077 Add NAT-PMP port forwarding support (hebasto)
- paydacoin/paydacoin#18722 addrman: improve performance by using more suitable containers (vasild)
- paydacoin/paydacoin#18819 Replace `cs_feeFilter` with simple std::atomic (MarcoFalke)
- paydacoin/paydacoin#19203 Add regression fuzz harness for CVE-2017-18350. Add FuzzedSocket (practicalswift)
- paydacoin/paydacoin#19288 fuzz: Add fuzzing harness for TorController (practicalswift)
- paydacoin/paydacoin#19415 Make DNS lookup mockable, add fuzzing harness (practicalswift)
- paydacoin/paydacoin#19509 Per-Peer Message Capture (troygiorshev)
- paydacoin/paydacoin#19763 Don't try to relay to the address' originator (vasild)
- paydacoin/paydacoin#19771 Replace enum CConnMan::NumConnections with enum class ConnectionDirection (luke-jr)
- paydacoin/paydacoin#19776 net, rpc: expose high bandwidth mode state via getpeerinfo (theStack)
- paydacoin/paydacoin#19832 Put disconnecting logs into BCLog::NET category (hebasto)
- paydacoin/paydacoin#19858 Periodically make block-relay connections and sync headers (sdaftuar)
- paydacoin/paydacoin#19884 No delay in adding fixed seeds if -dnsseed=0 and peers.dat is empty (dhruv)
- paydacoin/paydacoin#20079 Treat handshake misbehavior like unknown message (MarcoFalke)
- paydacoin/paydacoin#20138 Assume that SetCommonVersion is called at most once per peer (MarcoFalke)
- paydacoin/paydacoin#20162 p2p: declare Announcement::m_state as uint8_t, add getter/setter (jonatack)
- paydacoin/paydacoin#20197 Protect onions in AttemptToEvictConnection(), add eviction protection test coverage (jonatack)
- paydacoin/paydacoin#20210 assert `CNode::m_inbound_onion` is inbound in ctor, add getter, unit tests (jonatack)
- paydacoin/paydacoin#20228 addrman: Make addrman a top-level component (jnewbery)
- paydacoin/paydacoin#20234 Don't bind on 0.0.0.0 if binds are restricted to Tor (vasild)
- paydacoin/paydacoin#20477 Add unit testing of node eviction logic (practicalswift)
- paydacoin/paydacoin#20516 Well-defined CAddress disk serialization, and addrv2 anchors.dat (sipa)
- paydacoin/paydacoin#20557 addrman: Fix new table bucketing during unserialization (jnewbery)
- paydacoin/paydacoin#20561 Periodically clear `m_addr_known` (sdaftuar)
- paydacoin/paydacoin#20599 net processing: Tolerate sendheaders and sendcmpct messages before verack (jnewbery)
- paydacoin/paydacoin#20616 Check CJDNS address is valid (lontivero)
- paydacoin/paydacoin#20617 Remove `m_is_manual_connection` from CNodeState (ariard)
- paydacoin/paydacoin#20624 net processing: Remove nStartingHeight check from block relay (jnewbery)
- paydacoin/paydacoin#20651 Make p2p recv buffer timeout 20 minutes for all peers (jnewbery)
- paydacoin/paydacoin#20661 Only select from addrv2-capable peers for torv3 address relay (sipa)
- paydacoin/paydacoin#20685 Add I2P support using I2P SAM (vasild)
- paydacoin/paydacoin#20690 Clean up logging of outbound connection type (sdaftuar)
- paydacoin/paydacoin#20721 Move ping data to `net_processing` (jnewbery)
- paydacoin/paydacoin#20724 Cleanup of -debug=net log messages (ajtowns)
- paydacoin/paydacoin#20747 net processing: Remove dropmessagestest (jnewbery)
- paydacoin/paydacoin#20764 cli -netinfo peer connections dashboard updates 🎄 ✨ (jonatack)
- paydacoin/paydacoin#20788 add RAII socket and use it instead of bare SOCKET (vasild)
- paydacoin/paydacoin#20791 remove unused legacyWhitelisted in AcceptConnection() (jonatack)
- paydacoin/paydacoin#20816 Move RecordBytesSent() call out of `cs_vSend` lock (jnewbery)
- paydacoin/paydacoin#20845 Log to net debug in MaybeDiscourageAndDisconnect except for noban and manual peers (MarcoFalke)
- paydacoin/paydacoin#20864 Move SocketSendData lock annotation to header (MarcoFalke)
- paydacoin/paydacoin#20965 net, rpc:  return `NET_UNROUTABLE` as `not_publicly_routable`, automate helps (jonatack)
- paydacoin/paydacoin#20966 banman: save the banlist in a JSON format on disk (vasild)
- paydacoin/paydacoin#21015 Make all of `net_processing` (and some of net) use std::chrono types (dhruv)
- paydacoin/paydacoin#21029 paydacoin-cli: Correct docs (no "generatenewaddress" exists) (luke-jr)
- paydacoin/paydacoin#21148 Split orphan handling from `net_processing` into txorphanage (ajtowns)
- paydacoin/paydacoin#21162 Net Processing: Move RelayTransaction() into PeerManager (jnewbery)
- paydacoin/paydacoin#21167 make `CNode::m_inbound_onion` public, initialize explicitly (jonatack)
- paydacoin/paydacoin#21186 net/net processing: Move addr data into `net_processing` (jnewbery)
- paydacoin/paydacoin#21187 Net processing: Only call PushAddress() from `net_processing` (jnewbery)
- paydacoin/paydacoin#21198 Address outstanding review comments from PR20721 (jnewbery)
- paydacoin/paydacoin#21222 log: Clarify log message when file does not exist (MarcoFalke)
- paydacoin/paydacoin#21235 Clarify disconnect log message in ProcessGetBlockData, remove send bool (MarcoFalke)
- paydacoin/paydacoin#21236 Net processing: Extract `addr` send functionality into MaybeSendAddr() (jnewbery)
- paydacoin/paydacoin#21261 update inbound eviction protection for multiple networks, add I2P peers (jonatack)
- paydacoin/paydacoin#21328 net, refactor: pass uint16 CService::port as uint16 (jonatack)
- paydacoin/paydacoin#21387 Refactor sock to add I2P fuzz and unit tests (vasild)
- paydacoin/paydacoin#21395 Net processing: Remove unused CNodeState.address member (jnewbery)
- paydacoin/paydacoin#21407 i2p: limit the size of incoming messages (vasild)
- paydacoin/paydacoin#21506 p2p, refactor: make NetPermissionFlags an enum class (jonatack)
- paydacoin/paydacoin#21509 Don't send FEEFILTER in blocksonly mode (mzumsande)
- paydacoin/paydacoin#21560 Add Tor v3 hardcoded seeds (laanwj)
- paydacoin/paydacoin#21563 Restrict period when `cs_vNodes` mutex is locked (hebasto)
- paydacoin/paydacoin#21564 Avoid calling getnameinfo when formatting IPv4 addresses in CNetAddr::ToStringIP (practicalswift)
- paydacoin/paydacoin#21631 i2p: always check the return value of Sock::Wait() (vasild)
- paydacoin/paydacoin#21644 p2p, bugfix: use NetPermissions::HasFlag() in CConnman::Bind() (jonatack)
- paydacoin/paydacoin#21659 flag relevant Sock methods with [[nodiscard]] (vasild)
- paydacoin/paydacoin#21750 remove unnecessary check of `CNode::cs_vSend` (vasild)
- paydacoin/paydacoin#21756 Avoid calling `getnameinfo` when formatting IPv6 addresses in `CNetAddr::ToStringIP` (practicalswift)
- paydacoin/paydacoin#21775 Limit `m_block_inv_mutex` (MarcoFalke)
- paydacoin/paydacoin#21825 Add I2P hardcoded seeds (jonatack)
- paydacoin/paydacoin#21843 p2p, rpc: enable GetAddr, GetAddresses, and getnodeaddresses by network (jonatack)
- paydacoin/paydacoin#21845 net processing: Don't require locking `cs_main` before calling RelayTransactions() (jnewbery)
- paydacoin/paydacoin#21872 Sanitize message type for logging (laanwj)
- paydacoin/paydacoin#21914 Use stronger AddLocal() for our I2P address (vasild)
- paydacoin/paydacoin#21985 Return IPv6 scope id in `CNetAddr::ToStringIP()` (laanwj)
- paydacoin/paydacoin#21992 Remove -feefilter option (amadeuszpawlik)
- paydacoin/paydacoin#21996 Pass strings to NetPermissions::TryParse functions by const ref (jonatack)
- paydacoin/paydacoin#22013 ignore block-relay-only peers when skipping DNS seed (ajtowns)
- paydacoin/paydacoin#22050 Remove tor v2 support (jonatack)
- paydacoin/paydacoin#22096 AddrFetch - don't disconnect on self-announcements (mzumsande)
- paydacoin/paydacoin#22141 net processing: Remove hash and fValidatedHeaders from QueuedBlock (jnewbery)
- paydacoin/paydacoin#22144 Randomize message processing peer order (sipa)
- paydacoin/paydacoin#22147 Protect last outbound HB compact block peer (sdaftuar)
- paydacoin/paydacoin#22179 Torv2 removal followups (vasild)
- paydacoin/paydacoin#22211 Relay I2P addresses even if not reachable (by us) (vasild)
- paydacoin/paydacoin#22284 Performance improvements to ProtectEvictionCandidatesByRatio() (jonatack)
- paydacoin/paydacoin#22387 Rate limit the processing of rumoured addresses (sipa)
- paydacoin/paydacoin#22455 addrman: detect on-disk corrupted nNew and nTried during unserialization (vasild)

### Wallet
- paydacoin/paydacoin#15710 Catch `ios_base::failure` specifically (Bushstar)
- paydacoin/paydacoin#16546 External signer support - Wallet Box edition (Sjors)
- paydacoin/paydacoin#17331 Use effective values throughout coin selection (achow101)
- paydacoin/paydacoin#18418 Increase `OUTPUT_GROUP_MAX_ENTRIES` to 100 (fjahr)
- paydacoin/paydacoin#18842 Mark replaced tx to not be in the mempool anymore (MarcoFalke)
- paydacoin/paydacoin#19136 Add `parent_desc` to `getaddressinfo` (achow101)
- paydacoin/paydacoin#19137 wallettool: Add dump and createfromdump commands (achow101)
- paydacoin/paydacoin#19651 `importdescriptor`s update existing (S3RK)
- paydacoin/paydacoin#20040 Refactor OutputGroups to handle fees and spending eligibility on grouping (achow101)
- paydacoin/paydacoin#20202 Make BDB support optional (achow101)
- paydacoin/paydacoin#20226, paydacoin/paydacoin#21277, - paydacoin/paydacoin#21063 Add `listdescriptors` command (S3RK)
- paydacoin/paydacoin#20267 Disable and fix tests for when BDB is not compiled (achow101)
- paydacoin/paydacoin#20275 List all wallets in non-SQLite and non-BDB builds (ryanofsky)
- paydacoin/paydacoin#20365 wallettool: Add parameter to create descriptors wallet (S3RK)
- paydacoin/paydacoin#20403 `upgradewallet` fixes, improvements, test coverage (jonatack)
- paydacoin/paydacoin#20448 `unloadwallet`: Allow specifying `wallet_name` param matching RPC endpoint wallet (luke-jr)
- paydacoin/paydacoin#20536 Error with "Transaction too large" if the funded tx will end up being too large after signing (achow101)
- paydacoin/paydacoin#20687 Add missing check for -descriptors wallet tool option (MarcoFalke)
- paydacoin/paydacoin#20952 Add BerkeleyDB version sanity check at init time (laanwj)
- paydacoin/paydacoin#21127 Load flags before everything else (Sjors)
- paydacoin/paydacoin#21141 Add new format string placeholders for walletnotify (maayank)
- paydacoin/paydacoin#21238 A few descriptor improvements to prepare for Taproot support (sipa)
- paydacoin/paydacoin#21302 `createwallet` examples for descriptor wallets (S3RK)
- paydacoin/paydacoin#21329 descriptor wallet: Cache last hardened xpub and use in normalized descriptors (achow101)
- paydacoin/paydacoin#21365 Basic Taproot signing support for descriptor wallets (sipa)
- paydacoin/paydacoin#21417 Misc external signer improvement and HWI 2 support (Sjors)
- paydacoin/paydacoin#21467 Move external signer out of wallet module (Sjors)
- paydacoin/paydacoin#21572 Fix wrong wallet RPC context set after #21366 (ryanofsky)
- paydacoin/paydacoin#21574 Drop JSONRPCRequest constructors after #21366 (ryanofsky)
- paydacoin/paydacoin#21666 Miscellaneous external signer changes (fanquake)
- paydacoin/paydacoin#21759 Document coin selection code (glozow)
- paydacoin/paydacoin#21786 Ensure sat/vB feerates are in range (mantissa of 3) (jonatack)
- paydacoin/paydacoin#21944 Fix issues when `walletdir` is root directory (prayank23)
- paydacoin/paydacoin#22042 Replace size/weight estimate tuple with struct for named fields (instagibbs)
- paydacoin/paydacoin#22051 Basic Taproot derivation support for descriptors (sipa)
- paydacoin/paydacoin#22154 Add OutputType::BECH32M and related wallet support for fetching bech32m addresses (achow101)
- paydacoin/paydacoin#22156 Allow tr() import only when Taproot is active (achow101)
- paydacoin/paydacoin#22166 Add support for inferring tr() descriptors (sipa)
- paydacoin/paydacoin#22173 Do not load external signers wallets when unsupported (achow101)
- paydacoin/paydacoin#22308 Add missing BlockUntilSyncedToCurrentChain (MarcoFalke)
- paydacoin/paydacoin#22334 Do not spam about non-existent spk managers (S3RK)
- paydacoin/paydacoin#22379 Erase spkmans rather than setting to nullptr (achow101)
- paydacoin/paydacoin#22421 Make IsSegWitOutput return true for taproot outputs (sipa)
- paydacoin/paydacoin#22461 Change ScriptPubKeyMan::Upgrade default to True (achow101)
- paydacoin/paydacoin#22492 Reorder locks in dumpwallet to avoid lock order assertion (achow101)
- paydacoin/paydacoin#22686 Use GetSelectionAmount in ApproximateBestSubset (achow101)

### RPC and other APIs
- paydacoin/paydacoin#18335, paydacoin/paydacoin#21484 cli: Print useful error if paydacoind rpc work queue exceeded (LarryRuane)
- paydacoin/paydacoin#18466 Fix invalid parameter error codes for `{sign,verify}message` RPCs (theStack)
- paydacoin/paydacoin#18772 Calculate fees in `getblock` using BlockUndo data (robot-visions)
- paydacoin/paydacoin#19033 http: Release work queue after event base finish (promag)
- paydacoin/paydacoin#19055 Add MuHash3072 implementation (fjahr)
- paydacoin/paydacoin#19145 Add `hash_type` MUHASH for gettxoutsetinfo (fjahr)
- paydacoin/paydacoin#19847 Avoid duplicate set lookup in `gettxoutproof` (promag)
- paydacoin/paydacoin#20286 Deprecate `addresses` and `reqSigs` from RPC outputs (mjdietzx)
- paydacoin/paydacoin#20459 Fail to return undocumented return values (MarcoFalke)
- paydacoin/paydacoin#20461 Validate `-rpcauth` arguments (promag)
- paydacoin/paydacoin#20556 Properly document return values (`submitblock`, `gettxout`, `getblocktemplate`, `scantxoutset`) (MarcoFalke)
- paydacoin/paydacoin#20755 Remove deprecated fields from `getpeerinfo` (amitiuttarwar)
- paydacoin/paydacoin#20832 Better error messages for invalid addresses (eilx2)
- paydacoin/paydacoin#20867 Support up to 20 keys for multisig under Segwit context (darosior)
- paydacoin/paydacoin#20877 cli: `-netinfo` user help and argument parsing improvements (jonatack)
- paydacoin/paydacoin#20891 Remove deprecated bumpfee behavior (achow101)
- paydacoin/paydacoin#20916 Return wtxid from `testmempoolaccept` (MarcoFalke)
- paydacoin/paydacoin#20917 Add missing signet mentions in network name lists (theStack)
- paydacoin/paydacoin#20941 Document `RPC_TRANSACTION_ALREADY_IN_CHAIN` exception (jarolrod)
- paydacoin/paydacoin#20944 Return total fee in `getmempoolinfo` (MarcoFalke)
- paydacoin/paydacoin#20964 Add specific error code for "wallet already loaded" (laanwj)
- paydacoin/paydacoin#21053 Document {previous,next}blockhash as optional (theStack)
- paydacoin/paydacoin#21056 Add a `-rpcwaittimeout` parameter to limit time spent waiting (cdecker)
- paydacoin/paydacoin#21192 cli: Treat high detail levels as maximum in `-netinfo` (laanwj)
- paydacoin/paydacoin#21311 Document optional fields for `getchaintxstats` result (theStack)
- paydacoin/paydacoin#21359 `include_unsafe` option for fundrawtransaction (t-bast)
- paydacoin/paydacoin#21426 Remove `scantxoutset` EXPERIMENTAL warning (jonatack)
- paydacoin/paydacoin#21544 Missing doc updates for bumpfee psbt update (MarcoFalke)
- paydacoin/paydacoin#21594 Add `network` field to `getnodeaddresses` (jonatack)
- paydacoin/paydacoin#21595, paydacoin/paydacoin#21753 cli: Create `-addrinfo` (jonatack)
- paydacoin/paydacoin#21602 Add additional ban time fields to `listbanned` (jarolrod)
- paydacoin/paydacoin#21679 Keep default argument value in correct type (promag)
- paydacoin/paydacoin#21718 Improve error message for `getblock` invalid datatype (klementtan)
- paydacoin/paydacoin#21913 RPCHelpMan fixes (kallewoof)
- paydacoin/paydacoin#22021 `bumpfee`/`psbtbumpfee` fixes and updates (jonatack)
- paydacoin/paydacoin#22043 `addpeeraddress` test coverage, code simplify/constness (jonatack)
- paydacoin/paydacoin#22327 cli: Avoid truncating `-rpcwaittimeout` (MarcoFalke)

### GUI
- paydacoin/paydacoin#18948 Call setParent() in the parent's context (hebasto)
- paydacoin/paydacoin#20482 Add depends qt fix for ARM macs (jonasschnelli)
- paydacoin/paydacoin#21836 scripted-diff: Replace three dots with ellipsis in the ui strings (hebasto)
- paydacoin/paydacoin#21935 Enable external signer support for GUI builds (Sjors)
- paydacoin/paydacoin#22133 Make QWindowsVistaStylePlugin available again (regression) (hebasto)
- paydacoin-core/gui#4 UI external signer support (e.g. hardware wallet) (Sjors)
- paydacoin-core/gui#13 Hide peer detail view if multiple are selected (promag)
- paydacoin-core/gui#18 Add peertablesortproxy module (hebasto)
- paydacoin-core/gui#21 Improve pruning tooltip (fluffypony, PaydacoinErrorLog)
- paydacoin-core/gui#72 Log static plugins meta data and used style (hebasto)
- paydacoin-core/gui#79 Embed monospaced font (hebasto)
- paydacoin-core/gui#85 Remove unused "What's This" button in dialogs on Windows OS (hebasto)
- paydacoin-core/gui#115 Replace "Hide tray icon" option with positive "Show tray icon" one (hebasto)
- paydacoin-core/gui#118 Remove BDB version from the Information tab (hebasto)
- paydacoin-core/gui#121 Early subscribe core signals in transaction table model (promag)
- paydacoin-core/gui#123 Do not accept command while executing another one (hebasto)
- paydacoin-core/gui#125 Enable changing the autoprune block space size in intro dialog (luke-jr)
- paydacoin-core/gui#138 Unlock encrypted wallet "OK" button bugfix (mjdietzx)
- paydacoin-core/gui#139 doc: Improve gui/src/qt README.md (jarolrod)
- paydacoin-core/gui#154 Support macOS Dark mode (goums, Uplab)
- paydacoin-core/gui#162 Add network to peers window and peer details (jonatack)
- paydacoin-core/gui#163, paydacoin-core/gui#180 Peer details: replace Direction with Connection Type (jonatack)
- paydacoin-core/gui#164 Handle peer addition/removal in a right way (hebasto)
- paydacoin-core/gui#165 Save QSplitter state in QSettings (hebasto)
- paydacoin-core/gui#173 Follow Qt docs when implementing rowCount and columnCount (hebasto)
- paydacoin-core/gui#179 Add Type column to peers window, update peer details name/tooltip (jonatack)
- paydacoin-core/gui#186 Add information to "Confirm fee bump" window (prayank23)
- paydacoin-core/gui#189 Drop workaround for QTBUG-42503 which was fixed in Qt 5.5.0 (prusnak)
- paydacoin-core/gui#194 Save/restore RPCConsole geometry only for window (hebasto)
- paydacoin-core/gui#202 Fix right panel toggle in peers tab (RandyMcMillan)
- paydacoin-core/gui#203 Display plain "Inbound" in peer details (jonatack)
- paydacoin-core/gui#204 Drop buggy TableViewLastColumnResizingFixer class (hebasto)
- paydacoin-core/gui#205, paydacoin-core/gui#229 Save/restore TransactionView and recentRequestsView tables column sizes (hebasto)
- paydacoin-core/gui#206 Display fRelayTxes and `bip152_highbandwidth_{to, from}` in peer details (jonatack)
- paydacoin-core/gui#213 Add Copy Address Action to Payment Requests (jarolrod)
- paydacoin-core/gui#214 Disable requests context menu actions when appropriate (jarolrod)
- paydacoin-core/gui#217 Make warning label look clickable (jarolrod)
- paydacoin-core/gui#219 Prevent the main window popup menu (hebasto)
- paydacoin-core/gui#220 Do not translate file extensions (hebasto)
- paydacoin-core/gui#221 RPCConsole translatable string fixes and improvements (jonatack)
- paydacoin-core/gui#226 Add "Last Block" and "Last Tx" rows to peer details area (jonatack)
- paydacoin-core/gui#233 qt test: Don't bind to regtest port (achow101)
- paydacoin-core/gui#243 Fix issue when disabling the auto-enabled blank wallet checkbox (jarolrod)
- paydacoin-core/gui#246 Revert "qt: Use "fusion" style on macOS Big Sur with old Qt" (hebasto)
- paydacoin-core/gui#248 For values of "Bytes transferred" and "Bytes/s" with 1000-based prefix names use 1000-based divisor instead of 1024-based (wodry)
- paydacoin-core/gui#251 Improve URI/file handling message (hebasto)
- paydacoin-core/gui#256 Save/restore column sizes of the tables in the Peers tab (hebasto)
- paydacoin-core/gui#260 Handle exceptions isntead of crash (hebasto)
- paydacoin-core/gui#263 Revamp context menus (hebasto)
- paydacoin-core/gui#271 Don't clear console prompt when font resizing (jarolrod)
- paydacoin-core/gui#275 Support runtime appearance adjustment on macOS (hebasto)
- paydacoin-core/gui#276 Elide long strings in their middle in the Peers tab (hebasto)
- paydacoin-core/gui#281 Set shortcuts for console's resize buttons (jarolrod)
- paydacoin-core/gui#293 Enable wordWrap for Services (RandyMcMillan)
- paydacoin-core/gui#296 Do not use QObject::tr plural syntax for numbers with a unit symbol (hebasto)
- paydacoin-core/gui#297 Avoid unnecessary translations (hebasto)
- paydacoin-core/gui#298 Peertableview alternating row colors (RandyMcMillan)
- paydacoin-core/gui#300 Remove progress bar on modal overlay (brunoerg)
- paydacoin-core/gui#309 Add access to the Peers tab from the network icon (hebasto)
- paydacoin-core/gui#311 Peers Window rename 'Peer id' to 'Peer' (jarolrod)
- paydacoin-core/gui#313 Optimize string concatenation by default (hebasto)
- paydacoin-core/gui#325 Align numbers in the "Peer Id" column to the right (hebasto)
- paydacoin-core/gui#329 Make console buttons look clickable (jarolrod)
- paydacoin-core/gui#330 Allow prompt icon to be colorized (jarolrod)
- paydacoin-core/gui#331 Make RPC console welcome message translation-friendly (hebasto)
- paydacoin-core/gui#332 Replace disambiguation strings with translator comments (hebasto)
- paydacoin-core/gui#335 test: Use QSignalSpy instead of QEventLoop (jarolrod)
- paydacoin-core/gui#343 Improve the GUI responsiveness when progress dialogs are used (hebasto)
- paydacoin-core/gui#361 Fix GUI segfault caused by paydacoin/paydacoin#22216 (ryanofsky)
- paydacoin-core/gui#362 Add keyboard shortcuts to context menus (luke-jr)
- paydacoin-core/gui#366 Dark Mode fixes/portability (luke-jr)
- paydacoin-core/gui#375 Emit dataChanged signal to dynamically re-sort Peers table (hebasto)
- paydacoin-core/gui#393 Fix regression in "Encrypt Wallet" menu item (hebasto)
- paydacoin-core/gui#396 Ensure external signer option remains disabled without signers (achow101)
- paydacoin-core/gui#406 Handle new added plurals in `paydacoin_en.ts` (hebasto)

### Build system
- paydacoin/paydacoin#17227 Add Android packaging support (icota)
- paydacoin/paydacoin#17920 guix: Build support for macOS (dongcarl)
- paydacoin/paydacoin#18298 Fix Qt processing of configure script for depends with DEBUG=1 (hebasto)
- paydacoin/paydacoin#19160 multiprocess: Add basic spawn and IPC support (ryanofsky)
- paydacoin/paydacoin#19504 Bump minimum python version to 3.6 (ajtowns)
- paydacoin/paydacoin#19522 fix building libconsensus with reduced exports for Darwin targets (fanquake)
- paydacoin/paydacoin#19683 Pin clang search paths for darwin host (dongcarl)
- paydacoin/paydacoin#19764 Split boost into build/host packages + bump + cleanup (dongcarl)
- paydacoin/paydacoin#19817 libtapi 1100.0.11 (fanquake)
- paydacoin/paydacoin#19846 enable unused member function diagnostic (Zero-1729)
- paydacoin/paydacoin#19867 Document and cleanup Qt hacks (fanquake)
- paydacoin/paydacoin#20046 Set `CMAKE_INSTALL_RPATH` for native packages (ryanofsky)
- paydacoin/paydacoin#20223 Drop the leading 0 from the version number (achow101)
- paydacoin/paydacoin#20333 Remove `native_biplist` dependency (fanquake)
- paydacoin/paydacoin#20353 configure: Support -fdebug-prefix-map and -fmacro-prefix-map (ajtowns)
- paydacoin/paydacoin#20359 Various config.site.in improvements and linting (dongcarl)
- paydacoin/paydacoin#20413 Require C++17 compiler (MarcoFalke)
- paydacoin/paydacoin#20419 Set minimum supported macOS to 10.14 (fanquake)
- paydacoin/paydacoin#20421 miniupnpc 2.2.2 (fanquake)
- paydacoin/paydacoin#20422 Mac deployment unification (fanquake)
- paydacoin/paydacoin#20424 Update univalue subtree (MarcoFalke)
- paydacoin/paydacoin#20449 Fix Windows installer build (achow101)
- paydacoin/paydacoin#20468 Warn when generating man pages for binaries built from a dirty branch (tylerchambers)
- paydacoin/paydacoin#20469 Avoid secp256k1.h include from system (dergoegge)
- paydacoin/paydacoin#20470 Replace genisoimage with xorriso (dongcarl)
- paydacoin/paydacoin#20471 Use C++17 in depends (fanquake)
- paydacoin/paydacoin#20496 Drop unneeded macOS framework dependencies (hebasto)
- paydacoin/paydacoin#20520 Do not force Precompiled Headers (PCH) for building Qt on Linux (hebasto)
- paydacoin/paydacoin#20549 Support make src/paydacoin-node and src/paydacoin-gui (promag)
- paydacoin/paydacoin#20565 Ensure PIC build for bdb on Android (BlockMechanic)
- paydacoin/paydacoin#20594 Fix getauxval calls in randomenv.cpp (jonasschnelli)
- paydacoin/paydacoin#20603 Update crc32c subtree (MarcoFalke)
- paydacoin/paydacoin#20609 configure: output notice that test binary is disabled by fuzzing (apoelstra)
- paydacoin/paydacoin#20619 guix: Quality of life improvements (dongcarl)
- paydacoin/paydacoin#20629 Improve id string robustness (dongcarl)
- paydacoin/paydacoin#20641 Use Qt top-level build facilities (hebasto)
- paydacoin/paydacoin#20650 Drop workaround for a fixed bug in Qt build system (hebasto)
- paydacoin/paydacoin#20673 Use more legible qmake commands in qt package (hebasto)
- paydacoin/paydacoin#20684 Define .INTERMEDIATE target once only (hebasto)
- paydacoin/paydacoin#20720 more robustly check for fcf-protection support (fanquake)
- paydacoin/paydacoin#20734 Make platform-specific targets available for proper platform builds only (hebasto)
- paydacoin/paydacoin#20936 build fuzz tests by default (danben)
- paydacoin/paydacoin#20937 guix: Make nsis reproducible by respecting SOURCE-DATE-EPOCH (dongcarl)
- paydacoin/paydacoin#20938 fix linking against -latomic when building for riscv (fanquake)
- paydacoin/paydacoin#20939 fix `RELOC_SECTION` security check for paydacoin-util (fanquake)
- paydacoin/paydacoin#20963 gitian-linux: Build binaries for 64-bit POWER (continued) (laanwj)
- paydacoin/paydacoin#21036 gitian: Bump descriptors to focal for 22.0 (fanquake)
- paydacoin/paydacoin#21045 Adds switch to enable/disable randomized base address in MSVC builds (EthanHeilman)
- paydacoin/paydacoin#21065 make macOS HOST in download-osx generic (fanquake)
- paydacoin/paydacoin#21078 guix: only download sources for hosts being built (fanquake)
- paydacoin/paydacoin#21116 Disable --disable-fuzz-binary for gitian/guix builds (hebasto)
- paydacoin/paydacoin#21182 remove mostly pointless `BOOST_PROCESS` macro (fanquake)
- paydacoin/paydacoin#21205 actually fail when Boost is missing (fanquake)
- paydacoin/paydacoin#21209 use newer source for libnatpmp (fanquake)
- paydacoin/paydacoin#21226 Fix fuzz binary compilation under windows (danben)
- paydacoin/paydacoin#21231 Add /opt/homebrew to path to look for boost libraries (fyquah)
- paydacoin/paydacoin#21239 guix: Add codesignature attachment support for osx+win (dongcarl)
- paydacoin/paydacoin#21250 Make `HAVE_O_CLOEXEC` available outside LevelDB (bugfix) (theStack)
- paydacoin/paydacoin#21272 guix: Passthrough `SDK_PATH` into container (dongcarl)
- paydacoin/paydacoin#21274 assumptions:  Assume C++17 (fanquake)
- paydacoin/paydacoin#21286 Bump minimum Qt version to 5.9.5 (hebasto)
- paydacoin/paydacoin#21298 guix: Bump time-machine, glibc, and linux-headers (dongcarl)
- paydacoin/paydacoin#21304 guix: Add guix-clean script + establish gc-root for container profiles (dongcarl)
- paydacoin/paydacoin#21320 fix libnatpmp macos cross compile (fanquake)
- paydacoin/paydacoin#21321 guix: Add curl to required tool list (hebasto)
- paydacoin/paydacoin#21333 set Unicode true for NSIS installer (fanquake)
- paydacoin/paydacoin#21339 Make `AM_CONDITIONAL([ENABLE_EXTERNAL_SIGNER])` unconditional (hebasto)
- paydacoin/paydacoin#21349 Fix fuzz-cuckoocache cross-compiling with DEBUG=1 (hebasto)
- paydacoin/paydacoin#21354 build, doc: Drop no longer required packages from macOS cross-compiling dependencies (hebasto)
- paydacoin/paydacoin#21363 build, qt: Improve Qt static plugins/libs check code (hebasto)
- paydacoin/paydacoin#21375 guix: Misc feedback-based fixes + hier restructuring (dongcarl)
- paydacoin/paydacoin#21376 Qt 5.12.10 (fanquake)
- paydacoin/paydacoin#21382 Clean remnants of QTBUG-34748 fix (hebasto)
- paydacoin/paydacoin#21400 Fix regression introduced in #21363 (hebasto)
- paydacoin/paydacoin#21403 set --build when configuring packages in depends (fanquake)
- paydacoin/paydacoin#21421 don't try and use -fstack-clash-protection on Windows (fanquake)
- paydacoin/paydacoin#21423 Cleanups and follow ups after bumping Qt to 5.12.10 (hebasto)
- paydacoin/paydacoin#21427 Fix `id_string` invocations (dongcarl)
- paydacoin/paydacoin#21430 Add -Werror=implicit-fallthrough compile flag (hebasto)
- paydacoin/paydacoin#21457 Split libtapi and clang out of `native_cctools` (fanquake)
- paydacoin/paydacoin#21462 guix: Add guix-{attest,verify} scripts (dongcarl)
- paydacoin/paydacoin#21495 build, qt: Fix static builds on macOS Big Sur (hebasto)
- paydacoin/paydacoin#21497 Do not opt-in unused CoreWLAN stuff in depends for macOS (hebasto)
- paydacoin/paydacoin#21543 Enable safe warnings for msvc builds (hebasto)
- paydacoin/paydacoin#21565 Make `paydacoin_qt.m4` more generic (fanquake)
- paydacoin/paydacoin#21610 remove -Wdeprecated-register from NOWARN flags (fanquake)
- paydacoin/paydacoin#21613 enable -Wdocumentation (fanquake)
- paydacoin/paydacoin#21629 Fix configuring when building depends with `NO_BDB=1` (fanquake)
- paydacoin/paydacoin#21654 build, qt: Make Qt rcc output always deterministic (hebasto)
- paydacoin/paydacoin#21655 build, qt: No longer need to set `QT_RCC_TEST=1` for determinism (hebasto)
- paydacoin/paydacoin#21658 fix make deploy for arm64-darwin (sgulls)
- paydacoin/paydacoin#21694 Use XLIFF file to provide more context to Transifex translators (hebasto)
- paydacoin/paydacoin#21708, paydacoin/paydacoin#21593 Drop pointless sed commands (hebasto)
- paydacoin/paydacoin#21731 Update msvc build to use Qt5.12.10 binaries (sipsorcery)
- paydacoin/paydacoin#21733 Re-add command to install vcpkg (dplusplus1024)
- paydacoin/paydacoin#21793 Use `-isysroot` over `--sysroot` on macOS (fanquake)
- paydacoin/paydacoin#21869 Add missing `-D_LIBCPP_DEBUG=1` to debug flags (MarcoFalke)
- paydacoin/paydacoin#21889 macho: check for control flow instrumentation (fanquake)
- paydacoin/paydacoin#21920 Improve macro for testing -latomic requirement (MarcoFalke)
- paydacoin/paydacoin#21991 libevent 2.1.12-stable (fanquake)
- paydacoin/paydacoin#22054 Bump Qt version to 5.12.11 (hebasto)
- paydacoin/paydacoin#22063 Use Qt archive of the same version as the compiled binaries (hebasto)
- paydacoin/paydacoin#22070 Don't use cf-protection when targeting arm-apple-darwin (fanquake)
- paydacoin/paydacoin#22071 Latest config.guess and config.sub (fanquake)
- paydacoin/paydacoin#22075 guix: Misc leftover usability improvements (dongcarl)
- paydacoin/paydacoin#22123 Fix qt.mk for mac arm64 (promag)
- paydacoin/paydacoin#22174 build, qt: Fix libraries linking order for Linux hosts (hebasto)
- paydacoin/paydacoin#22182 guix: Overhaul how guix-{attest,verify} works and hierarchy (dongcarl)
- paydacoin/paydacoin#22186 build, qt: Fix compiling qt package in depends with GCC 11 (hebasto)
- paydacoin/paydacoin#22199 macdeploy: minor fixups and simplifications (fanquake)
- paydacoin/paydacoin#22230 Fix MSVC linker /SubSystem option for paydacoin-qt.exe (hebasto)
- paydacoin/paydacoin#22234 Mark print-% target as phony (dgoncharov)
- paydacoin/paydacoin#22238 improve detection of eBPF support (fanquake)
- paydacoin/paydacoin#22258 Disable deprecated-copy warning only when external warnings are enabled (MarcoFalke)
- paydacoin/paydacoin#22320 set minimum required Boost to 1.64.0 (fanquake)
- paydacoin/paydacoin#22348 Fix cross build for Windows with Boost Process (hebasto)
- paydacoin/paydacoin#22365 guix: Avoid relying on newer symbols by rebasing our cross toolchains on older glibcs (dongcarl)
- paydacoin/paydacoin#22381 guix: Test security-check sanity before performing them (with macOS) (fanquake)
- paydacoin/paydacoin#22405 Remove --enable-glibc-back-compat from Guix build (fanquake)
- paydacoin/paydacoin#22406 Remove --enable-determinism configure option (fanquake)
- paydacoin/paydacoin#22410 Avoid GCC 7.1 ABI change warning in guix build (sipa)
- paydacoin/paydacoin#22436 use aarch64 Clang if cross-compiling for darwin on aarch64 (fanquake)
- paydacoin/paydacoin#22465 guix: Pin kernel-header version, time-machine to upstream 1.3.0 commit (dongcarl)
- paydacoin/paydacoin#22511 guix: Silence `getent(1)` invocation, doc fixups (dongcarl)
- paydacoin/paydacoin#22531 guix: Fixes to guix-{attest,verify} (achow101)
- paydacoin/paydacoin#22642 release: Release with separate sha256sums and sig files (dongcarl)
- paydacoin/paydacoin#22685 clientversion: No suffix `#if CLIENT_VERSION_IS_RELEASE` (dongcarl)
- paydacoin/paydacoin#22713 Fix build with Boost 1.77.0 (sizeofvoid)

### Tests and QA
- paydacoin/paydacoin#14604 Add test and refactor `feature_block.py` (sanket1729)
- paydacoin/paydacoin#17556 Change `feature_config_args.py` not to rely on strange regtest=0 behavior (ryanofsky)
- paydacoin/paydacoin#18795 wallet issue with orphaned rewards (domob1812)
- paydacoin/paydacoin#18847 compressor: Use a prevector in CompressScript serialization (jb55)
- paydacoin/paydacoin#19259 fuzz: Add fuzzing harness for LoadMempool(…) and DumpMempool(…) (practicalswift)
- paydacoin/paydacoin#19315 Allow outbound & block-relay-only connections in functional tests. (amitiuttarwar)
- paydacoin/paydacoin#19698 Apply strict verification flags for transaction tests and assert backwards compatibility (glozow)
- paydacoin/paydacoin#19801 Check for all possible `OP_CLTV` fail reasons in `feature_cltv.py` (BIP 65) (theStack)
- paydacoin/paydacoin#19893 Remove or explain syncwithvalidationinterfacequeue (MarcoFalke)
- paydacoin/paydacoin#19972 fuzz: Add fuzzing harness for node eviction logic (practicalswift)
- paydacoin/paydacoin#19982 Fix inconsistent lock order in `wallet_tests/CreateWallet` (hebasto)
- paydacoin/paydacoin#20000 Fix creation of "std::string"s with \0s (vasild)
- paydacoin/paydacoin#20047 Use `wait_for_{block,header}` helpers in `p2p_fingerprint.py` (theStack)
- paydacoin/paydacoin#20171 Add functional test `test_txid_inv_delay` (ariard)
- paydacoin/paydacoin#20189 Switch to BIP341's suggested scheme for outputs without script (sipa)
- paydacoin/paydacoin#20248 Fix length of R check in `key_signature_tests` (dgpv)
- paydacoin/paydacoin#20276, paydacoin/paydacoin#20385, paydacoin/paydacoin#20688, paydacoin/paydacoin#20692 Run various mempool tests even with wallet disabled (mjdietzx)
- paydacoin/paydacoin#20323 Create or use existing properly initialized NodeContexts (dongcarl)
- paydacoin/paydacoin#20354 Add `feature_taproot.py --previous_release` (MarcoFalke)
- paydacoin/paydacoin#20370 fuzz: Version handshake (MarcoFalke)
- paydacoin/paydacoin#20377 fuzz: Fill various small fuzzing gaps (practicalswift)
- paydacoin/paydacoin#20425 fuzz: Make CAddrMan fuzzing harness deterministic (practicalswift)
- paydacoin/paydacoin#20430 Sanitizers: Add suppression for unsigned-integer-overflow in libstdc++ (jonasschnelli)
- paydacoin/paydacoin#20437 fuzz: Avoid time-based "non-determinism" in fuzzing harnesses by using mocked GetTime() (practicalswift)
- paydacoin/paydacoin#20458 Add `is_bdb_compiled` helper (Sjors)
- paydacoin/paydacoin#20466 Fix intermittent `p2p_fingerprint` issue (MarcoFalke)
- paydacoin/paydacoin#20472 Add testing of ParseInt/ParseUInt edge cases with leading +/-/0:s (practicalswift)
- paydacoin/paydacoin#20507 sync: print proper lock order location when double lock is detected (vasild)
- paydacoin/paydacoin#20522 Fix sync issue in `disconnect_p2ps` (amitiuttarwar)
- paydacoin/paydacoin#20524 Move `MIN_VERSION_SUPPORTED` to p2p.py (jnewbery)
- paydacoin/paydacoin#20540 Fix `wallet_multiwallet` issue on windows (MarcoFalke)
- paydacoin/paydacoin#20560 fuzz: Link all targets once (MarcoFalke)
- paydacoin/paydacoin#20567 Add option to git-subtree-check to do full check, add help (laanwj)
- paydacoin/paydacoin#20569 Fix intermittent `wallet_multiwallet` issue with `got_loading_error` (MarcoFalke)
- paydacoin/paydacoin#20613 Use Popen.wait instead of RPC in `assert_start_raises_init_error` (MarcoFalke)
- paydacoin/paydacoin#20663 fuzz: Hide `script_assets_test_minimizer` (MarcoFalke)
- paydacoin/paydacoin#20674 fuzz: Call SendMessages after ProcessMessage to increase coverage (MarcoFalke)
- paydacoin/paydacoin#20683 Fix restart node race (MarcoFalke)
- paydacoin/paydacoin#20686 fuzz: replace CNode code with fuzz/util.h::ConsumeNode() (jonatack)
- paydacoin/paydacoin#20733 Inline non-member functions with body in fuzzing headers (pstratem)
- paydacoin/paydacoin#20737 Add missing assignment in `mempool_resurrect.py` (MarcoFalke)
- paydacoin/paydacoin#20745 Correct `epoll_ctl` data race suppression (hebasto)
- paydacoin/paydacoin#20748 Add race:SendZmqMessage tsan suppression (MarcoFalke)
- paydacoin/paydacoin#20760 Set correct nValue for multi-op-return policy check (MarcoFalke)
- paydacoin/paydacoin#20761 fuzz: Check that `NULL_DATA` is unspendable (MarcoFalke)
- paydacoin/paydacoin#20765 fuzz: Check that certain script TxoutType are nonstandard (mjdietzx)
- paydacoin/paydacoin#20772 fuzz: Bolster ExtractDestination(s) checks (mjdietzx)
- paydacoin/paydacoin#20789 fuzz: Rework strong and weak net enum fuzzing (MarcoFalke)
- paydacoin/paydacoin#20828 fuzz: Introduce CallOneOf helper to replace switch-case (MarcoFalke)
- paydacoin/paydacoin#20839 fuzz: Avoid extraneous copy of input data, using Span<> (MarcoFalke)
- paydacoin/paydacoin#20844 Add sanitizer suppressions for AMD EPYC CPUs (MarcoFalke)
- paydacoin/paydacoin#20857 Update documentation in `feature_csv_activation.py` (PiRK)
- paydacoin/paydacoin#20876 Replace getmempoolentry with testmempoolaccept in MiniWallet (MarcoFalke)
- paydacoin/paydacoin#20881 fuzz: net permission flags in net processing (MarcoFalke)
- paydacoin/paydacoin#20882 fuzz: Add missing muhash registration (MarcoFalke)
- paydacoin/paydacoin#20908 fuzz: Use mocktime in `process_message*` fuzz targets (MarcoFalke)
- paydacoin/paydacoin#20915 fuzz: Fail if message type is not fuzzed (MarcoFalke)
- paydacoin/paydacoin#20946 fuzz: Consolidate fuzzing TestingSetup initialization (dongcarl)
- paydacoin/paydacoin#20954 Declare `nodes` type `in test_framework.py` (kiminuo)
- paydacoin/paydacoin#20955 Fix `get_previous_releases.py` for aarch64 (MarcoFalke)
- paydacoin/paydacoin#20969 check that getblockfilter RPC fails without block filter index (theStack)
- paydacoin/paydacoin#20971 Work around libFuzzer deadlock (MarcoFalke)
- paydacoin/paydacoin#20993 Store subversion (user agent) as string in `msg_version` (theStack)
- paydacoin/paydacoin#20995 fuzz: Avoid initializing version to less than `MIN_PEER_PROTO_VERSION` (MarcoFalke)
- paydacoin/paydacoin#20998 Fix BlockToJsonVerbose benchmark (martinus)
- paydacoin/paydacoin#21003 Move MakeNoLogFileContext to `libtest_util`, and use it in bench (MarcoFalke)
- paydacoin/paydacoin#21008 Fix zmq test flakiness, improve speed (theStack)
- paydacoin/paydacoin#21023 fuzz: Disable shuffle when merge=1 (MarcoFalke)
- paydacoin/paydacoin#21037 fuzz: Avoid designated initialization (C++20) in fuzz tests (practicalswift)
- paydacoin/paydacoin#21042 doc, test: Improve `setup_clean_chain` documentation (fjahr)
- paydacoin/paydacoin#21080 fuzz: Configure check for main function (take 2) (MarcoFalke)
- paydacoin/paydacoin#21084 Fix timeout decrease in `feature_assumevalid` (brunoerg)
- paydacoin/paydacoin#21096 Re-add dead code detection (flack)
- paydacoin/paydacoin#21100 Remove unused function `xor_bytes` (theStack)
- paydacoin/paydacoin#21115 Fix Windows cross build (hebasto)
- paydacoin/paydacoin#21117 Remove `assert_blockchain_height` (MarcoFalke)
- paydacoin/paydacoin#21121 Small unit test improvements, including helper to make mempool transaction (amitiuttarwar)
- paydacoin/paydacoin#21124 Remove unnecessary assignment in bdb (brunoerg)
- paydacoin/paydacoin#21125 Change `BOOST_CHECK` to `BOOST_CHECK_EQUAL` for paths (kiminuo)
- paydacoin/paydacoin#21142, paydacoin/paydacoin#21512 fuzz: Add `tx_pool` fuzz target (MarcoFalke)
- paydacoin/paydacoin#21165 Use mocktime in `test_seed_peers` (dhruv)
- paydacoin/paydacoin#21169 fuzz: Add RPC interface fuzzing. Increase fuzzing coverage from 65% to 70% (practicalswift)
- paydacoin/paydacoin#21170 bench: Add benchmark to write json into a string (martinus)
- paydacoin/paydacoin#21178 Run `mempool_reorg.py` even with wallet disabled (DariusParvin)
- paydacoin/paydacoin#21185 fuzz: Remove expensive and redundant muhash from crypto fuzz target (MarcoFalke)
- paydacoin/paydacoin#21200 Speed up `rpc_blockchain.py` by removing miniwallet.generate() (MarcoFalke)
- paydacoin/paydacoin#21211 Move `P2WSH_OP_TRUE` to shared test library (MarcoFalke)
- paydacoin/paydacoin#21228 Avoid comparision of integers with different signs (jonasschnelli)
- paydacoin/paydacoin#21230 Fix `NODE_NETWORK_LIMITED_MIN_BLOCKS` disconnection (MarcoFalke)
- paydacoin/paydacoin#21252 Add missing wait for sync to `feature_blockfilterindex_prune` (MarcoFalke)
- paydacoin/paydacoin#21254 Avoid connecting to real network when running tests (MarcoFalke)
- paydacoin/paydacoin#21264 fuzz: Two scripted diff renames (MarcoFalke)
- paydacoin/paydacoin#21280 Bug fix in `transaction_tests` (glozow)
- paydacoin/paydacoin#21293 Replace accidentally placed bit-OR with logical-OR (hebasto)
- paydacoin/paydacoin#21297 `feature_blockfilterindex_prune.py` improvements (jonatack)
- paydacoin/paydacoin#21310 zmq test: fix sync-up by matching notification to generated block (theStack)
- paydacoin/paydacoin#21334 Additional BIP9 tests (Sjors)
- paydacoin/paydacoin#21338 Add functional test for anchors.dat (brunoerg)
- paydacoin/paydacoin#21345 Bring `p2p_leak.py` up to date (mzumsande)
- paydacoin/paydacoin#21357 Unconditionally check for fRelay field in test framework (jarolrod)
- paydacoin/paydacoin#21358 fuzz: Add missing include (`test/util/setup_common.h`) (MarcoFalke)
- paydacoin/paydacoin#21371 fuzz: fix gcc Woverloaded-virtual build warnings (jonatack)
- paydacoin/paydacoin#21373 Generate fewer blocks in `feature_nulldummy` to fix timeouts, speed up (jonatack)
- paydacoin/paydacoin#21390 Test improvements for UTXO set hash tests (fjahr)
- paydacoin/paydacoin#21410 increase `rpc_timeout` for fundrawtx `test_transaction_too_large` (jonatack)
- paydacoin/paydacoin#21411 add logging, reduce blocks, move `sync_all` in `wallet_` groups (jonatack)
- paydacoin/paydacoin#21438 Add ParseUInt8() test coverage (jonatack)
- paydacoin/paydacoin#21443 fuzz: Implement `fuzzed_dns_lookup_function` as a lambda (practicalswift)
- paydacoin/paydacoin#21445 cirrus: Use SSD cluster for speedup (MarcoFalke)
- paydacoin/paydacoin#21477 Add test for CNetAddr::ToString IPv6 address formatting (RFC 5952) (practicalswift)
- paydacoin/paydacoin#21487 fuzz: Use ConsumeWeakEnum in addrman for service flags (MarcoFalke)
- paydacoin/paydacoin#21488 Add ParseUInt16() unit test and fuzz coverage (jonatack)
- paydacoin/paydacoin#21491 test: remove duplicate assertions in util_tests (jonatack)
- paydacoin/paydacoin#21522 fuzz: Use PickValue where possible (MarcoFalke)
- paydacoin/paydacoin#21531 remove qt byteswap compattests (fanquake)
- paydacoin/paydacoin#21557 small cleanup in RPCNestedTests tests (fanquake)
- paydacoin/paydacoin#21586 Add missing suppression for signed-integer-overflow:txmempool.cpp (MarcoFalke)
- paydacoin/paydacoin#21592 Remove option to make TestChain100Setup non-deterministic (MarcoFalke)
- paydacoin/paydacoin#21597 Document `race:validation_chainstatemanager_tests` suppression (MarcoFalke)
- paydacoin/paydacoin#21599 Replace file level integer overflow suppression with function level suppression (practicalswift)
- paydacoin/paydacoin#21604 Document why no symbol names can be used for suppressions (MarcoFalke)
- paydacoin/paydacoin#21606 fuzz: Extend psbt fuzz target a bit (MarcoFalke)
- paydacoin/paydacoin#21617 fuzz: Fix uninitialized read in i2p test (MarcoFalke)
- paydacoin/paydacoin#21630 fuzz: split FuzzedSock interface and implementation (vasild)
- paydacoin/paydacoin#21634 Skip SQLite fsyncs while testing (achow101)
- paydacoin/paydacoin#21669 Remove spurious double lock tsan suppressions by bumping to clang-12 (MarcoFalke)
- paydacoin/paydacoin#21676 Use mocktime to avoid intermittent failure in `rpc_tests` (MarcoFalke)
- paydacoin/paydacoin#21677 fuzz: Avoid use of low file descriptor ids (which may be in use) in FuzzedSock (practicalswift)
- paydacoin/paydacoin#21678 Fix TestPotentialDeadLockDetected suppression (hebasto)
- paydacoin/paydacoin#21689 Remove intermittently failing and not very meaningful `BOOST_CHECK` in `cnetaddr_basic` (practicalswift)
- paydacoin/paydacoin#21691 Check that no versionbits are re-used (MarcoFalke)
- paydacoin/paydacoin#21707 Extend functional tests for addr relay (mzumsande)
- paydacoin/paydacoin#21712 Test default `include_mempool` value of gettxout (promag)
- paydacoin/paydacoin#21738 Use clang-12 for ASAN, Add missing suppression (MarcoFalke)
- paydacoin/paydacoin#21740 add new python linter to check file names and permissions (windsok)
- paydacoin/paydacoin#21749 Bump shellcheck version (hebasto)
- paydacoin/paydacoin#21754 Run `feature_cltv` with MiniWallet (MarcoFalke)
- paydacoin/paydacoin#21762 Speed up `mempool_spend_coinbase.py` (MarcoFalke)
- paydacoin/paydacoin#21773 fuzz: Ensure prevout is consensus-valid (MarcoFalke)
- paydacoin/paydacoin#21777 Fix `feature_notifications.py` intermittent issue (MarcoFalke)
- paydacoin/paydacoin#21785 Fix intermittent issue in `p2p_addr_relay.py` (MarcoFalke)
- paydacoin/paydacoin#21787 Fix off-by-ones in `rpc_fundrawtransaction` assertions (jonatack)
- paydacoin/paydacoin#21792 Fix intermittent issue in `p2p_segwit.py` (MarcoFalke)
- paydacoin/paydacoin#21795 fuzz: Terminate immediately if a fuzzing harness tries to perform a DNS lookup (belt and suspenders) (practicalswift)
- paydacoin/paydacoin#21798 fuzz: Create a block template in `tx_pool` targets (MarcoFalke)
- paydacoin/paydacoin#21804 Speed up `p2p_segwit.py` (jnewbery)
- paydacoin/paydacoin#21810 fuzz: Various RPC fuzzer follow-ups (practicalswift)
- paydacoin/paydacoin#21814 Fix `feature_config_args.py` intermittent issue (MarcoFalke)
- paydacoin/paydacoin#21821 Add missing test for empty P2WSH redeem (MarcoFalke)
- paydacoin/paydacoin#21822 Resolve bug in `interface_paydacoin_cli.py` (klementtan)
- paydacoin/paydacoin#21846 fuzz: Add `-fsanitize=integer` suppression needed for RPC fuzzer (`generateblock`) (practicalswift)
- paydacoin/paydacoin#21849 fuzz: Limit toxic test globals to their respective scope (MarcoFalke)
- paydacoin/paydacoin#21867 use MiniWallet for `p2p_blocksonly.py` (theStack)
- paydacoin/paydacoin#21873 minor fixes & improvements for files linter test (windsok)
- paydacoin/paydacoin#21874 fuzz: Add `WRITE_ALL_FUZZ_TARGETS_AND_ABORT` (MarcoFalke)
- paydacoin/paydacoin#21884 fuzz: Remove unused --enable-danger-fuzz-link-all option (MarcoFalke)
- paydacoin/paydacoin#21890 fuzz: Limit ParseISO8601DateTime fuzzing to 32-bit (MarcoFalke)
- paydacoin/paydacoin#21891 fuzz: Remove strprintf test cases that are known to fail (MarcoFalke)
- paydacoin/paydacoin#21892 fuzz: Avoid excessively large min fee rate in `tx_pool` (MarcoFalke)
- paydacoin/paydacoin#21895 Add TSA annotations to the WorkQueue class members (hebasto)
- paydacoin/paydacoin#21900 use MiniWallet for `feature_csv_activation.py` (theStack)
- paydacoin/paydacoin#21909 fuzz: Limit max insertions in timedata fuzz test (MarcoFalke)
- paydacoin/paydacoin#21922 fuzz: Avoid timeout in EncodeBase58 (MarcoFalke)
- paydacoin/paydacoin#21927 fuzz: Run const CScript member functions only once (MarcoFalke)
- paydacoin/paydacoin#21929 fuzz: Remove incorrect float round-trip serialization test (MarcoFalke)
- paydacoin/paydacoin#21936 fuzz: Terminate immediately if a fuzzing harness tries to create a TCP socket (belt and suspenders) (practicalswift)
- paydacoin/paydacoin#21941 fuzz: Call const member functions in addrman fuzz test only once (MarcoFalke)
- paydacoin/paydacoin#21945 add P2PK support to MiniWallet (theStack)
- paydacoin/paydacoin#21948 Fix off-by-one in mockscheduler test RPC (MarcoFalke)
- paydacoin/paydacoin#21953 fuzz: Add `utxo_snapshot` target (MarcoFalke)
- paydacoin/paydacoin#21970 fuzz: Add missing CheckTransaction before CheckTxInputs (MarcoFalke)
- paydacoin/paydacoin#21989 Use `COINBASE_MATURITY` in functional tests (kiminuo)
- paydacoin/paydacoin#22003 Add thread safety annotations (ajtowns)
- paydacoin/paydacoin#22004 fuzz: Speed up transaction fuzz target (MarcoFalke)
- paydacoin/paydacoin#22005 fuzz: Speed up banman fuzz target (MarcoFalke)
- paydacoin/paydacoin#22029 [fuzz] Improve transport deserialization fuzz test coverage (dhruv)
- paydacoin/paydacoin#22048 MiniWallet: introduce enum type for output mode (theStack)
- paydacoin/paydacoin#22057 use MiniWallet (P2PK mode) for `feature_dersig.py` (theStack)
- paydacoin/paydacoin#22065 Mark `CheckTxInputs` `[[nodiscard]]`. Avoid UUM in fuzzing harness `coins_view` (practicalswift)
- paydacoin/paydacoin#22069 fuzz: don't try and use fopencookie() when building for Android (fanquake)
- paydacoin/paydacoin#22082 update nanobench from release 4.0.0 to 4.3.4 (martinus)
- paydacoin/paydacoin#22086 remove BasicTestingSetup from unit tests that don't need it (fanquake)
- paydacoin/paydacoin#22089 MiniWallet: fix fee calculation for P2PK and check tx vsize (theStack)
- paydacoin/paydacoin#21107, paydacoin/paydacoin#22092 Convert documentation into type annotations (fanquake)
- paydacoin/paydacoin#22095 Additional BIP32 test vector for hardened derivation with leading zeros (kristapsk)
- paydacoin/paydacoin#22103 Fix IPv6 check on BSD systems (n-thumann)
- paydacoin/paydacoin#22118 check anchors.dat when node starts for the first time (brunoerg)
- paydacoin/paydacoin#22120 `p2p_invalid_block`: Check that a block rejected due to too-new tim… (willcl-ark)
- paydacoin/paydacoin#22153 Fix `p2p_leak.py` intermittent failure (mzumsande)
- paydacoin/paydacoin#22169 p2p, rpc, fuzz: various tiny follow-ups (jonatack)
- paydacoin/paydacoin#22176 Correct outstanding -Werror=sign-compare errors (Empact)
- paydacoin/paydacoin#22180 fuzz: Increase branch coverage of the float fuzz target (MarcoFalke)
- paydacoin/paydacoin#22187 Add `sync_blocks` in `wallet_orphanedreward.py` (domob1812)
- paydacoin/paydacoin#22201 Fix TestShell to allow running in Jupyter Notebook (josibake)
- paydacoin/paydacoin#22202 Add temporary coinstats suppressions (MarcoFalke)
- paydacoin/paydacoin#22203 Use ConnmanTestMsg from test lib in `denialofservice_tests` (MarcoFalke)
- paydacoin/paydacoin#22210 Use MiniWallet in `test_no_inherited_signaling` RBF test (MarcoFalke)
- paydacoin/paydacoin#22224 Update msvc and appveyor builds to use Qt5.12.11 binaries (sipsorcery)
- paydacoin/paydacoin#22249 Kill process group to avoid dangling processes when using `--failfast` (S3RK)
- paydacoin/paydacoin#22267 fuzz: Speed up crypto fuzz target (MarcoFalke)
- paydacoin/paydacoin#22270 Add paydacoin-util tests (+refactors) (MarcoFalke)
- paydacoin/paydacoin#22271 fuzz: Assert roundtrip equality for `CPubKey` (theStack)
- paydacoin/paydacoin#22279 fuzz: add missing ECCVerifyHandle to `base_encode_decode` (apoelstra)
- paydacoin/paydacoin#22292 bench, doc: benchmarking updates and fixups (jonatack)
- paydacoin/paydacoin#22306 Improvements to `p2p_addr_relay.py` (amitiuttarwar)
- paydacoin/paydacoin#22310 Add functional test for replacement relay fee check (ariard)
- paydacoin/paydacoin#22311 Add missing syncwithvalidationinterfacequeue in `p2p_blockfilters` (MarcoFalke)
- paydacoin/paydacoin#22313 Add missing `sync_all` to `feature_coinstatsindex` (MarcoFalke)
- paydacoin/paydacoin#22322 fuzz: Check banman roundtrip (MarcoFalke)
- paydacoin/paydacoin#22363 Use `script_util` helpers for creating P2{PKH,SH,WPKH,WSH} scripts (theStack)
- paydacoin/paydacoin#22399 fuzz: Rework CTxDestination fuzzing (MarcoFalke)
- paydacoin/paydacoin#22408 add tests for `bad-txns-prevout-null` reject reason (theStack)
- paydacoin/paydacoin#22445 fuzz: Move implementations of non-template fuzz helpers from util.h to util.cpp (sriramdvt)
- paydacoin/paydacoin#22446 Fix `wallet_listdescriptors.py` if bdb is not compiled (hebasto)
- paydacoin/paydacoin#22447 Whitelist `rpc_rawtransaction` peers to speed up tests (jonatack)
- paydacoin/paydacoin#22742 Use proper target in `do_fund_send` (S3RK)

### Miscellaneous
- paydacoin/paydacoin#19337 sync: Detect double lock from the same thread (vasild)
- paydacoin/paydacoin#19809 log: Prefix log messages with function name and source code location if -logsourcelocations is set (practicalswift)
- paydacoin/paydacoin#19866 eBPF Linux tracepoints (jb55)
- paydacoin/paydacoin#20024 init: Fix incorrect warning "Reducing -maxconnections from N to N-1, because of system limitations" (practicalswift)
- paydacoin/paydacoin#20145 contrib: Add getcoins.py script to get coins from (signet) faucet (kallewoof)
- paydacoin/paydacoin#20255 util: Add assume() identity function (MarcoFalke)
- paydacoin/paydacoin#20288 script, doc: Contrib/seeds updates (jonatack)
- paydacoin/paydacoin#20358 src/randomenv.cpp: Fix build on uclibc (ffontaine)
- paydacoin/paydacoin#20406 util: Avoid invalid integer negation in formatmoney and valuefromamount (practicalswift)
- paydacoin/paydacoin#20434 contrib: Parse elf directly for symbol and security checks (laanwj)
- paydacoin/paydacoin#20451 lint: Run mypy over contrib/devtools (fanquake)
- paydacoin/paydacoin#20476 contrib: Add test for elf symbol-check (laanwj)
- paydacoin/paydacoin#20530 lint: Update cppcheck linter to c++17 and improve explicit usage (fjahr)
- paydacoin/paydacoin#20589 log: Clarify that failure to read/write `fee_estimates.dat` is non-fatal (MarcoFalke)
- paydacoin/paydacoin#20602 util: Allow use of c++14 chrono literals (MarcoFalke)
- paydacoin/paydacoin#20605 init: Signal-safe instant shutdown (laanwj)
- paydacoin/paydacoin#20608 contrib: Add symbol check test for PE binaries (fanquake)
- paydacoin/paydacoin#20689 contrib: Replace binary verification script verify.sh with python rewrite (theStack)
- paydacoin/paydacoin#20715 util: Add argsmanager::getcommand() and use it in paydacoin-wallet (MarcoFalke)
- paydacoin/paydacoin#20735 script: Remove outdated extract-osx-sdk.sh (hebasto)
- paydacoin/paydacoin#20817 lint: Update list of spelling linter false positives, bump to codespell 2.0.0 (theStack)
- paydacoin/paydacoin#20884 script: Improve robustness of paydacoind.service on startup (hebasto)
- paydacoin/paydacoin#20906 contrib: Embed c++11 patch in `install_db4.sh` (gruve-p)
- paydacoin/paydacoin#21004 contrib: Fix docker args conditional in gitian-build (setpill)
- paydacoin/paydacoin#21007 paydacoind: Add -daemonwait option to wait for initialization (laanwj)
- paydacoin/paydacoin#21041 log: Move "Pre-allocating up to position 0x[…] in […].dat" log message to debug category (practicalswift)
- paydacoin/paydacoin#21059 Drop boost/preprocessor dependencies (hebasto)
- paydacoin/paydacoin#21087 guix: Passthrough `BASE_CACHE` into container (dongcarl)
- paydacoin/paydacoin#21088 guix: Jump forwards in time-machine and adapt (dongcarl)
- paydacoin/paydacoin#21089 guix: Add support for powerpc64{,le} (dongcarl)
- paydacoin/paydacoin#21110 util: Remove boost `posix_time` usage from `gettime*` (fanquake)
- paydacoin/paydacoin#21111 Improve OpenRC initscript (parazyd)
- paydacoin/paydacoin#21123 code style: Add EditorConfig file (kiminuo)
- paydacoin/paydacoin#21173 util: Faster hexstr => 13% faster blocktojson (martinus)
- paydacoin/paydacoin#21221 tools: Allow argument/parameter bin packing in clang-format (jnewbery)
- paydacoin/paydacoin#21244 Move GetDataDir to ArgsManager (kiminuo)
- paydacoin/paydacoin#21255 contrib: Run test-symbol-check for risc-v (fanquake)
- paydacoin/paydacoin#21271 guix: Explicitly set umask in build container (dongcarl)
- paydacoin/paydacoin#21300 script: Add explanatory comment to tc.sh (dscotese)
- paydacoin/paydacoin#21317 util: Make assume() usable as unary expression (MarcoFalke)
- paydacoin/paydacoin#21336 Make .gitignore ignore src/test/fuzz/fuzz.exe (hebasto)
- paydacoin/paydacoin#21337 guix: Update darwin native packages dependencies (hebasto)
- paydacoin/paydacoin#21405 compat: remove memcpy -> memmove backwards compatibility alias (fanquake)
- paydacoin/paydacoin#21418 contrib: Make systemd invoke dependencies only when ready (laanwj)
- paydacoin/paydacoin#21447 Always add -daemonwait to known command line arguments (hebasto)
- paydacoin/paydacoin#21471 bugfix: Fix `bech32_encode` calls in `gen_key_io_test_vectors.py` (sipa)
- paydacoin/paydacoin#21615 script: Add trusted key for hebasto (hebasto)
- paydacoin/paydacoin#21664 contrib: Use lief for macos and windows symbol & security checks (fanquake)
- paydacoin/paydacoin#21695 contrib: Remove no longer used contrib/paydacoin-qt.pro (hebasto)
- paydacoin/paydacoin#21711 guix: Add full installation and usage documentation (dongcarl)
- paydacoin/paydacoin#21799 guix: Use `gcc-8` across the board (dongcarl)
- paydacoin/paydacoin#21802 Avoid UB in util/asmap (advance a dereferenceable iterator outside its valid range) (MarcoFalke)
- paydacoin/paydacoin#21823 script: Update reviewers (jonatack)
- paydacoin/paydacoin#21850 Remove `GetDataDir(net_specific)` function (kiminuo)
- paydacoin/paydacoin#21871 scripts: Add checks for minimum required os versions (fanquake)
- paydacoin/paydacoin#21966 Remove double serialization; use software encoder for fee estimation (sipa)
- paydacoin/paydacoin#22060 contrib: Add torv3 seed nodes for testnet, drop v2 ones (laanwj)
- paydacoin/paydacoin#22244 devtools: Correctly extract symbol versions in symbol-check (laanwj)
- paydacoin/paydacoin#22533 guix/build: Remove vestigial SKIPATTEST.TAG (dongcarl)
- paydacoin/paydacoin#22643 guix-verify: Non-zero exit code when anything fails (dongcarl)
- paydacoin/paydacoin#22654 guix: Don't include directory name in SHA256SUMS (achow101)

### Documentation
- paydacoin/paydacoin#15451 clarify getdata limit after #14897 (HashUnlimited)
- paydacoin/paydacoin#15545 Explain why CheckBlock() is called before AcceptBlock (Sjors)
- paydacoin/paydacoin#17350 Add developer documentation to isminetype (HAOYUatHZ)
- paydacoin/paydacoin#17934 Use `CONFIG_SITE` variable instead of --prefix option (hebasto)
- paydacoin/paydacoin#18030 Coin::IsSpent() can also mean never existed (Sjors)
- paydacoin/paydacoin#18096 IsFinalTx comment about nSequence & `OP_CLTV` (nothingmuch)
- paydacoin/paydacoin#18568 Clarify developer notes about constant naming (ryanofsky)
- paydacoin/paydacoin#19961 doc: tor.md updates (jonatack)
- paydacoin/paydacoin#19968 Clarify CRollingBloomFilter size estimate (robot-dreams)
- paydacoin/paydacoin#20200 Rename CODEOWNERS to REVIEWERS (adamjonas)
- paydacoin/paydacoin#20329 docs/descriptors.md: Remove hardened marker in the path after xpub (dgpv)
- paydacoin/paydacoin#20380 Add instructions on how to fuzz the P2P layer using Honggfuzz NetDriver (practicalswift)
- paydacoin/paydacoin#20414 Remove generated manual pages from master branch (laanwj)
- paydacoin/paydacoin#20473 Document current boost dependency as 1.71.0 (laanwj)
- paydacoin/paydacoin#20512 Add bash as an OpenBSD dependency (emilengler)
- paydacoin/paydacoin#20568 Use FeeModes doc helper in estimatesmartfee (MarcoFalke)
- paydacoin/paydacoin#20577 libconsensus: add missing error code description, fix NPaydacoin link (theStack)
- paydacoin/paydacoin#20587 Tidy up Tor doc (more stringent) (wodry)
- paydacoin/paydacoin#20592 Update wtxidrelay documentation per BIP339 (jonatack)
- paydacoin/paydacoin#20601 Update for FreeBSD 12.2, add GUI Build Instructions (jarolrod)
- paydacoin/paydacoin#20635 fix misleading comment about call to non-existing function (pox)
- paydacoin/paydacoin#20646 Refer to BIPs 339/155 in feature negotiation (jonatack)
- paydacoin/paydacoin#20653 Move addr relay comment in net to correct place (MarcoFalke)
- paydacoin/paydacoin#20677 Remove shouty enums in `net_processing` comments (sdaftuar)
- paydacoin/paydacoin#20741 Update 'Secure string handling' (prayank23)
- paydacoin/paydacoin#20757 tor.md and -onlynet help updates (jonatack)
- paydacoin/paydacoin#20829 Add -netinfo help (jonatack)
- paydacoin/paydacoin#20830 Update developer notes with signet (jonatack)
- paydacoin/paydacoin#20890 Add explicit macdeployqtplus dependencies install step (hebasto)
- paydacoin/paydacoin#20913 Add manual page generation for paydacoin-util (laanwj)
- paydacoin/paydacoin#20985 Add xorriso to macOS depends packages (fanquake)
- paydacoin/paydacoin#20986 Update developer notes to discourage very long lines (jnewbery)
- paydacoin/paydacoin#20987 Add instructions for generating RPC docs (ben-kaufman)
- paydacoin/paydacoin#21026 Document use of make-tag script to make tags (laanwj)
- paydacoin/paydacoin#21028 doc/bips: Add BIPs 43, 44, 49, and 84 (luke-jr)
- paydacoin/paydacoin#21049 Add release notes for listdescriptors RPC (S3RK)
- paydacoin/paydacoin#21060 More precise -debug and -debugexclude doc (wodry)
- paydacoin/paydacoin#21077 Clarify -timeout and -peertimeout config options (glozow)
- paydacoin/paydacoin#21105 Correctly identify script type (niftynei)
- paydacoin/paydacoin#21163 Guix is shipped in Debian and Ubuntu (MarcoFalke)
- paydacoin/paydacoin#21210 Rework internal and external links (MarcoFalke)
- paydacoin/paydacoin#21246 Correction for VerifyTaprootCommitment comments (roconnor-blockstream)
- paydacoin/paydacoin#21263 Clarify that squashing should happen before review (MarcoFalke)
- paydacoin/paydacoin#21323 guix, doc: Update default HOSTS value (hebasto)
- paydacoin/paydacoin#21324 Update build instructions for Fedora (hebasto)
- paydacoin/paydacoin#21343 Revamp macOS build doc (jarolrod)
- paydacoin/paydacoin#21346 install qt5 when building on macOS (fanquake)
- paydacoin/paydacoin#21384 doc: add signet to paydacoin.conf documentation (jonatack)
- paydacoin/paydacoin#21394 Improve comment about protected peers (amitiuttarwar)
- paydacoin/paydacoin#21398 Update fuzzing docs for afl-clang-lto (MarcoFalke)
- paydacoin/paydacoin#21444 net, doc: Doxygen updates and fixes in netbase.{h,cpp} (jonatack)
- paydacoin/paydacoin#21481 Tell howto install clang-format on Debian/Ubuntu (wodry)
- paydacoin/paydacoin#21567 Fix various misleading comments (glozow)
- paydacoin/paydacoin#21661 Fix name of script guix-build (Emzy)
- paydacoin/paydacoin#21672 Remove boostrap info from `GUIX_COMMON_FLAGS` doc (fanquake)
- paydacoin/paydacoin#21688 Note on SDK for macOS depends cross-compile (jarolrod)
- paydacoin/paydacoin#21709 Update reduce-memory.md and paydacoin.conf -maxconnections info (jonatack)
- paydacoin/paydacoin#21710 update helps for addnode rpc and -addnode/-maxconnections config options (jonatack)
- paydacoin/paydacoin#21752 Clarify that feerates are per virtual size (MarcoFalke)
- paydacoin/paydacoin#21811 Remove Visual Studio 2017 reference from readme (sipsorcery)
- paydacoin/paydacoin#21818 Fixup -coinstatsindex help, update paydacoin.conf and files.md (jonatack)
- paydacoin/paydacoin#21856 add OSS-Fuzz section to fuzzing.md doc (adamjonas)
- paydacoin/paydacoin#21912 Remove mention of priority estimation (MarcoFalke)
- paydacoin/paydacoin#21925 Update bips.md for 0.21.1 (MarcoFalke)
- paydacoin/paydacoin#21942 improve make with parallel jobs description (klementtan)
- paydacoin/paydacoin#21947 Fix OSS-Fuzz links (MarcoFalke)
- paydacoin/paydacoin#21988 note that brew installed qt is not supported (jarolrod)
- paydacoin/paydacoin#22056 describe in fuzzing.md how to reproduce a CI crash (jonatack)
- paydacoin/paydacoin#22080 add maxuploadtarget to paydacoin.conf example (jarolrod)
- paydacoin/paydacoin#22088 Improve note on choosing posix mingw32 (jarolrod)
- paydacoin/paydacoin#22109 Fix external links (IRC, …) (MarcoFalke)
- paydacoin/paydacoin#22121 Various validation doc fixups (MarcoFalke)
- paydacoin/paydacoin#22172 Update tor.md, release notes with removal of tor v2 support (jonatack)
- paydacoin/paydacoin#22204 Remove obsolete `okSafeMode` RPC guideline from developer notes (theStack)
- paydacoin/paydacoin#22208 Update `REVIEWERS` (practicalswift)
- paydacoin/paydacoin#22250 add basic I2P documentation (vasild)
- paydacoin/paydacoin#22296 Final merge of release notes snippets, mv to wiki (MarcoFalke)
- paydacoin/paydacoin#22335 recommend `--disable-external-signer` in OpenBSD build guide (theStack)
- paydacoin/paydacoin#22339 Document minimum required libc++ version (hebasto)
- paydacoin/paydacoin#22349 Repository IRC updates (jonatack)
- paydacoin/paydacoin#22360 Remove unused section from release process (MarcoFalke)
- paydacoin/paydacoin#22369 Add steps for Transifex to release process (jonatack)
- paydacoin/paydacoin#22393 Added info to paydacoin.conf doc (bliotti)
- paydacoin/paydacoin#22402 Install Rosetta on M1-macOS for qt in depends (hebasto)
- paydacoin/paydacoin#22432 Fix incorrect `testmempoolaccept` doc (glozow)
- paydacoin/paydacoin#22648 doc, test: improve i2p/tor docs and i2p reachable unit tests (jonatack)

Credits
=======

Thanks to everyone who directly contributed to this release:

- Aaron Clauson
- Adam Jonas
- amadeuszpawlik
- Amiti Uttarwar
- Andrew Chow
- Andrew Poelstra
- Anthony Towns
- Antoine Poinsot
- Antoine Riard
- apawlik
- apitko
- Ben Carman
- Ben Woosley
- benk10
- Bezdrighin
- Block Mechanic
- Brian Liotti
- Bruno Garcia
- Carl Dong
- Christian Decker
- coinforensics
- Cory Fields
- Dan Benjamin
- Daniel Kraft
- Darius Parvin
- Dhruv Mehta
- Dmitry Goncharov
- Dmitry Petukhov
- dplusplus1024
- dscotese
- Duncan Dean
- Elle Mouton
- Elliott Jin
- Emil Engler
- Ethan Heilman
- eugene
- Evan Klitzke
- Fabian Jahr
- Fabrice Fontaine
- fanquake
- fdov
- flack
- Fotis Koutoupas
- Fu Yong Quah
- fyquah
- glozow
- Gregory Sanders
- Guido Vranken
- Gunar C. Gessner
- h
- HAOYUatHZ
- Hennadii Stepanov
- Igor Cota
- Ikko Ashimine
- Ivan Metlushko
- jackielove4u
- James O'Beirne
- Jarol Rodriguez
- Joel Klabo
- John Newbery
- Jon Atack
- Jonas Schnelli
- João Barbosa
- Josiah Baker
- Karl-Johan Alm
- Kiminuo
- Klement Tan
- Kristaps Kaupe
- Larry Ruane
- lisa neigut
- Lucas Ontivero
- Luke Dashjr
- Maayan Keshet
- MarcoFalke
- Martin Ankerl
- Martin Zumsande
- Michael Dietz
- Michael Polzer
- Michael Tidwell
- Niklas Gögge
- nthumann
- Oliver Gugger
- parazyd
- Patrick Strateman
- Pavol Rusnak
- Peter Bushnell
- Pierre K
- Pieter Wuille
- PiRK
- pox
- practicalswift
- Prayank
- R E Broadley
- Rafael Sadowski
- randymcmillan
- Raul Siles
- Riccardo Spagni
- Russell O'Connor
- Russell Yanofsky
- S3RK
- saibato
- Samuel Dobson
- sanket1729
- Sawyer Billings
- Sebastian Falbesoner
- setpill
- sgulls
- sinetek
- Sjors Provoost
- Sriram
- Stephan Oeste
- Suhas Daftuar
- Sylvain Goumy
- t-bast
- Troy Giorshev
- Tushar Singla
- Tyler Chambers
- Uplab
- Vasil Dimov
- W. J. van der Laan
- willcl-ark
- William Bright
- William Casarin
- windsok
- wodry
- Yerzhan Mazhkenov
- Yuval Kogman
- Zero

As well as to everyone that helped with translations on
[Transifex](https://www.transifex.com/paydacoin/paydacoin/).

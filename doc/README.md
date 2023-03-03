Paydacoin Core
=============

Setup
---------------------
Paydacoin Core is the original Paydacoin client and it builds the backbone of the network. It downloads and, by default, stores the entire history of Paydacoin transactions, which requires a few hundred gigabytes of disk space. Depending on the speed of your computer and network connection, the synchronization process can take anywhere from a few hours to a day or more.

To download Paydacoin Core, visit [paydacoincore.org](https://paydacoincore.org/en/download/).

Running
---------------------
The following are some helpful notes on how to run Paydacoin Core on your native platform.

### Unix

Unpack the files into a directory and run:

- `bin/paydacoin-qt` (GUI) or
- `bin/paydacoind` (headless)

### Windows

Unpack the files into a directory, and then run paydacoin-qt.exe.

### macOS

Drag Paydacoin Core to your applications folder, and then run Paydacoin Core.

### Need Help?

* See the documentation at the [Paydacoin Wiki](https://en.paydacoin.it/wiki/Main_Page)
for help and more information.
* Ask for help on [Paydacoin StackExchange](https://paydacoin.stackexchange.com).
* Ask for help on #paydacoin on Libera Chat. If you don't have an IRC client, you can use [web.libera.chat](https://web.libera.chat/#paydacoin).
* Ask for help on the [PaydacoinTalk](https://paydacointalk.org/) forums, in the [Technical Support board](https://paydacointalk.org/index.php?board=4.0).

Building
---------------------
The following are developer notes on how to build Paydacoin Core on your native platform. They are not complete guides, but include notes on the necessary libraries, compile flags, etc.

- [Dependencies](dependencies.md)
- [macOS Build Notes](build-osx.md)
- [Unix Build Notes](build-unix.md)
- [Windows Build Notes](build-windows.md)
- [FreeBSD Build Notes](build-freebsd.md)
- [OpenBSD Build Notes](build-openbsd.md)
- [NetBSD Build Notes](build-netbsd.md)
- [Android Build Notes](build-android.md)

Development
---------------------
The Paydacoin repo's [root README](/README.md) contains relevant information on the development process and automated testing.

- [Developer Notes](developer-notes.md)
- [Productivity Notes](productivity.md)
- [Release Process](release-process.md)
- [Source Code Documentation (External Link)](https://doxygen.paydacoincore.org/)
- [Translation Process](translation_process.md)
- [Translation Strings Policy](translation_strings_policy.md)
- [JSON-RPC Interface](JSON-RPC-interface.md)
- [Unauthenticated REST Interface](REST-interface.md)
- [Shared Libraries](shared-libraries.md)
- [BIPS](bips.md)
- [Dnsseed Policy](dnsseed-policy.md)
- [Benchmarking](benchmarking.md)
- [Internal Design Docs](design/)

### Resources
* Discuss on the [PaydacoinTalk](https://paydacointalk.org/) forums, in the [Development & Technical Discussion board](https://paydacointalk.org/index.php?board=6.0).
* Discuss project-specific development on #paydacoin-core-dev on Libera Chat. If you don't have an IRC client, you can use [web.libera.chat](https://web.libera.chat/#paydacoin-core-dev).

### Miscellaneous
- [Assets Attribution](assets-attribution.md)
- [paydacoin.conf Configuration File](paydacoin-conf.md)
- [CJDNS Support](cjdns.md)
- [Files](files.md)
- [Fuzz-testing](fuzzing.md)
- [I2P Support](i2p.md)
- [Init Scripts (systemd/upstart/openrc)](init.md)
- [Managing Wallets](managing-wallets.md)
- [Multisig Tutorial](multisig-tutorial.md)
- [P2P bad ports definition and list](p2p-bad-ports.md)
- [PSBT support](psbt.md)
- [Reduce Memory](reduce-memory.md)
- [Reduce Traffic](reduce-traffic.md)
- [Tor Support](tor.md)
- [Transaction Relay Policy](policy/README.md)
- [ZMQ](zmq.md)

License
---------------------
Distributed under the [MIT software license](/COPYING).

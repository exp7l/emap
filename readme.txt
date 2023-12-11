Emap is a fork of Dmap https://github.com/dapphub/dmap/tree/master

It is an implementation of a ultra-minimal name service, everything under 150 lines of code.

Here some example dpaths, each path resolves to a key-value map
where value can be any arbitrary Solidity ABI type.

             # means accessing a key                           resolves to a tuple of ABI type and bytes
             v                                                    v
:free.vitalik#primary-address                                 => ("(addreess)", b"0x123...")
     ^
     . means the map vitalik is mutable and can resolve to different resources in the future

:free:staking-contract#author                                 => ("(string)", "Alice")
^    ^  
     : means the name is immutable
       if the entire path is : seperated, it means the entire path is immutable and is guranteed to always resolve to same resources


The emphasis is on strictness and immutability.

To this end, the requirements are:

* "centralized" name resolution, everything is resolved with 1 contract object and the rules are the same for all names
* allows users to have custom registrars so custom rules around e.g. fees can be customized
* name is bought not rented, unlike Ethereum Name Service
* supports forward resolution (name to resources) and reverse (resources to name)


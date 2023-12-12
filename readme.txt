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

* you can lock a name that you own, your registrar cannot unlock it
* name registrations can be delegated eg owner of the ":free" registrar can delegate name registrations to another registrar such as ":free:maker-dao"

============
deployment
============

      "contractName": "RootAppraiser"
      "contractAddress": "0x11500Bee195242968D901b1352AdA3810CA0f5DB"

      "contractName": "RootRegistrar"
      "contractAddress": "0x777E03f58dF6079E536847E98EfF506F8558B3f4"

      "contractName": "Emap"
      "contractAddress": "0x07AB50AaBb1c11359eBBec4c9eBd64Bd38Fe2Bcb"

      "contractName": "FreeRegistrar"
      "contractAddress": "0xef8cfCb8e5C8a3142F5053CD4b9206BeC072B540"

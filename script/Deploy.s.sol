// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Emap} from "../src/Emap.sol";
import {RootRegistrar} from "../src/RootRegistrar.sol";
import {FreeRegistrar} from "../src/FreeRegistrar.sol";
import {RootAppraiser} from "../src/RootAppraiser.sol";

contract DeployScript is Script {
    Emap public emap;
    RootAppraiser rootAppraiser;
    RootRegistrar rootRegistrar;
    FreeRegistrar freeRegistrar;

    function _setUp(address gov) internal {
        // deploy root registrar
        rootAppraiser = new RootAppraiser();
        rootRegistrar = new RootRegistrar(address(rootAppraiser), gov);
        // deploy emap
        emap = new Emap(address(rootRegistrar));
        // deploy free registrar
        freeRegistrar = new FreeRegistrar(address(emap));
        // add emap address into root registrar
        rootRegistrar.configure(3, address(emap));

        // add free registrar to root registrar i.e. map "free" to the free registrar's address
        uint256 salt = 42;
        string memory free = "free";
        bytes32 hash = keccak256(abi.encode(salt, free, address(freeRegistrar)));
        rootRegistrar.commit(hash);
        rootRegistrar.set(salt, free, address(freeRegistrar));

        string memory testName = "staking-contract";
        string memory testKey = "address";
        string memory testMeta = "(address)";
        bytes memory testData = abi.encode(0x00000000219ab540356cBB839Cbe05303d7705Fa);
        freeRegistrar.take(testName);
        freeRegistrar.set(testName, testKey, testMeta, testData);
    }

    function run() public {
        string memory m = vm.envString("SEEDPHRASE");
        uint256 sk = vm.deriveKey(m, 0);
        address gov = vm.envAddress("GOV");
        vm.startBroadcast(sk);
        _setUp(gov);
        vm.stopBroadcast();
    }
}

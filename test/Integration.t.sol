/// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {Emap} from "../src/Emap.sol";
import {RootRegistrar, RootAppraiser} from "../src/RootRegistrar.sol";
import {FreeRegistrar} from "../src/FreeRegistrar.sol";

contract IntegrationTest is Test {
    Emap public emap;
    RootAppraiser rootAppraiser;
    RootRegistrar rootRegistrar;
    FreeRegistrar freeRegistrar;

    function setUp() public {
        // warp to the time where we can commit
        vm.warp(24 hours);
        // deploy root registrar
        rootAppraiser = new RootAppraiser();
        rootRegistrar = new RootRegistrar(address(rootAppraiser), address(this));
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
    }

    function test_Resolve() public {
        // set up for test
        string memory testName = "staking-contract";
        string memory testKey = "my-address";
        string memory testMeta = "(bytes)";
        bytes memory testData = abi.encode(0x00000000219ab540356cBB839Cbe05303d7705Fa);
        freeRegistrar.take(testName);
        freeRegistrar.emap();
        freeRegistrar.set(
            testName, 
            testKey,
            testMeta,
            testData
        );

        // walk from root registrar to lowest level registrar
        string[1] memory labels = ["free"];
        string[1] memory keys = ["REGISTRAR"];
        address registrar = emap.ROOT_REGISTRAR();
        bytes32 slot;
        string memory meta;
        bytes memory data;
        uint256 len = labels.length;
        for (uint256 i=0; i < len; i++) {
            string memory label = labels[i];
            string memory key = keys[i];
            slot = keccak256(abi.encode(registrar, label));
            (meta, data) = emap.valueStore(slot, key);
            registrar = abi.decode(data, (address));
        }

        // registrar is the free registrar
        slot = keccak256(abi.encode(registrar, testName));
        // get value from the free registrar
        (meta, data) = emap.valueStore(slot, testKey);

        require(keccak256(abi.encode(meta)) == keccak256(abi.encode(testMeta)), "ERR_TEST_META");
        require(keccak256(data) == keccak256(testData), "ERR_TEST_DATA");
    }
}

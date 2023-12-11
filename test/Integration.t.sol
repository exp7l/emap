// SPDX-License-Identifier: UNLICENSED
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

    function _setUp() internal {
        vm.warp(24 hours);
        rootAppraiser = new RootAppraiser();
        rootRegistrar = new RootRegistrar(address(rootAppraiser), address(this));
        emap = new Emap(address(rootRegistrar));
        freeRegistrar = new FreeRegistrar(address(emap));
        rootRegistrar.configure(3, address(emap));

        uint256 salt = 42;
        string memory free = "free";
        bytes32 hash = keccak256(abi.encode(salt, free, address(freeRegistrar)));
        rootRegistrar.commit(hash);
        rootRegistrar.set(salt, free, address(freeRegistrar));


    }

    function setUp() public {
        _setUp();
    }

    function test_Resolve() public {
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

        string[2] memory labels = ["free", testName];
        string[2] memory keys = ["REGISTRAR",testKey];
        bool[2] memory locks = [true, true];
        string memory key = "address";
        address registrar = emap.ROOT_REGISTRAR();
        bytes32 slot;
        string memory meta;
        bytes memory data;
        uint256 len = labels.length;
        for (uint256 i=0; i < len - 1; i++) {
            string memory label = labels[i];
            string memory key = keys[i];
            slot = keccak256(abi.encode(registrar, label));
            (meta, data) = emap.valueStore(slot, key);
            registrar = abi.decode(data, (address));
            // console.log(meta);
            // console.log(data);
        }
        slot = keccak256(abi.encode(registrar, labels[len - 1]));
        (meta, data) = emap.valueStore(slot, keys[len - 1]);

        require(keccak256(abi.encode(meta)) == keccak256(abi.encode(testMeta)), "ERR_TEST_META");
        require(keccak256(data) == keccak256(testData), "ERR_TEST_DATA");
    }
}

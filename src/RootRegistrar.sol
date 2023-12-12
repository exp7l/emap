/// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.13;

import {Emap} from "./Emap.sol";

interface AppraiserLike {
    function appraise(string calldata name) external view returns (uint256 value);
}

contract RootRegistrar {
    address public emap;
    uint256 public last;
    uint256 public paid;
    bytes32 public commitment;
    address public appraiser;
    address public gov;
    mapping(uint8 => bool) abdicated;
    uint256 immutable FREQ = 24 hours;

    event Commit(address indexed caller, bytes32 hash, uint256 paid);
    event Set(address indexed caller, string indexed name, address indexed zone);
    event Configure(address indexed caller, uint8 which, address data);
    event Abdicate(uint8 which);

    constructor(address a, address g) {
        appraiser = a;
        gov = g;
    }

    function commit(bytes32 hash) external payable {
        require(block.timestamp >= last + FREQ, "ERR_PENDING");
        last = block.timestamp;
        paid = msg.value;
        commitment = hash;
        payable(gov).call{value: msg.value}("");
        emit Commit(msg.sender, hash, msg.value);
    }

    function set(uint256 salt, string calldata name, address registrar) external {
        bytes32 hash = keccak256(abi.encode(salt, name, registrar));
        require(hash == commitment, "ERR_EXPIRED");
        emit Set(msg.sender, name, registrar);
        require(paid >= AppraiserLike(appraiser).appraise(name), "ERR_PAID");
        Emap(emap).set(name, Emap(emap).REGISTRAR(), "(address)", abi.encode(registrar));
        Emap(emap).set(name, Emap(emap).LOCK(), "(bool)", abi.encode(true));
    }

    function abdicate(uint8 which) external {
        abdicated[which] = true;
        emit Abdicate(which);
    }

    function configure(uint8 which, address data) external {
        require(msg.sender == gov, "ERR_GOV");
        require(!abdicated[which], "ERR_ABDICATED");
        if (which == 1) gov = data;
        else if (which == 2) appraiser = data;
        else if (which == 3 && emap == address(0)) emap = data;
        else revert("ERR_WHICH");
        emit Configure(msg.sender, which, data);
    }
}

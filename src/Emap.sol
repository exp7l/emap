/// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.13;

contract Emap {
    struct Value {
        string meta;
        bytes data;
    }

    mapping(bytes32 => string[]) public keyStore;
    mapping(bytes32 => mapping(string => Value)) public valueStore;
    address public immutable ROOT_REGISTRAR;

    event Set(address indexed caller, string indexed name, string indexed key, string meta, bytes data);
    event Unset(address indexed caller, string indexed name, string indexed key);

    constructor(address root) {
        ROOT_REGISTRAR = root;
    }

    function set(string calldata name, string calldata key, string calldata meta, bytes calldata data) external {
        bytes32 slot = keccak256(abi.encode(msg.sender, name));
        require(valueStore[slot][LOCK()].data.length == 0, "ERR_LOCK");
        _unset(slot, key);
        keyStore[slot].push(key);
        valueStore[slot][key] = Value({meta: meta, data: data});
        emit Set(msg.sender, name, key, meta, data);
    }

    function unset(string calldata name, string calldata key) external {
        bytes32 slot = keccak256(abi.encode(msg.sender, name));
        require(valueStore[slot][LOCK()].data.length == 0, "ERR_LOCK");
        require(keccak256(abi.encode(LOCK())) != keccak256(abi.encode(key)), "ERR_UNSET_LOCK");
        _unset(slot, key);
        emit Unset(msg.sender, name, key);
    }

    function _unset(bytes32 slot, string calldata key) internal {
        delete valueStore[slot][key];
        uint256 len = keyStore[slot].length;
        for (uint256 i = 0; i < len; ++i) {
            if (keccak256(abi.encode(keyStore[slot][i])) == keccak256(abi.encode(key))) {
                keyStore[slot][i] = keyStore[slot][len - 1];
                keyStore[slot].pop();
                return;
            }
        }
    }

    function keys(address registrar, string calldata name) external view returns (string[] memory) {
        bytes32 slot = keccak256(abi.encode(registrar, name));
        return keyStore[slot];
    }

    function LOCK() public pure returns (string memory) {
        return "LOCK";
    }

    function REGISTRAR() external pure returns (string memory) {
        return "REGISTRAR";
    }
}

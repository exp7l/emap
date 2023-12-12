/// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.13;

contract RootAppraiser {
    function appraise(string calldata name) external pure returns (uint256) {
        if (keccak256(abi.encode(name)) == keccak256(abi.encode("free"))) {
            return 0;
        } else {
            revert("ERR_NAME");
        }
    }
}

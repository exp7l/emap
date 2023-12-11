import {Emap} from "./Emap.sol";
import "forge-std/Test.sol";

contract FreeRegistrar is Test {
    address public immutable emap;
    uint256 public last;
    mapping(string => address) public controllers;

    event Give(address indexed giver, string indexed zone, address indexed recipient);

    constructor(address e) {
        emap = e;
    }

    function take(string calldata name) external {
        require(controllers[name] == address(0), "ERR_TAKEN");
        require(block.timestamp > last, "ERR_LIMIT");
        last = block.timestamp;
        controllers[name] = msg.sender;
        emit Give(address(0), name, msg.sender);
    }

    function give(string calldata name, address recipient) external {
        require(controllers[name] == msg.sender, "ERR_OWNER");
        controllers[name] = recipient;
        emit Give(msg.sender, name, recipient);
    }

    function set(string calldata name, string calldata key, string calldata meta, bytes calldata data) external {
        console.log("free1");
        require(controllers[name] == msg.sender, "ERR_OWNER");
        console.log("free2");
        Emap(emap).set(name, key, meta, data);
        console.log("free3");
    }
}

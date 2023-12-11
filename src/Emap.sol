import "forge-std/Test.sol";
// UI: block explorers

contract Emap is Test {
    struct Value {
        string meta;
        bytes data;
    }
    // SPECIAL_KEY: PRIMARY_WALLET, PRIMARY_WALLET_SIG, MAP_LOCK, REGISTRAR

    mapping(bytes32 => string[]) public keyStore;

    // optinally, there is a meta
    // each meta has the same name as a key for describing data's encoding in Solidity's ABI
    mapping(bytes32 => mapping(string => Value)) public valueStore;

    address public immutable ROOT_REGISTRAR;

    event Set(address indexed caller, string indexed name, string indexed key, string meta, bytes data);
    event Unset(address indexed caller, string indexed name, string indexed key);

    constructor(address root) {
        ROOT_REGISTRAR = root;
    }

    // tools
    // https://adibas03.github.io/online-ethereum-abi-encoder-decoder/#/encode

    function set(string calldata name, string calldata key, string calldata meta, bytes calldata data) external {
        console.log("s1");
        bytes32 slot = keccak256(abi.encode(msg.sender, name));
        require(valueStore[slot][LOCK()].data.length == 0, "ERR_LOCK");
        _unset(slot, key);
        console.log("s2");
        keyStore[slot].push(key);
        valueStore[slot][key] = Value({meta: meta, data: data});
        console.log("s3");
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

    function LOCK() public returns (string memory) {
        return "LOCK";
    }

    function REGISTRAR() external returns (string memory) {
        return "REGISTRAR";
    }
}

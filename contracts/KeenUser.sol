// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract KeenUser is Context,AccessControlEnumerable{
    using Address for address;
	using SafeMath for uint256;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
	// using SafeERC20 for IERC20;

    bytes32 public constant CREATE_ROLE = keccak256("CREATE_ROLE");
    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");
    bytes32 public constant DELETE_ROLE = keccak256("DELETE_ROLE");

    TcpPosition public immutable tcpPosition;

    address public keenRouter;

    address public keenConfig;
    
    

    mapping(address => address) public userParents;

    
    mapping(uint256 =>EnumerableMap.AddressToUintMap) private stackTypeMap;


    mapping(address => uint256) public pairBetReward;

    //pari => (user => amount)
    mapping(address => EnumerableMap.AddressToUintMap) public userBetTotal;


    constructor(address _tcpPosition,address _keenRouter,address _keenConfig) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CREATE_ROLE, _msgSender());
        _setupRole(UPDATE_ROLE, _msgSender());
        _setupRole(DELETE_ROLE, _msgSender());
        tcpPosition = TcpPosition(_tcpPosition);
        keenRouter = _keenRouter;
        keenConfig = _keenConfig;

    }



    function containsStackUser(uint256 _stackType,address _user) public view returns (bool) {
        return stackTypeMap[_stackType].contains(_user);
    }

    function createStackUser(address _user,uint _stackType,address parent) external {
        require(hasRole(CREATE_ROLE, _msgSender()), "KeenUser: must have create role to createStackUser");
        require(!stackTypeMap[_stackType].contains(_user), "KeenUser: user is exist");
        stackTypeMap[_stackType].set(_user,1);
        
        addUserParent(_user,parent);
    }


    function deleteStackUser(address _user,uint _stackType,address parent) external  {
        require(hasRole(DELETE_ROLE, _msgSender()), "KeenUser: must have delete role to deleteStackUser");
        require(stackTypeMap[_stackType].contains(_user), "KeenUser: user is not exist");
        stackTypeMap[_stackType].remove(_user);

        addUserParent(_user,parent);
    }

    
    function getParentAddress(address userAddress) public view returns (address parentAddress) {
        parentAddress = userParents[userAddress];
        if(parentAddress == address(0)){
            parentAddress = tcpPosition.getParentAddress(userAddress);
        }
    }

    function addUserParent(address _user,address parent)private{
        if(userParents[_user] == address(0) && Address.isContract(address(tcpPosition))){
            address parentAddress = tcpPosition.getParentAddress(_user);
            if(parentAddress != address(0)){
                parentAddress = parent;
            }
            userParents[_user] = parentAddress;
        }
    }

    function calculateBet(address pair,uint256 amount,address to) external {
        require(_msgSender() == keenRouter, "KeenUser: must is keenRouter to calculateBet");
        
        userBetTotal[pair].set(to,userBetTotal[pair].get(to).add(amount));

        //self
        uint256 factor = IKeenConfig(keenConfig).betMintFactor(pair);

        // parent
        uint256[] memory inviteRates = IKeenConfig(keenConfig).getInviteRates();








    }



    
}

interface IKeenUser{
    function getParentAddress(address userAddress) external view returns (address parentAddress);
    function updateUser(address _user,uint _stackType,address parent)external;
    function userInfos(address _user)external view returns (address parent,uint stackType);
}


interface TcpPosition {
    

    function getParentAddress(address userAddress) external view returns (address parentAddress);

}

interface IKeenConfig{

    function setStackRatios(uint256 _companyStackRatio,uint256 _committeeStackRatio,uint256 _shareholderStackRatio) external;

    function getStackRatios() external view returns(uint256 [] memory stackRatios);

    function setBetOdds(uint256 [] calldata _betOdds) external;

    function getBetOdds() external view returns(uint256 [] memory _betOdds);

    function betReceive() external view returns(address );

    function setBetReceive(address _betReceive) external;

    function betSender() external view returns(address );

    function setBetSender(address _betSender) external;

    function betInterval() external view returns(uint256 );

    function setBetInterval(uint256 _betInterval) external;

    function getInviteRates() external view returns(uint256 [] memory inviteRates);

    function setInviteRates(uint256 [] calldata _inviteRates) external;

    function setBetMintFactor(address _pair,uint256 _factor) external;

    function betMintFactor(address _pair) external view returns(uint256);

}

interface IKeenPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function stackToken() external view returns (address);
    function replaceToken0() external view returns (address);
    function replaceToken1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to,uint stackType) external returns (uint liquidity);
    function burn(address to,uint stackType) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function bet(uint amountIn, address to,uint256 betType,uint256 betTime) external;
    function announce(uint256 betTime,uint256 [] calldata results) external;
    function skim(address to,uint stackType) external;
    function sync() external;
    function addStack(uint256 _companyStackRatio,uint256 _committeeStackRatio,uint256 _shareholderStackRatio) external;
    function initialize(address, address,address,address,address,uint256[]calldata) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function supply(address account, uint256 amount) public returns (bool);
}
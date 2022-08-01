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
    using EnumerableMap for EnumerableMap.UintToUintMap;
	// using SafeERC20 for IERC20;

    bytes32 public constant CREATE_ROLE = keccak256("CREATE_ROLE");
    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");
    bytes32 public constant DELETE_ROLE = keccak256("DELETE_ROLE");

    uint256 public constant DAY_SECONDS = 60*60*24;

    TcpPosition public tcpPosition;

    DateTimeAPI public dateTimeAPI;
    

    address public keenRouter;

    address public keenConfig;   

    address public keenToken; 

    mapping(address => address) public userParents;

    
    mapping(uint256 => EnumerableMap.AddressToUintMap) private stackTypeMap;

    //user => (date => reward)
    mapping(address => EnumerableMap.UintToUintMap) private userDateRewardMap;

    //pari =>  reward
    mapping(address => uint256) public pairRewardMap;


    constructor(address _tcpPosition,address _keenConfig,address _dateTimeAPI,address _keenToken) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CREATE_ROLE, _msgSender());
        _setupRole(UPDATE_ROLE, _msgSender());
        _setupRole(DELETE_ROLE, _msgSender());
        tcpPosition = TcpPosition(_tcpPosition);
        dateTimeAPI = DateTimeAPI(_dateTimeAPI);
        keenConfig = _keenConfig;
        keenToken = _keenToken;
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

    function calculateBetReward(address pair,uint256 amount,address to) external {
        require(_msgSender() == keenRouter, "KeenUser: must is keenRouter to calculateBet");
        
        uint256 factor = IKeenConfig(keenConfig).betMintFactor(pair);
        if(factor == 0){
            return;            
        }
        uint256 max = IKeenConfig(keenConfig).betMintMax(pair);

        uint256 tomorrow = dateTimeAPI.beginOfDay(uint16(block.timestamp+DAY_SECONDS));

        //self
        uint256 reward = amount.mul(factor).div(1000);

        uint256 _reward = rewardToUser(pair,to,reward,max,tomorrow);
        if(reward != _reward){
            return;
        }
        // parent
        uint256[] memory inviteRates = IKeenConfig(keenConfig).getInviteRates();
        address currentParent = to;
        for (uint256 index = 0; index < inviteRates.length; index++) {
            currentParent = getParentAddress(currentParent);
            if(currentParent == address(0)){
                break;
            }
            bool flag = false;
            if(containsStackUser(1,currentParent) || containsStackUser(2,currentParent)){
                flag = true;
            }else if(containsStackUser(3,currentParent) && index < 3){
                flag = true;
            }
            if(!flag){
                continue;
            }
            uint256 _rate = inviteRates[index];
            uint256 parentReward = _reward.mul(_rate).div(100);

            uint256 _parentReward = rewardToUser(pair,currentParent,parentReward,max,tomorrow);
            if(parentReward != _parentReward){
                break;
            }
        }
    }

    function rewardToUser(address pair,address to,uint256 reward,uint256 max,uint256 date) private returns (uint256 _reward){
        uint256 pairReward = pairRewardMap[pair];
        if(pairReward >= max){
            _reward =  0;
        }else{
            uint256 remain = max.sub(pairReward);
            _reward = remain >= reward ? reward : remain;
            userDateRewardMap[to].set(date,_reward.add(userDateRewardMap[to].get(date)));
            pairRewardMap[pair] = pairRewardMap[pair].add(_reward);
        }
    }

    function pendingReward(address to) public view returns (uint256 _reward){
        for (uint256 index = 0; index < userDateRewardMap[to].length(); index++) {
            (uint256 key,uint256 value)  = userDateRewardMap[to].at(index);
            if(key <= block.timestamp){
                _reward += value;
            }
        }
    }

    function harvest() public returns (uint256 _reward){
        address to = msg.sender;
        uint256 [] memory harvestKeys = new uint256[](userDateRewardMap[to].length());
        for (uint256 index = 0; index < userDateRewardMap[to].length(); index++) {
            (uint256 key, uint256 value) = userDateRewardMap[to].at(index);
            if(key <= block.timestamp){
                _reward += value;
                harvestKeys[index] = key;
            }
        }
        
        require(_reward != 0, "KeenUser: reward must not eq zero");
        IERC20(keenToken).supply(to, _reward);
        for (uint256 index = 0; index < harvestKeys.length; index++) {
            if(harvestKeys[index] != 0){
                userDateRewardMap[to].remove(harvestKeys[index]);
            }
        }
    }

    function updateKeenRouter(address _keenRouter) external {
        require(hasRole(UPDATE_ROLE, _msgSender()), "KeenUser: must have update role to updateKeenRouter");
        keenRouter = _keenRouter;
    }

    function updateTcpPosition(address _tcpPosition) external {
        require(hasRole(UPDATE_ROLE, _msgSender()), "KeenUser: must have update role to updateTcpPosition");
        tcpPosition = TcpPosition(_tcpPosition);
    }

    function updateKeenConfig(address _keenConfig) external {
        require(hasRole(UPDATE_ROLE, _msgSender()), "KeenUser: must have update role to updateKeenConfig");
        keenConfig = _keenConfig;
    }

    function updateDateTimeAPI(address _dateTimeAPI) external {
        require(hasRole(UPDATE_ROLE, _msgSender()), "KeenUser: must have update role to updateDateTimeAPI");
        dateTimeAPI = DateTimeAPI(_dateTimeAPI);
    }

    function updateKeenToken(address _keenToken) external {
        require(hasRole(UPDATE_ROLE, _msgSender()), "KeenUser: must have update role to updateKeenToken");
        keenToken = _keenToken;
    }

    
}

interface IKeenUser{
    function getParentAddress(address userAddress) external view returns (address parentAddress);
    function createStackUser(address _user,uint _stackType,address parent) external;
    function deleteStackUser(address _user,uint _stackType,address parent) external;
    function userInfos(address _user)external view returns (address parent,uint stackType);
    function calculateBetReward(address pair,uint256 amount,address to) external;
    function containsStackUser(uint256 _stackType,address _user) external view returns (bool);
    
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


    function setBetMintMax(address _pair,uint256 _factor) external;

    function betMintMax(address _pair) external view returns(uint256);

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
    function supply(address account, uint256 amount) external returns (bool);
}

interface DateTimeAPI {
        /*
         *  Abstract contract for interfacing with the DateTime contract.
         *
         */
        function isLeapYear(uint year) external pure returns (bool);
        function getYear(uint timestamp) external pure returns (uint);
        function getMonth(uint timestamp) external pure returns (uint);
        function getDay(uint timestamp) external pure returns (uint);
        function getHour(uint timestamp) external pure returns (uint);
        function getMinute(uint timestamp) external pure returns (uint);
        function getSecond(uint timestamp) external pure returns (uint);
        function getWeekday(uint timestamp) external pure returns (uint);
        function beginOfDay(uint timestamp) external pure returns (uint);
        function toTimestamp(uint year, uint month, uint day) external pure returns (uint );
}
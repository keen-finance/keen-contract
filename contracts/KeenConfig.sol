// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

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

    function committeeFreedTimes() external view returns(uint256 time);

    function setCommitteeFreedTimes(uint256 _committeeFreedTimes) external;

    function committeeIntervalTime() external view returns(uint256 time);

    function setCommitteeIntervalTime(uint256 _committeeIntervalTime) external;

    function committeeFreedStartTime() external view returns(uint256 time);

    function currentCommitteeFreedStartTime() external view returns(uint256);

    function setCommitteeFreedStartTime(uint256 _committeeFreedStartTime) external;

    function committeeMinStack() external view returns(uint256);
    
    function setCommitteeMinStack(uint256 _committeeMinStack) external;
    
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


contract KeenConfig is IKeenConfig,Context,AccessControlEnumerable{
    using Address for address;
	using SafeMath for uint256;
	// using SafeERC20 for IERC20;

    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");
    uint256 public constant DAY_SECONDS = 60 * 60 * 24;
    uint256 public constant MONTH_SECONDS = DAY_SECONDS * 30;

    DateTimeAPI public dateTimeAPI;

    //[buy,sell]
    uint256[] private betOdds = [195,195];
    //receive bet token
    address public betReceive;
    //send reward bet token
    address public betSender;

    //Institutional holding ratio
    uint256 private companyStackRatio = 20;
    uint256 private committeeStackRatio = 30;
    uint256 private shareholderStackRatio = 50;

    uint256 public betInterval = 60;

    uint256[] private inviteRates = [10,6,5,4,3,2,1,1,1,1];

    //committee config
    uint256 public committeeFreedTimes = 10;
    uint256 public committeeIntervalTime = MONTH_SECONDS;
    uint256 public committeeFreedStartTime = MONTH_SECONDS*3;
    uint256 public committeeMinStack = 5000*(10**18);




    mapping(address => uint256) public betMintFactor;

    mapping(address => uint256) public betMintMax;

    constructor(address _betReceive,address _betSender,address _dateTimeAPI) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(UPDATE_ROLE, _msgSender());
        betReceive = _betReceive;
        betSender = _betSender;
        dateTimeAPI = DateTimeAPI(_dateTimeAPI);
    }

    function setStackRatios(uint256 _companyStackRatio,uint256 _committeeStackRatio,uint256 _shareholderStackRatio) external {
        require(hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        companyStackRatio = _companyStackRatio;
        committeeStackRatio = _committeeStackRatio;
        shareholderStackRatio = _shareholderStackRatio;
    }

    function getStackRatios() external view returns(uint256 [] memory stackRatios){
        stackRatios = new uint256[](3);
        stackRatios[0] = companyStackRatio;
        stackRatios[1] = committeeStackRatio;
        stackRatios[2] = shareholderStackRatio;
    }

    function setBetOdds(uint256 [] calldata _betOdds) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betOdds = _betOdds;
    }

    function getBetOdds() external view returns(uint256 [] memory _betOdds){
        _betOdds = betOdds;
    }

    function setBetReceive(address _betReceive) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betReceive = _betReceive;
    }

    function setBetSender(address _betSender) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betSender = _betSender;
    }

    function setBetInterval(uint256 _betInterval) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betInterval = _betInterval;
    }

    function getInviteRates() external view returns(uint256 [] memory _inviteRates){
        _inviteRates = inviteRates;
    }

    function setInviteRates(uint256 [] calldata _inviteRates) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        inviteRates = _inviteRates;
    }

    function setBetMintFactor(address _pair,uint256 _factor) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betMintFactor[_pair] = _factor;
    }

    function setBetMintMax(address _pair,uint256 _max) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betMintMax[_pair] = _max;
    }


    function setCommitteeFreedTimes(uint256 _committeeFreedTimes) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        committeeFreedTimes = _committeeFreedTimes;
    }

    function setCommitteeIntervalTime(uint _committeeIntervalTime) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        committeeIntervalTime = _committeeIntervalTime;
    }

    function setCommitteeFreedStartTime(uint _committeeFreedStartTime) external {
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        committeeFreedStartTime = _committeeFreedStartTime;
    }

    function currentCommitteeFreedStartTime() public view returns(uint256){
        uint256 time =  block.timestamp + committeeFreedStartTime;
        return dateTimeAPI.beginOfDay(time);
    }

    function setCommitteeMinStack(uint256 _committeeMinStack) external{
        require( hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        committeeMinStack = _committeeMinStack;
    }

 
}



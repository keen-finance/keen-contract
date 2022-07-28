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

}


contract KeenConfig is IKeenConfig,Context,AccessControlEnumerable{
    using Address for address;
	using SafeMath for uint256;
	// using SafeERC20 for IERC20;

    bytes32 public constant CREATE_ROLE = keccak256("CREATE_ROLE");
    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");
    bytes32 public constant DELETE_ROLE = keccak256("DELETE_ROLE");

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

    uint256 public betInterval = 30;

    uint256[] private inviteRates = [10,6,5,4,3,2,1,1,1,1];

    mapping(address => uint256) public betMintFactor;

    mapping(address => uint256) public betMintMax;

    constructor(address _betReceive,address _betSender) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CREATE_ROLE, _msgSender());
        _setupRole(UPDATE_ROLE, _msgSender());
        _setupRole(DELETE_ROLE, _msgSender());
        betReceive = _betReceive;
        betSender = _betSender;
    }

    function setStackRatios(uint256 _companyStackRatio,uint256 _committeeStackRatio,uint256 _shareholderStackRatio) external {
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
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
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betOdds = _betOdds;
    }

    function getBetOdds() external view returns(uint256 [] memory _betOdds){
        _betOdds = betOdds;
    }

    function setBetReceive(address _betReceive) external {
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betReceive = _betReceive;
    }

    function setBetSender(address _betSender) external {
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betSender = _betSender;
    }

    function setBetInterval(uint256 _betInterval) external {
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betInterval = _betInterval;
    }

    function getInviteRates() external view returns(uint256 [] memory _inviteRates){
        _inviteRates = inviteRates;
    }

    function setInviteRates(uint256 [] calldata _inviteRates) external {
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        inviteRates = _inviteRates;
    }

    function setBetMintFactor(address _pair,uint256 _factor) external {
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betMintFactor[_pair] = _factor;
    }

    function setBetMintMax(address _pair,uint256 _max) external {
        require(hasRole(CREATE_ROLE, _msgSender()) || hasRole(UPDATE_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'KeenConfig: FORBIDDEN');
        betMintMax[_pair] = _max;
    }
 
}



// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
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
    
    

    mapping(address => address) public userParents;

    
    mapping(uint256 =>EnumerableMap.AddressToUintMap) private stackTypeMap;




    constructor(address _tcpPosition) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CREATE_ROLE, _msgSender());
        _setupRole(UPDATE_ROLE, _msgSender());
        _setupRole(DELETE_ROLE, _msgSender());
        tcpPosition = TcpPosition(_tcpPosition);
    }



    function containsStackUser(uint256 _stackType,address _user) public view returns (bool) {
        return stackTypeMap[_stackType].contains(_user);
    }

    function createStackUser(address _user,uint _stackType,address parent) public  {
        require(hasRole(CREATE_ROLE, _msgSender()), "KeenUser: must have create role to createStackUser");
        require(!stackTypeMap[_stackType].contains(_user), "KeenUser: user is exist");
        stackTypeMap[_stackType].set(_user,1);
        
        if(userParents[_user] == address(0)){
            address parentAddress = tcpPosition.getParentAddress(_user);
            if(parentAddress != address(0)){
                parentAddress = parent;
            }
            userParents[_user] = parentAddress;
        }
    }


    function deleteStackUser(address _user,uint _stackType,address parent) public  {
        require(hasRole(DELETE_ROLE, _msgSender()), "KeenUser: must have delete role to deleteStackUser");
        require(stackTypeMap[_stackType].contains(_user), "KeenUser: user is not exist");
        stackTypeMap[_stackType].remove(_user);

        if(userParents[_user] == address(0)){
            address parentAddress = tcpPosition.getParentAddress(_user);
            if(parentAddress != address(0)){
                parentAddress = parent;
            }
            userParents[_user] = parentAddress;
        }
    }

    
    function getParentAddress(address userAddress) public view returns (address parentAddress) {
        parentAddress = userParents[userAddress];
        if(parentAddress == address(0)){
            parentAddress = tcpPosition.getParentAddress(userAddress);
        }
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
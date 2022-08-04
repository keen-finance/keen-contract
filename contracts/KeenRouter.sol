/**
 *Submitted for verification at BscScan.com on 2021-04-23
*/

// File: @uniswap\lib\contracts\libraries\TransferHelper.sol

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// File: contracts\interfaces\IKeenRouter01.sol

pragma solidity >=0.6.2;

interface IKeenRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts\interfaces\IKeenRouter02.sol

pragma solidity >=0.6.2;

interface IKeenRouter02 is IKeenRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: contracts\interfaces\IKeenFactory.sol

pragma solidity >=0.5.0;

interface IKeenFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    event AnnounceResult(uint betType,uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function keenConfig() external view returns (address);
    function betResultArray(uint256 betTime) external view returns (uint256 [] memory);


    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address[] calldata path,address[] calldata replacePath,uint256 maxStake) external returns (address pair);
    function announce(uint256 betTime,uint256 [] calldata results) external;

    function calculateStackArray(uint256 maxStake) external view returns(uint256 [] memory);

    function calculateStack(uint256 maxStake,uint256 ratio) external pure returns(uint256);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setKeenConfig(address) external;

    function addStack(address tokenA, address tokenB,uint256 _stack) external;
    function getBetReceive() external view returns(address);

}

// File: contracts\libraries\SafeMath.sol

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

// File: contracts\interfaces\IKeenPair.sol

pragma solidity >=0.5.0;

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
    function accept(address to,uint256 betTime) external returns(uint256 outAmount);
    function bet(uint amountIn, address to,uint256 betType,uint256 betTime) external;
    function announce(uint256 betTime,uint256 [] calldata results) external;
    function skim(address to,uint stackType) external;
    function sync() external;
    function addStack(uint256 _companyStackRatio,uint256 _committeeStackRatio,uint256 _shareholderStackRatio) external;
    function initialize(address, address,address,address,address,uint256[]calldata) external;
    function getStackTokenBalance(address to) external view returns (uint256);
    function getFreezeLiquidity(address to) external view returns (uint256);
    function getUnfreezeLiquidity(address to) external view returns (uint256);
}

// File: contracts\libraries\KeenLibrary.sol

pragma solidity >=0.5.0;



library KeenLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'KeenLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'KeenLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'ed643b98febb8bc860df619b52a17f5f217eaca97713c32a12fa0f73534ba68b' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IKeenPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // fetches stackToken
    function getStackToken(address factory, address tokenA, address tokenB) internal view returns (address stackToken) {
        pairFor(factory, tokenA, tokenB);
        stackToken = IKeenPair(pairFor(factory, tokenA, tokenB)).stackToken();
    }

    // fetches replaceToken0
    function getReplaceToken0(address factory, address tokenA, address tokenB) internal view returns (address replaceToken0) {
        pairFor(factory, tokenA, tokenB);
        replaceToken0 = IKeenPair(pairFor(factory, tokenA, tokenB)).replaceToken0();
    }

    // fetches replaceToken1
    function getReplaceToken1(address factory, address tokenA, address tokenB) internal view returns (address replaceToken1) {
        pairFor(factory, tokenA, tokenB);
        replaceToken1 = IKeenPair(pairFor(factory, tokenA, tokenB)).replaceToken1();
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'KeenLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'KeenLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'KeenLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'KeenLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'KeenLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'KeenLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'KeenLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'KeenLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

}

// File: contracts\interfaces\IERC20.sol

pragma solidity >=0.5.0;

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
}

// File: contracts\interfaces\IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// File: contracts\KeenUser.sol
pragma solidity >=0.5.0;
interface IKeenUser{
    function getParentAddress(address userAddress) external view returns (address parentAddress);
    function createStackUser(address _user,uint _stackType,address parent) external;
    function deleteStackUser(address _user,uint _stackType,address parent) external;
    function userInfos(address _user)external view returns (address parent,uint stackType);
    function calculateBetReward(address pair,uint256 amount,address to) external;
    function containsStackUser(uint256 _stackType,address _user) external view returns (bool);
    
}

// File: contracts\KeenRouter.sol
pragma solidity =0.6.6;






contract KeenRouter {
    using SafeMath for uint;

    address public immutable  factory;
    address public immutable  WETH;
    address public immutable WKEEN;
    address public immutable keenUserContract;

    address public immutable committeeStackHolder;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'KeenRouter: EXPIRED');
        _;
    }



    constructor(address _factory, address _WETH, address _WKEEN, address _keenUserContract, address _committeeStackHolder) public {
        factory = _factory;
        WETH = _WETH;
        WKEEN = _WKEEN;
        keenUserContract = _keenUserContract;
        committeeStackHolder = _committeeStackHolder;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // require the pair exist
        require(IKeenFactory(factory).getPair(tokenA, tokenB) != address(0), 'KeenRouter: PAIR_NOT_EXIST');

        (uint reserveA, uint reserveB) = KeenLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = KeenLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'KeenRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = KeenLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'KeenRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    // **** company ****
    function addCompanyLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual  ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        address _tokenA = tokenA;                                // gas savings
        address _tokenB = tokenB;
        (amountA, amountB) = _addLiquidity(_tokenA, _tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = KeenLibrary.pairFor(factory, _tokenA, _tokenB);

        require(IKeenUser(keenUserContract).containsStackUser(1, to), 'KeenRouter: MUST_IS_COMPANY');
        
        TransferHelper.safeTransferFrom(_tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(_tokenB, msg.sender, pair, amountB);

        liquidity = IKeenPair(pair).mint(to,1);
    }

    function addCompanyLiquidityByReplaceToken(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual  ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        address _tokenA = tokenA;                                // gas savings
        address _tokenB = tokenB;
        (amountA, amountB) = _addLiquidity(_tokenA, _tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = KeenLibrary.pairFor(factory, _tokenA, _tokenB);

        require(IKeenUser(keenUserContract).containsStackUser(1, to), 'KeenRouter: MUST_IS_COMPANY');
        (address token0,) = KeenLibrary.sortTokens(_tokenA, _tokenB);

        address replaceToken0 = KeenLibrary.getReplaceToken0(factory, _tokenA, _tokenB);
        address replaceToken1 = KeenLibrary.getReplaceToken1(factory, _tokenA, _tokenB);
        if(replaceToken0 != address(0)){
            //token0 is usdt
            if(token0 == _tokenA){
                _tokenA = replaceToken0;
            }else{
                _tokenB = replaceToken0;
            }
        }else if(replaceToken1 != address(0)){
            //token1 is usdt
            if(token0 != _tokenA){
                _tokenA = replaceToken1;
            }else{
                _tokenB = replaceToken1;
            }
        }
        TransferHelper.safeTransferFrom(_tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(_tokenB, msg.sender, pair, amountB);

        liquidity = IKeenPair(pair).mint(to,1);
    }


    // **** committee ****
    function addCommitteeLiquidity(
        address tokenA,
        address tokenB,
        bool isWKEEN,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        address parent
    ) external virtual  ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        address _tokenA = tokenA;                                // gas savings
        address _tokenB = tokenB;
        
        (amountA, amountB) = _addLiquidity(_tokenA, _tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = KeenLibrary.pairFor(factory, _tokenA, _tokenB);

        if(isWKEEN){
            address stackToken = KeenLibrary.getStackToken(factory, _tokenA, _tokenB);
            if(stackToken == _tokenA){
                //tokenB is usdt
                TransferHelper.safeTransferFrom(WKEEN, msg.sender, committeeStackHolder, amountA);
                TransferHelper.safeTransferFrom(_tokenA, committeeStackHolder, pair, amountA);
                TransferHelper.safeTransferFrom(_tokenB, msg.sender, pair, amountB);
            }else if(stackToken == _tokenB){
                //tokenA is usdt
                TransferHelper.safeTransferFrom(_tokenA, msg.sender, pair, amountA);
                TransferHelper.safeTransferFrom(WKEEN, msg.sender, committeeStackHolder, amountB);
                TransferHelper.safeTransferFrom(_tokenB, committeeStackHolder, pair, amountB);
            }
        }else{
            TransferHelper.safeTransferFrom(_tokenA, msg.sender, pair, amountA);
            TransferHelper.safeTransferFrom(_tokenB, msg.sender, pair, amountB);
        }
        liquidity = IKeenPair(pair).mint(to,2);
        _updateStackType(pair,to,2,parent);
    }


    // **** shareholders ****
    function addShareholdersLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        address parent
    ) external virtual  ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = KeenLibrary.pairFor(factory, tokenA, tokenB);

        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IKeenPair(pair).mint(to,3);
        _updateStackType(pair,to,3,parent);
    }

    function _updateStackType(address pair,address to,uint256 stackType,address parent) private {
        bool isStackUser = IKeenUser(keenUserContract).containsStackUser(stackType, to);
        uint256 stackTokenBalance = IKeenPair(pair).getStackTokenBalance(to);
        if(isStackUser && stackTokenBalance < 100*(10**18)){
            IKeenUser(keenUserContract).deleteStackUser(to,stackType,parent);
        }
        if(!isStackUser && stackTokenBalance >= 100*(10**18)){
            IKeenUser(keenUserContract).createStackUser(to,stackType,parent);
        }
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        uint stackType
    ) public virtual  ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = KeenLibrary.pairFor(factory, tokenA, tokenB);
        IKeenPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IKeenPair(pair).burn(to,stackType);
        (address token0,) = KeenLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'KeenRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'KeenRouter: INSUFFICIENT_B_AMOUNT');
        _updateStackType(pair,to,stackType,address(0));
    }



    function bet(
        uint amountIn,
        address[] calldata path,
        uint256 betType,
        uint256 betTime,
        uint deadline
    ) external virtual  ensure(deadline){
        address stackToken = KeenLibrary.getStackToken(factory, path[0], path[1]);
        require(path[1] == stackToken,"KeenRouter: PATH_0_ERROR");
        //bet amount summary
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, IKeenFactory(factory).getBetReceive(), amountIn
        );
        //Input data
        address pairAddress = KeenLibrary.pairFor(factory, path[0], path[1]);
        IKeenPair(pairAddress).bet(
            amountIn, msg.sender,betType,betTime
        );
        //calculate bet reward
        IKeenUser(keenUserContract).calculateBetReward(pairAddress, amountIn, msg.sender);
    }


    function accept(
        address[] calldata path,
        uint256 betTime,
        uint deadline
    ) external virtual  ensure(deadline){
        address stackToken = KeenLibrary.getStackToken(factory, path[0], path[1]);
        require(path[0] != stackToken,"KeenRouter: PATH_0_ERROR");
        //Input data
        address pairAddress = KeenLibrary.pairFor(factory, path[0], path[1]);
        IKeenPair(pairAddress).accept(
             msg.sender,betTime
        );
    }

    

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual  returns (uint amountB) {
        return KeenLibrary.quote(amountA, reserveA, reserveB);
    }


    function getReserves(address addressA, address addressB) public  virtual view returns (uint reserve0, uint reserve1) {
        (uint reserve0A, uint reserve1A) = KeenLibrary.getReserves(factory,addressA, addressB);
        reserve0 = reserve0A;
        reserve1 = reserve1A;
    }

    function pairFor(address tokenA, address tokenB) public   virtual view  returns (address pair) {
        pair =  KeenLibrary.pairFor(factory,tokenA, tokenB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        virtual

        returns (uint amountOut)
    {
        return KeenLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        virtual

        returns (uint amountIn)
    {
        return KeenLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual

        returns (uint[] memory amounts)
    {
        return KeenLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        virtual

        returns (uint[] memory amounts)
    {
        return KeenLibrary.getAmountsIn(factory, amountOut, path);
    }
}

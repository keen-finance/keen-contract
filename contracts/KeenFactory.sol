/**
 *Submitted for verification at BscScan.com on 2021-04-23
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-22
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-22
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-19
*/

pragma solidity =0.5.16;


interface IKeenFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB,address replaceTokenA,address replaceTokenB,address stackToken,uint256 maxStake) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setStackRatio(uint256 _companyStackRatio,uint256 _committeeStackRatio,uint256 _shareholderStackRatio) external ;

    function addStack(address tokenA, address tokenB,uint256 _stack) external ;

    function keenConfig() external view returns (address);
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

interface IKeenERC20 {
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
}

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

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "ds-math-div-overflow");
        z = x / y;
    }
}

contract KeenERC20 is IKeenERC20 {
    using SafeMath for uint;

    string public constant name = 'Keen LPs';
    string public constant symbol = 'Keen-LP';
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'Keen: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'Keen: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// a library for performing various math operations
library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
// range: [0, 2**112 - 1]
// resolution: 1 / 2**112
library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
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
}

interface IKeenCallee {
    function keenCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
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

contract KeenPair is IKeenPair, KeenERC20 {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public stackToken;

    address public token0;
    address public token1;
    address public replaceToken0;
    address public replaceToken1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 public companyStack;
    uint256 public committeeStack;
    uint256 public shareholderStack;

    uint256 private betTotal;
    //betType:0-sell,1-buy
    //result:0-,1-win,2-lose
    //betTime ==> betType ==> result
    mapping (uint256 => uint256[])  public  betResultMap;
    //betTime ==> amount
    mapping (uint256 => uint256)  public  betSummaryMap;
    //betTime ==> (betType ==> amount)
    mapping (uint256 => uint256[])  public  betTypeMap;
    //betTime ==> (betType ==> (address ==> amount))
    mapping (uint256 => mapping (address => uint256)[])  public  betAddressMap;


    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Keen: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Keen: TRANSFER_FAILED');
    }

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
    event Bet(address indexed sender,uint amountIn,uint betType,uint betTime,address indexed  to);
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1,address _replaceToken0,address _replaceToken1,address _stackToken,uint256[] calldata stackArray) external {
        require(msg.sender == factory, 'Keen: FORBIDDEN'); // sufficient check
        require(stackArray.length == 3, 'Keen: STACKARRAY_LENGTH_ERROR'); // sufficient check
        token0 = _token0;
        token1 = _token1;
        replaceToken0 = _replaceToken0;
        replaceToken1 = _replaceToken1;
        stackToken = _stackToken;
        companyStack = stackArray[0];
        committeeStack = stackArray[1];
        shareholderStack = stackArray[2];
        
    }

    function addStack(uint256 _companyStack,uint256 _committeeStack,uint256 _shareholderStack) external {
        require(msg.sender == factory, 'Keen: FORBIDDEN');
        companyStack = companyStack+_companyStack;
        committeeStack = committeeStack+_committeeStack;
        shareholderStack = shareholderStack+_shareholderStack;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'Keen: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 8/25 of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IKeenFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast)).mul(8);
                    uint denominator = rootK.mul(17).add(rootKLast.mul(8));
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to,uint stackType) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        if(replaceToken0 != address(0)){
            balance0 = balance0.add(IERC20(replaceToken0).balanceOf(address(this)));
        }
        uint balance1 = IERC20(token1).balanceOf(address(this));
        if(replaceToken1 != address(0)){
            balance1 = balance1.add(IERC20(replaceToken1).balanceOf(address(this)));
        }
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        uint256 stackAmount = 0;
        if(stackToken == token0){
            stackAmount = amount0;
        }else if(stackToken == token1){
            stackAmount = amount1;
        }
        if(stackType == 1){
            companyStack = companyStack.sub(stackAmount);
            require(companyStack >= 0, 'Keen: INSUFFICIENT_STACK');
        }else if(stackType == 2){
            committeeStack = companyStack.sub(stackAmount);
            require(committeeStack >= 0, 'Keen: INSUFFICIENT_STACK');
        }else if(stackType == 3){
            shareholderStack = shareholderStack.sub(stackAmount);
            require(shareholderStack >= 0, 'Keen: INSUFFICIENT_STACK');
        }
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'Keen: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to,uint stackType) external lock returns (uint amount0, uint amount1) {

        (uint112 _reserve0, uint112 _reserve1,) = getReserves();

        uint tokenbalance0 = IERC20(token0).balanceOf(address(this));
        uint balance0 = tokenbalance0;
        if(replaceToken0 != address(0)){
            balance0 = balance0.add(IERC20(replaceToken0).balanceOf(address(this)));
        }
        uint tokenbalance1 = IERC20(token1).balanceOf(address(this));
        uint balance1 = tokenbalance1;
        if(replaceToken1 != address(0)){
            balance1 = balance1.add(IERC20(replaceToken1).balanceOf(address(this)));
        }
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'Keen: INSUFFICIENT_LIQUIDITY_BURNED');

        _addStack(amount0,amount1,stackType);

        _burn(address(this), liquidity);

        if(amount0 <= tokenbalance0){
            _safeTransfer(token0, to, amount0);
        }else{
            if(tokenbalance0 > 0){
                _safeTransfer(token0, to, tokenbalance0);
            }
            _safeTransfer(replaceToken0, to, amount0.sub(tokenbalance0));
        }

        if(amount1 <= tokenbalance1){
            _safeTransfer(token1, to, amount1);
        }else{
            if(tokenbalance1 > 0){
                _safeTransfer(token1, to, tokenbalance1);
            }
            _safeTransfer(replaceToken1, to, amount1.sub(tokenbalance1));
        }

        balance0 = IERC20(token0).balanceOf(address(this));
        if(replaceToken0 != address(0)){
            balance0 = balance0.add(IERC20(replaceToken0).balanceOf(address(this)));
        }
        balance1 = IERC20(token1).balanceOf(address(this));
        if(replaceToken1 != address(0)){
            balance1 = balance1.add(IERC20(replaceToken1).balanceOf(address(this)));
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function _addStack(uint256 amount0,uint256 amount1,uint stackType) private {
        uint256 stackAmount = 0;
        if(stackToken == token0){
            stackAmount = amount0;
        }else if(stackToken == token1){
            stackAmount = amount1;
        }
        if(stackType == 1){
            companyStack = companyStack.add(stackAmount);
        }else if(stackType == 2){
            committeeStack = companyStack.add(stackAmount);
        }else if(stackType == 3){
            shareholderStack = shareholderStack.add(stackAmount);
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        uint _amount0Out = amount0Out;
        uint _amount1Out = amount1Out;
        require(_amount0Out > 0 || _amount1Out > 0, 'Keen: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(_amount0Out < _reserve0 && _amount1Out < _reserve1, 'Keen: INSUFFICIENT_LIQUIDITY');

        address _token0 = token0;                                // gas savings
        address _token1 = token1;

        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        { // scope for _token{0,1}, avoids stack too deep errors
        require(to != _token0 && to != _token1, 'Keen: INVALID_TO');
        if (_amount0Out > 0){
            // optimistically transfer tokens
            if(_amount0Out <= balance0){
                _safeTransfer(_token0, to, _amount0Out);
            }else{
                if(balance0 > 0){
                    _safeTransfer(_token0, to, balance0);
                }
                _safeTransfer(replaceToken0, to, _amount0Out.sub(balance0));
            }
        }
        if (_amount1Out > 0){
            // optimistically transfer tokens
            if(_amount1Out <= balance1){
                _safeTransfer(_token1, to, _amount1Out);
            }else{
                if(balance1 > 0){
                    _safeTransfer(_token1, to, balance1);
                }
                _safeTransfer(replaceToken1, to, _amount1Out.sub(balance1));
            }
        }
        if (data.length > 0) IKeenCallee(to).keenCall(msg.sender, _amount0Out, _amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        if(replaceToken0 != address(0)){
            balance0 = balance0.add(IERC20(replaceToken0).balanceOf(address(this)));
        }
        balance1 = IERC20(_token1).balanceOf(address(this));
        if(replaceToken1 != address(0)){
            balance1 = balance1.add(IERC20(replaceToken1).balanceOf(address(this)));
        }
        }
        uint amount0In = balance0 > _reserve0 - _amount0Out ? balance0 - (_reserve0 - _amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - _amount1Out ? balance1 - (_reserve1 - _amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'Keen: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = (balance0.mul(10000).sub(amount0In.mul(25)));
        uint balance1Adjusted = (balance1.mul(10000).sub(amount1In.mul(25)));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(10000**2), 'Keen: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, _amount0Out, _amount1Out, to);
    }


    function bet(uint amountIn, address to,uint256 betType,uint256 betTime) external lock {
        require(amountIn > 0, 'Keen: INSUFFICIENT_OUTPUT_AMOUNT');
        address _keenConfig = IKeenFactory(factory).keenConfig();
        require(betTime % IKeenConfig(_keenConfig).betInterval() == 0, 'KeenRouter: BET_TIME_ERROR');
        require(betTime > block.timestamp, 'KeenRouter: BET_TIME_EXPIRED');

        address _betToken = token0;
        if(_betToken == stackToken){
            _betToken = token1;
        }
        uint256 betTotal = IERC20(_betToken).balanceOf(IKeenConfig(_keenConfig).betReceive());
        uint256 lastBetAmount = betTotal.sub(betSummaryMap[betTime]);
        require(lastBetAmount >= amountIn, 'Keen: BETS_ERROR');

        betTotal += lastBetAmount;
        betSummaryMap[betTime] = betSummaryMap[betTime]+lastBetAmount;
        betTypeMap[betTime][betType] = betTypeMap[betTime][betType]+lastBetAmount;
        betAddressMap[betTime][betType][msg.sender] = betAddressMap[betTime][betType][to]+lastBetAmount;
        emit Bet(msg.sender, amountIn, betType, betTime, to);
    }
    //Announce results
    function announce(uint256 betTime,uint256 [] calldata results) external lock {
        require(msg.sender == factory, 'Keen: FORBIDDEN');
        require(results.length > 0, 'Keen: RESULT_LENGTH_ERROR');
        
        address _betToken = token0;
        if(_betToken == stackToken){
            _betToken = token1;
        }
        IKeenConfig ikeenConfig = IKeenConfig(IKeenFactory(factory).keenConfig());
        
        uint256[] memory betOdds = ikeenConfig.getBetOdds();
        uint256 outAmount = 0;
        for (uint256 index = 0; index < results.length; index++) {

            uint256 result = results[index];
            uint256 betAmount = betTypeMap[betTime][index];
            uint256 oods = betOdds[index];
            if(result == 1 && oods > 0){
                outAmount = outAmount + betAmount.mul(oods).div(100);
            }
        }

        address _betReceive = ikeenConfig.betReceive();
        
        uint256 betTotalBalance = IERC20(_betToken).balanceOf(_betReceive);

        if(betTotalBalance >  0){
            address _betSender = ikeenConfig.betSender();
            
            if(outAmount <= 0){
                IERC20(_betToken).transferFrom(_betReceive, address(this), betTotalBalance);
            }else{
                if(betTotalBalance >= outAmount){
                    IERC20(_betToken).transferFrom(_betReceive, _betSender, outAmount);
                    if(betTotalBalance > outAmount){
                        IERC20(_betToken).transferFrom(_betReceive, address(this), betTotalBalance.sub(outAmount));
                    }
                }else{
                    uint256 thisBetBalance = IERC20(_betToken).balanceOf(address(this));

                    IERC20(_betToken).transferFrom(_betReceive, _betSender, betTotalBalance);
                    if(thisBetBalance > 0){
                        uint256 out = outAmount.sub(betTotalBalance);
                        IERC20(_betToken).transfer(_betSender, out > thisBetBalance?thisBetBalance:out);
                    }
                }

            }
            uint balance0 = IERC20(token0).balanceOf(address(this));
            if(replaceToken0 != address(0)){
                balance0 = balance0.add(IERC20(replaceToken0).balanceOf(address(this)));
            }
            uint balance1 = IERC20(token1).balanceOf(address(this));
            if(replaceToken1 != address(0)){
                balance1 = balance1.add(IERC20(replaceToken1).balanceOf(address(this)));
            }
            _update(balance0, balance1, reserve0, reserve1);
        }
        
    }

    // force balances to match reserves
    function skim(address to,uint stackType) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings

        uint tokenbalance0 = IERC20(_token0).balanceOf(address(this));
        uint balance0 = tokenbalance0;
        if(replaceToken0 != address(0)){
            balance0 = balance0.add(IERC20(replaceToken0).balanceOf(address(this)));
        }
        uint tokenbalance1 = IERC20(_token1).balanceOf(address(this));
        uint balance1 = tokenbalance1;
        if(replaceToken1 != address(0)){
            balance1 = balance1.add(IERC20(replaceToken1).balanceOf(address(this)));
        }

        uint amount0 = balance0.sub(reserve0);
        uint amount1 = balance1.sub(reserve1);


        uint256 stackAmount = 0;
        if(stackToken == _token0){
            stackAmount = amount0;
        }else if(stackToken == _token1){
            stackAmount = amount1;
        }
        if(stackType == 1){
            companyStack = companyStack.sub(stackAmount);
        }else if(stackType == 2){
            committeeStack = companyStack.sub(stackAmount);
        }else if(stackType == 3){
            shareholderStack = shareholderStack.sub(stackAmount);
        }
        if(amount0 <= tokenbalance0){
            _safeTransfer(_token0, to, amount0);
        }else{
            if(tokenbalance0 > 0){
                _safeTransfer(_token0, to, tokenbalance0);
            }
            _safeTransfer(replaceToken0, to, amount0.sub(tokenbalance0));
        }

        if(amount1 <= tokenbalance1){
            _safeTransfer(_token1, to, amount1);
        }else{
            if(tokenbalance0 > 0){
                _safeTransfer(_token1, to, tokenbalance1);
            }
            _safeTransfer(replaceToken1, to, amount1.sub(tokenbalance1));
        }

    }

    // force reserves to match balances
    function sync() external lock {
        uint balance0 = IERC20(token0).balanceOf(address(this));
        if(replaceToken0 != address(0)){
            balance0 = balance0.add(IERC20(replaceToken0).balanceOf(address(this)));
        }
        uint balance1 = IERC20(token1).balanceOf(address(this));
        if(replaceToken1 != address(0)){
            balance1 = balance1.add(IERC20(replaceToken1).balanceOf(address(this)));
        }
        _update(balance0, balance1, reserve0, reserve1);
    }
}

contract KeenFactory is IKeenFactory {
    using SafeMath for uint256;
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(KeenPair).creationCode));

    address public feeTo;
    address public feeToSetter;
    address public keenConfig;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    //betType:0-sell,1-buy
    //result:0-,1-win,2-lose
    //betTime ==> betType ==> result
    mapping (uint256 => uint256[])  public  betResultMap;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    event AnnounceResult(uint betType,uint);

    constructor(address _feeToSetter,address _keenConfig) public {
        feeToSetter = _feeToSetter;
        keenConfig = _keenConfig;
    }




    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB,address replaceTokenA,address replaceTokenB,address stackToken,uint256 maxStake,uint256 betMintFactor) external returns (address pair) {
        require(msg.sender == feeToSetter, 'Keen: FORBIDDEN');
        require(tokenA != tokenB, 'Keen: IDENTICAL_ADDRESSES');
        require(replaceTokenA == address(0) || replaceTokenB == address(0), 'Keen: require replaceTokenA or replaceTokenB is zero');
        require(tokenA == stackToken || tokenB == stackToken, 'Keen: require tokenA or tokenB is stackToken');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        (address replaceToken0, address replaceToken1) = tokenA < tokenB ? (replaceTokenA, replaceTokenB) : (replaceTokenB, replaceTokenA);
        require(token0 != address(0), 'Keen: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Keen: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(KeenPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IKeenPair(pair).initialize(token0, token1,replaceToken0,replaceToken1,stackToken,calculateStackArray(maxStake));
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        if(betMintFactor > 0){
            IKeenConfig(keenConfig).setBetMintFactor(pair,betMintFactor);
        }
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function announce(uint256 betTime,uint256 [] calldata results) external {
        require(msg.sender == feeToSetter, 'Keen: FORBIDDEN');
        require(betResultMap[betTime][0] == 0, 'Keen: RESULT_REPEAT_ERROR');
        betResultMap[betTime] = results;
        for (uint256 index = 0; index < allPairs.length; index++) {
            address pair = allPairs[index];
            IKeenPair(pair).announce(betTime, results);
        }
        emit AnnounceResult(betTime, results.length);
    }

    function calculateStackArray(uint256 maxStake) public view returns(uint256 [] memory){
        uint256[] memory stackRatios = IKeenConfig(keenConfig).getStackRatios();
        uint256[] memory arrays = new uint256[](3);
        arrays[0] = calculateStack(maxStake,stackRatios[0]);
        arrays[1] = calculateStack(maxStake,stackRatios[1]);
        arrays[2] = calculateStack(maxStake,stackRatios[2]);
        return arrays;
    }

    function calculateStack(uint256 maxStake,uint256 ratio) public view returns(uint256){
        return maxStake.mul(ratio).div(10**2);
    }


    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Keen: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setKeenConfig(address _keenConfig) external {
        require(msg.sender == feeToSetter, 'Keen: FORBIDDEN');
        keenConfig = _keenConfig;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Keen: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }


    function addStack(address tokenA, address tokenB,uint256 _stack) external {
        require(msg.sender == feeToSetter, 'Keen: FORBIDDEN');
        require(getPair[tokenA][tokenB] != address(0), 'Keen: PAIR_NOT_EXISTS');
        uint256 [] memory stackArray = calculateStackArray(_stack);
        IKeenPair(getPair[tokenA][tokenB]).addStack(stackArray[0],stackArray[1],stackArray[2]);
    }
}

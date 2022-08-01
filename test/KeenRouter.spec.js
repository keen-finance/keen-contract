
const RewardToken = artifacts.require('RewardToken')
const KeenFactory = artifacts.require('KeenFactory')
const KeenRouter = artifacts.require('KeenRouter')
const KeenPair = artifacts.require('KeenPair')
const KeenUser = artifacts.require('KeenUser')
const WKEEN = artifacts.require('WKEEN')
const DateTime = artifacts.require('DateTime')
const KeenConfig = artifacts.require('KeenConfig')


const BN = web3.utils.BN
const expect = require('chai').use(require('bn-chai')(BN)).expect
const domain = 'KeenRouter'
const version = '1'

describe('KeenRouter', function () {
  this.timeout(100000)

  let zero = "0x0000000000000000000000000000000000000000"
  // Accounts
  let accounts

  let deployer


  let companyUser

  let companyUserFrom

  let committeeUser

  let ccommitteeUserFrom

  let shareholdersUser

  let shareholdersUserFrom

  let committeeStackHolder

  let committeeStackHolderFrom

  let parent




  // Contracts
  let usdt
  let keen
  let wkeen

  let keenFactoryContract

  let keenRouterContract

  let WETH = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

  let keenUserContract

  let usdtRecived

  let keenPair
  let createPairLogs

  let betReceive

  let betSender
  let wusdt
  beforeEach(async function () {
    // Create Listing environment
    accounts = await web3.eth.getAccounts()
    parent = accounts[0]
    companyUser = accounts[1]

    companyUserFrom = { from: companyUser }
    
    committeeUser = accounts[2]

    committeeUserFrom = { from: committeeUser }
    
    shareholdersUserUser = accounts[3]

    shareholdersUserFrom = { from: shareholdersUser }

    committeeStackHolder = accounts[4]

    committeeStackHolderFrom = { from: committeeStackHolder }

    betReceive = accounts[9]

    betSender = accounts[10]
    

    deployer = accounts[0]

    usdtRecived = accounts[0];

    fromUser = { from: accounts[deployer] }

    pancakeRouter = deployer;

    //create usdt token
    usdt = await RewardToken.new(deployer)

    //create wusdt token
    wusdt = await RewardToken.new(deployer)
    // 
    // await usdt.supply(committeeUser,web3.utils.toWei('100000', 'ether'))
    // await usdt.supply(shareholdersUser,web3.utils.toWei('10000', 'ether'))
    
    //create keen token
    keen = await RewardToken.new(deployer)
    // await keen.supply(companyUser,web3.utils.toWei('400000', 'ether'))
    // await keen.supply(committeeStackHolder,web3.utils.toWei('600000', 'ether'))
    // await keen.supply(shareholdersUser,web3.utils.toWei('10000', 'ether'))

    //create wkeen address _storage,IPancakeRouter _pancakeRouter,address _keenToken,address _usdtToken,address _usdtRecived
    wkeen = await WKEEN.new(deployer,pancakeRouter,keen.address,usdt.address,usdtRecived);
    let dateTime = await DateTime.new();
    // await wkeen.supply(committeeUser,web3.utils.toWei('100000', 'ether'))
    let keenConfigContract = await KeenConfig.new(betReceive,betSender,dateTime.address);
    //

    keenFactoryContract = await KeenFactory.new(deployer,keenConfigContract.address);
    

    //create pair address tokenA, address tokenB,address replaceTokenA,address replaceTokenB,address stackToken,uint256 maxStake,uint256 betMintFactor,uint256 betMintMax
    let {logs} = await keenFactoryContract.createPair([keen.address,usdt.address],[zero,wusdt.address],web3.utils.toWei('2000000', 'ether'))
    createPairLogs = logs
    console.log("0000000000000000000",await keenFactoryContract.INIT_CODE_PAIR_HASH());

    let pair = await keenFactoryContract.getPair(usdt.address, keen.address);
    console.log("111111111111111111",pair);
    keenPair = await KeenPair.at(pair)
    let tcpPosition = "0x77d34de33a75ac2a772f8C47080c0232Cbff463B"

    //create pair keenUserContract address _tcpPosition,address _keenRouter,address _keenConfig,address _dateTimeAPI,address _keenToken
    keenUserContract = await KeenUser.new(tcpPosition,keenConfigContract.address,dateTime.address,keen.address);
    await keenUserContract.createStackUser(companyUser,1,zero)

    //create keen router
    keenRouterContract = await KeenRouter.new(keenFactoryContract.address,WETH,wkeen.address,keenUserContract.address,committeeStackHolder)


    // await keen.approve(keenRouterContract.address,web3.utils.toWei('600000', 'ether'),committeeStackHolderFrom)
  })

  describe('initialize', function () {
    it('should be initialized with correct values', async function () {
      
      let committeeStackHolderRes = await keenRouterContract.committeeStackHolder()
      expect(committeeStackHolderRes).to.be.equal(committeeStackHolder)
    })
  })

  describe('addCompanyLiquidity', function () {
    
    it('should be addCompanyLiquidity sucess', async function () {
      let companyStack = await keenPair.companyStack()
      expect(companyStack).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))
      
      await usdt.supply(companyUser,web3.utils.toWei('400000', 'ether'))
      await keen.supply(companyUser,web3.utils.toWei('400000', 'ether'))

      let usdtBalance = await usdt.balanceOf(companyUser)
      let keenBalance = await keen.balanceOf(companyUser)
      
      expect(usdtBalance).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))
      expect(keenBalance).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))

      await usdt.approve(keenRouterContract.address,web3.utils.toWei('800000', 'ether'),companyUserFrom)
      await keen.approve(keenRouterContract.address,web3.utils.toWei('800000', 'ether'),companyUserFrom)

      let usdtAllowance = await usdt.allowance(companyUser,keenRouterContract.address,companyUserFrom)
      let keenAllowance = await keen.allowance(companyUser,keenRouterContract.address,companyUserFrom)
      
      expect(usdtAllowance).to.be.gt.BN(web3.utils.toWei('400000', 'ether'))
      expect(keenAllowance).to.be.gt.BN(web3.utils.toWei('400000', 'ether'))
      let pair = await keenFactoryContract.getPair(usdt.address, keen.address);
      
      await keenRouterContract.addCompanyLiquidity(
        usdt.address,keen.address,
        web3.utils.toWei('400000', 'ether'),web3.utils.toWei('400000', 'ether'),
        web3.utils.toWei('400000', 'ether'),web3.utils.toWei('400000', 'ether'),
        companyUser,
        new Date().getTime(),
        companyUserFrom
      )

      let keenPairBalance = await keenPair.balanceOf(companyUser)
      
      expect(keenPairBalance).to.be.gt.BN(web3.utils.toWei('390000', 'ether'))
    })

    
  })


  describe('addCompanyLiquidityByReplaceToken', function () {
    
    it('should be addCompanyLiquidityByReplaceToken sucess', async function () {
      let companyStack = await keenPair.companyStack()
      expect(companyStack).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))
      
      await wusdt.supply(companyUser,web3.utils.toWei('400000', 'ether'))
      await keen.supply(companyUser,web3.utils.toWei('400000', 'ether'))

      let wusdtBalance = await wusdt.balanceOf(companyUser)
      let keenBalance = await keen.balanceOf(companyUser)
      
      expect(wusdtBalance).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))
      expect(keenBalance).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))

      await wusdt.approve(keenRouterContract.address,web3.utils.toWei('800000', 'ether'),companyUserFrom)
      await keen.approve(keenRouterContract.address,web3.utils.toWei('800000', 'ether'),companyUserFrom)

      let wusdtBalanceAllowance = await wusdt.allowance(companyUser,keenRouterContract.address,companyUserFrom)
      let keenAllowance = await keen.allowance(companyUser,keenRouterContract.address,companyUserFrom)
      
      expect(wusdtBalanceAllowance).to.be.gt.BN(web3.utils.toWei('400000', 'ether'))
      expect(keenAllowance).to.be.gt.BN(web3.utils.toWei('400000', 'ether'))
      let pair = await keenFactoryContract.getPair(wusdt.address, keen.address);
      
      await keenRouterContract.addCompanyLiquidityByReplaceToken(
        usdt.address,keen.address,
        web3.utils.toWei('400000', 'ether'),web3.utils.toWei('400000', 'ether'),
        web3.utils.toWei('400000', 'ether'),web3.utils.toWei('400000', 'ether'),
        companyUser,
        new Date().getTime(),
        companyUserFrom
      )

      let keenPairBalance = await keenPair.balanceOf(companyUser)
      
      expect(keenPairBalance).to.be.gt.BN(web3.utils.toWei('390000', 'ether'))
    })

    
  })


  describe('addCommitteeLiquidity not wkeen', function () {
    
    it('should be addCommitteeLiquidity not wkeen sucess', async function () {
     
      await usdt.supply(committeeUser,web3.utils.toWei('4000', 'ether'))
      await keen.supply(committeeUser,web3.utils.toWei('4000', 'ether'))

      let usdtBalance = await usdt.balanceOf(committeeUser)
      let keenBalance = await keen.balanceOf(committeeUser)
      
      expect(usdtBalance).to.be.eq.BN(web3.utils.toWei('4000', 'ether'))
      expect(keenBalance).to.be.eq.BN(web3.utils.toWei('4000', 'ether'))

      await usdt.approve(keenRouterContract.address,web3.utils.toWei('800000', 'ether'),committeeUserFrom)
      await keen.approve(keenRouterContract.address,web3.utils.toWei('800000', 'ether'),committeeUserFrom)

      let usdtBalanceAllowance = await usdt.allowance(committeeUser,keenRouterContract.address,committeeUserFrom)
      let keenAllowance = await keen.allowance(committeeUser,keenRouterContract.address,committeeUserFrom)
      
      expect(usdtBalanceAllowance).to.be.gt.BN(web3.utils.toWei('4000', 'ether'))
      expect(keenAllowance).to.be.gt.BN(web3.utils.toWei('4000', 'ether'))
      let pair = await keenFactoryContract.getPair(usdt.address, keen.address);
      console.log(2222222222222222,pair)
      await keenRouterContract.addCommitteeLiquidity(
        usdt.address,keen.address, false,
        web3.utils.toWei('4000', 'ether'),web3.utils.toWei('4000', 'ether'),
        web3.utils.toWei('4000', 'ether'),web3.utils.toWei('4000', 'ether'),
        committeeUser,
        new Date().getTime(),
        parent,
        committeeUserFrom
      )

      let keenPairBalance = await keenPair.balanceOf(committeeUser)
      
      expect(keenPairBalance).to.be.gt.BN(web3.utils.toWei('3900', 'ether'))
    })

    
  })

  




})

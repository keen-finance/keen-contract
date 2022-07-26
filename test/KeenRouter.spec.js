
const RewardToken = artifacts.require('RewardToken')
const KeenFactory = artifacts.require('KeenFactory')
const KeenRouter = artifacts.require('KeenRouter')
const KeenPair = artifacts.require('KeenPair')
const KeenUser = artifacts.require('KeenUser')
const WKEEN = artifacts.require('WKEEN')


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
  beforeEach(async function () {
    // Create Listing environment
    accounts = await web3.eth.getAccounts()

    companyUser = accounts[1]

    companyUserFrom = { from: companyUser }
    
    committeeUser = accounts[2]

    ccommitteeUserFrom = { from: committeeUser }
    
    shareholdersUserUser = accounts[3]

    shareholdersUserFrom = { from: shareholdersUser }

    committeeStackHolder = accounts[4]

    committeeStackHolderFrom = { from: committeeStackHolder }
    

    deployer = accounts[0]

    usdtRecived = accounts[0];

    fromUser = { from: accounts[deployer] }

    //create usdt token
    usdt = await RewardToken.new(deployer)
    // 
    // await usdt.supply(committeeUser,web3.utils.toWei('100000', 'ether'))
    // await usdt.supply(shareholdersUser,web3.utils.toWei('10000', 'ether'))
    
    //create keen token
    keen = await RewardToken.new(deployer)
    // await keen.supply(companyUser,web3.utils.toWei('400000', 'ether'))
    // await keen.supply(committeeStackHolder,web3.utils.toWei('600000', 'ether'))
    // await keen.supply(shareholdersUser,web3.utils.toWei('10000', 'ether'))

    //create wkeen 
    wkeen = await WKEEN.new(deployer,usdt.address,usdtRecived)
    // await wkeen.supply(committeeUser,web3.utils.toWei('100000', 'ether'))

    //create factory
    keenFactoryContract = await KeenFactory.new(deployer)

    //create pair
    let {logs} = await keenFactoryContract.createPair(usdt.address, keen.address,zero,zero,keen.address,web3.utils.toWei('2000000', 'ether'))
    createPairLogs = logs
    

    let pair = await keenFactoryContract.getPair(usdt.address, keen.address);
    keenPair = await KeenPair.at(pair)
    let tcpPosition = "0x77d34de33a75ac2a772f8C47080c0232Cbff463B"

    //create pair keenUserContract
    keenUserContract = await KeenUser.new(tcpPosition)
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

  

  // describe('addStack', function () {
  //   it('should be createPair with correct values', async function () {
  //     let {logs} = await keenFactoryContract.createPair(tokenA.address, tokenB.address,zero,zero,tokenB.address,web3.utils.toWei('2000000', 'ether'))
  //     let pair = await keenFactoryContract.getPair(tokenA.address, tokenB.address);
  //     console.log("pair:",pair)
  //     console.log("allStack:",web3.utils.toWei('2000000', 'ether').toString())

  //     let calculateStack = await keenFactoryContract.calculateStack(web3.utils.toWei('2000000', 'ether'),20);
  //     console.log("calculateStack:",calculateStack.toString())

  //     let calculateStackArray = await keenFactoryContract.calculateStackArray(web3.utils.toWei('2000000', 'ether'));
  //     console.log("calculateStackArray0:",calculateStackArray[0].toString())
  //     console.log("calculateStackArray1:",calculateStackArray[1].toString())
  //     console.log("calculateStackArray2:",calculateStackArray[2].toString())

  //     let keenPair = await KeenPair.at(pair)
  //     let companyStack = await keenPair.companyStack()
  //     expect(companyStack).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))
      
  //     let committeeStack = await keenPair.committeeStack()
  //     expect(committeeStack).to.be.eq.BN(web3.utils.toWei('600000', 'ether'))
      
  //     let shareholderStack = await keenPair.shareholderStack()
  //     expect(shareholderStack).to.be.eq.BN(web3.utils.toWei('1000000', 'ether'))
      
  //     await keenFactoryContract.addStack(tokenA.address, tokenB.address,web3.utils.toWei('2000000', 'ether'))

  //     let companyStack2 = await keenPair.companyStack()
  //     expect(companyStack2).to.be.eq.BN(web3.utils.toWei('800000', 'ether'))
      
  //     let committeeStack2 = await keenPair.committeeStack()
  //     expect(committeeStack2).to.be.eq.BN(web3.utils.toWei('1200000', 'ether'))
      
  //     let shareholderStack2 = await keenPair.shareholderStack()
  //     expect(shareholderStack2).to.be.eq.BN(web3.utils.toWei('2000000', 'ether'))
      

      
  //   })
  // })




})

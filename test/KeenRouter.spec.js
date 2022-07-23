
const RewardToken = artifacts.require('RewardToken')
const KeenFactory = artifacts.require('KeenFactory')
const KeenRouter = artifacts.require('KeenRouter')
const KeenPair = artifacts.require('KeenPair')
const KeenUser = artifacts.require('KeenUser')

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

  let keenFactoryContract

  let keenRouterContract

  let WETH = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let WKEEN
  let keenUserContract

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

    fromUser = { from: accounts[deployer] }

    //usdt
    usdt = await RewardToken.new(deployer)
    await usdt.supply(companyUser,web3.utils.toWei('400000', 'ether'))
    await usdt.supply(committeeUser,web3.utils.toWei('100000', 'ether'))
    await usdt.supply(shareholdersUser,web3.utils.toWei('10000', 'ether'))
    

    keen = await RewardToken.new(deployer)
    await keen.supply(companyUser,web3.utils.toWei('400000', 'ether'))
    await keen.supply(committeeStackHolder,web3.utils.toWei('600000', 'ether'))
    await keen.supply(shareholdersUser,web3.utils.toWei('10000', 'ether'))

    WKEEN = await RewardToken.new(deployer)
    await WKEEN.supply(committeeUser,web3.utils.toWei('100000', 'ether'))


    keenFactoryContract = await KeenFactory.new(deployer)

    let tcpPosition = "0x77d34de33a75ac2a772f8C47080c0232Cbff463B"

    keenUserContract = await KeenUser.new(tcpPosition)
    //address _factory, address _WETH, address _WKEEN, address _keenUserContract, address _committeeStackHolder
    keenRouterContract = await KeenRouter.new(keenFactoryContract.address,WETH,WKEEN.address,keenUserContract.address,committeeStackHolder)
    await keen.approve(keenRouterContract.address,web3.utils.toWei('600000', 'ether'),committeeStackHolderFrom)
  })

  describe('initialize', function () {
    it('should be initialized with correct values', async function () {
      
      let committeeStackHolder = await keenRouterContract.committeeStackHolder()
      expect(committeeStackHolder).to.be.equal(deployer)
    })
  })

  // describe('createPair', function () {
  //   it('should be createPair with correct values', async function () {
  //     let {logs} = await keenFactoryContract.createPair(tokenA.address, tokenB.address,zero,zero,tokenB.address,web3.utils.toWei('2000000', 'ether'))
  //     let pair = await keenFactoryContract.getPair(tokenA.address, tokenB.address);
  //     console.log("pair:",pair)
  //     let keenPair = await KeenPair.at(pair)
  //     let length = await keenFactoryContract.allPairsLength()
  //     expect(length).to.be.eq.BN(1)
  //   })
  // })

  

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

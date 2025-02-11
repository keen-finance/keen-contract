
const RewardToken = artifacts.require('RewardToken')
const KeenFactory = artifacts.require('KeenFactory')
const KeenPair = artifacts.require('KeenPair')

const KeenConfig = artifacts.require('KeenConfig')
const DateTime = artifacts.require('DateTime')


const BN = web3.utils.BN
const expect = require('chai').use(require('bn-chai')(BN)).expect
const domain = 'KeenFactory'
const version = '1'

describe('KeenFactory', function () {
  this.timeout(100000)

  let zero = "0x0000000000000000000000000000000000000000"
  // Accounts
  let accounts

  let user

  let deployerUser

  let deployerFromUser



  let parent

  let fromUser


  let betReceive

  let betSender
  // Contracts
  let tokenA
  let tokenB

  let keenFactoryContract
  let keenConfigContract

  beforeEach(async function () {
    // Create Listing environment
    accounts = await web3.eth.getAccounts()

    user = accounts[1]

    parent = accounts[2]

    deployer = accounts[0]

    betReceive = accounts[9]

    betSender = accounts[10]

    fromUser = { from: accounts[deployer] }

    tokenA = await RewardToken.new(deployer,'USDT','USDT')
    await tokenA.supply(user,web3.utils.toWei('100000', 'ether'))
    tokenB = await RewardToken.new(deployer,'KEEN','KEEN')
    await tokenB.supply(user,web3.utils.toWei('100000', 'ether'))

    let dateTime = await DateTime.new();
    keenConfigContract = await KeenConfig.new(betReceive,betSender,dateTime.address);

    keenFactoryContract = await KeenFactory.new(deployer,keenConfigContract.address);

  })

  describe('initialize', function () {
    it('should be initialized with correct values', async function () {
      

      const feeToSetter = await keenFactoryContract.feeToSetter()
      
      expect(feeToSetter).to.be.equal(deployer)

      const keenConfig = await keenFactoryContract.keenConfig()
      expect(keenConfig).to.be.equal(keenConfigContract.address)
    })
  })

  describe('createPair', function () {
    it('should be createPair with correct values', async function () {
      let {logs} = await keenFactoryContract.createPair([tokenA.address, tokenB.address],[zero,zero],web3.utils.toWei('2000000', 'ether'))
      let pair = await keenFactoryContract.getPair(tokenA.address, tokenB.address);
      console.log("pair:",pair)
      let keenPair = await KeenPair.at(pair)
      let length = await keenFactoryContract.allPairsLength()
      expect(length).to.be.eq.BN(1)
    })
  })

  

  describe('addStack', function () {
    it('should be createPair with correct values', async function () {
      let {logs} = await keenFactoryContract.createPair([tokenA.address, tokenB.address],[zero,zero],web3.utils.toWei('2000000', 'ether'))
      let pair = await keenFactoryContract.getPair(tokenA.address, tokenB.address);
      console.log("pair:",pair)
      console.log("allStack:",web3.utils.toWei('2000000', 'ether').toString())

      let calculateStack = await keenFactoryContract.calculateStack(web3.utils.toWei('2000000', 'ether'),20);
      console.log("calculateStack:",calculateStack.toString())

      let calculateStackArray = await keenFactoryContract.calculateStackArray(web3.utils.toWei('2000000', 'ether'));
      console.log("calculateStackArray0:",calculateStackArray[0].toString())
      console.log("calculateStackArray1:",calculateStackArray[1].toString())
      console.log("calculateStackArray2:",calculateStackArray[2].toString())

      let keenPair = await KeenPair.at(pair)
      let companyStack = await keenPair.companyStack()
      expect(companyStack).to.be.eq.BN(web3.utils.toWei('400000', 'ether'))
      
      let committeeStack = await keenPair.committeeStack()
      expect(committeeStack).to.be.eq.BN(web3.utils.toWei('600000', 'ether'))
      
      let shareholderStack = await keenPair.shareholderStack()
      expect(shareholderStack).to.be.eq.BN(web3.utils.toWei('1000000', 'ether'))
      
      await keenFactoryContract.addStack(tokenA.address, tokenB.address,web3.utils.toWei('2000000', 'ether'))

      let companyStack2 = await keenPair.companyStack()
      expect(companyStack2).to.be.eq.BN(web3.utils.toWei('800000', 'ether'))
      
      let committeeStack2 = await keenPair.committeeStack()
      expect(committeeStack2).to.be.eq.BN(web3.utils.toWei('1200000', 'ether'))
      
      let shareholderStack2 = await keenPair.shareholderStack()
      expect(shareholderStack2).to.be.eq.BN(web3.utils.toWei('2000000', 'ether'))
      

      
    })
  })




})

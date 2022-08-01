
const KeenConfig = artifacts.require('KeenConfig')
const DateTime = artifacts.require('DateTime')

const BN = web3.utils.BN
const expect = require('chai').use(require('bn-chai')(BN)).expect
const domain = 'KeenConfig'
const version = '1'

describe('KeenConfig', function () {
  this.timeout(100000)

  // Accounts
  let accounts

  let user

  let betReceive

  let betSender

  let fromUser



  beforeEach(async function () {
    // Create Listing environment
    accounts = await web3.eth.getAccounts()

    betReceive = accounts[1]

    betSender = accounts[2]

    deployer = accounts[0]

    fromUser = { from: accounts[deployer] }

    let dateTime = await DateTime.new();
    
    KeenConfigContract = await KeenConfig.new(betReceive,betSender,dateTime.address);
  })

  describe('initialize', function () {
    it('should be initialized with correct values', async function () {
      let _betReceive = await KeenConfigContract.betReceive()
      expect(_betReceive).to.be.equal(betReceive)
    })
  })

  // describe('createStackUser', function () {
  //   it('should be createStackUser with correct values', async function () {
  //     const  isSuccess = await keenUserContract.createStackUser(user,1,parent,fromUser)
      
  //     const containsStackUser = await keenUserContract.containsStackUser(1,user)

  //     expect(containsStackUser).to.be.equal(true)
  //   })
  // })




})

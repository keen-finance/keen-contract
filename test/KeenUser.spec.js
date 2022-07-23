
const KeenUser = artifacts.require('KeenUser')

const BN = web3.utils.BN
const expect = require('chai').use(require('bn-chai')(BN)).expect
const domain = 'KeenUser'
const version = '1'

describe('KeenUser', function () {
  this.timeout(100000)

  // Accounts
  let accounts

  let user

  let deployerUser

  let deployerFromUser



  let parent

  let fromUser


  // Contracts
  let keenUserContract

  beforeEach(async function () {
    // Create Listing environment
    accounts = await web3.eth.getAccounts()

    user = accounts[1]

    parent = accounts[2]

    deployer = accounts[0]

    fromUser = { from: accounts[deployer] }

    tcpPosition = "0x77d34de33a75ac2a772f8C47080c0232Cbff463B"

    keenUserContract = await KeenUser.new(tcpPosition)
  })

  describe('initialize', function () {
    it('should be initialized with correct values', async function () {
      const contract = await KeenUser.new(tcpPosition)

      const hasRole = await contract.hasRole("0x00",deployer)
      
      expect(hasRole).to.be.equal(true)
    })
  })

  describe('createStackUser', function () {
    it('should be createStackUser with correct values', async function () {
      const  isSuccess = await keenUserContract.createStackUser(user,1,parent,fromUser)
      
      const containsStackUser = await keenUserContract.containsStackUser(1,user)

      expect(containsStackUser).to.be.equal(true)
    })
  })




})

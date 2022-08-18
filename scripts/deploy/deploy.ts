import { ethers } from "hardhat"

import {
  MANA_BYTECODE, RESCUE_ITEMS_SELECTOR,
  SET_APPROVE_COLLECTION_SELECTOR,
  SET_EDITABLE_SELECTOR
} from './utils'

import { BigNumber,utils } from "ethers";




/**
 * @dev Steps:
 * Deploy the Collection implementation
 * Deploy the committee with the desired members. The owner will be the DAO bridge
 * Deploy the collection Manager. The owner will be the DAO bridge
 * Deploy the forwarder. Caller Is the collection manager.
 * Deploy the collection Factory. Owner is the forwarder.
 */
async function main() {
  let WETH = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
  let zero = "0x0000000000000000000000000000000000000000"
  const accounts =  await ethers.provider.listAccounts();
  let betReceive = accounts[9]
  let betReceiveFrom = {from:betReceive}
  let betSender = accounts[10]
  let betSenderFrom = {from:betSender}

  let companyUser = accounts[1]
  let companyUserFrom = {from:companyUser}


  let usdtRecived = accounts[0];

  let committeeStackHolder = accounts[4]

  let committeeStackHolderFrom = { from: committeeStackHolder }




  const account = ethers.provider.getSigner()
  const deployer = await account.getAddress()

  let pancakeRouter = deployer;

  // Deploy the usdt、wusdt、keen
  const RewardToken = await ethers.getContractFactory("RewardToken")
  const usdt = await RewardToken.deploy(deployer,"USDT","USDT")
  console.log('usdt address:', usdt.address)

  const tcp = await RewardToken.deploy(deployer,"TCP","TCP")
  console.log('TCP address:', usdt.address)

  const wusdt = await RewardToken.deploy(deployer,"WUSDT","WUSDT")
  console.log('wusdt address:', wusdt.address)

  const keen = await RewardToken.deploy(deployer,"KEEN","KEEN")
  console.log('keen address:', keen.address)

  const WKEEN = await ethers.getContractFactory("WKEEN")
  const wkeen = await WKEEN.deploy(deployer,pancakeRouter,keen.address,usdt.address,usdtRecived)
  console.log('wkeen address:', wkeen.address)

  const DateTime = await ethers.getContractFactory("DateTime")
  const dateTime = await DateTime.deploy()
  console.log("dateTime address",dateTime.address);

  const KeenConfig = await ethers.getContractFactory("KeenConfig")
  const keenConfig = await KeenConfig.deploy(betReceive,betSender,dateTime.address)

  console.log("keenConfig address",keenConfig.address);
  const KeenFactory = await ethers.getContractFactory("KeenFactory")
  const keenFactory = await KeenFactory.deploy(deployer,keenConfig.address)
  console.log("keenFactory address",keenFactory.address);
  let pairResult = await keenFactory.createPair([keen.address,usdt.address],[zero,wusdt.address],utils.parseUnits('2000000','ether'))
  const KeenPair = await ethers.getContractFactory("KeenPair")
  let pair = await keenFactory.getPair(usdt.address, keen.address);
  
  const keenPair = await KeenPair.attach(pair)
  console.log("keenPair address",keenPair.address);


  let pairResult2 = await keenFactory.createPair([keen.address,tcp.address],[zero,zero],utils.parseUnits('2000000','ether'))
  
  let pair2 = await keenFactory.getPair(tcp.address, keen.address);

  const keenPair2 = await KeenPair.attach(pair2)
  console.log("keenPair2 address",keenPair2.address);

  let tcpPosition = "0x77d34de33a75ac2a772f8C47080c0232Cbff463B"
  const KeenUser = await ethers.getContractFactory("KeenUser")
    //create pair keenUserContract address _tcpPosition,address _keenRouter,address _keenConfig,address _dateTimeAPI,address _keenToken
  let  keenUser= await KeenUser.deploy(tcpPosition,keenConfig.address,dateTime.address,keen.address);
  console.log("keenUser address",keenUser.address);

  await keenUser.createStackUser(companyUser,1,zero)
  const KeenRouter = await ethers.getContractFactory("KeenRouter")


  let keenRouter = await KeenRouter.deploy(keenFactory.address,wkeen.address,keenUser.address,committeeStackHolder)
  console.log("keenRouter address",keenRouter.address);
  await keenUser.updateKeenRouter(keenRouter.address);

  await usdt.supply(pair,utils.parseEther('1000000'))
  await keen.supply(pair,utils.parseEther('1000000'))
  await tcp.supply(pair2,utils.parseEther('1000000'))
  await keen.supply(pair2,utils.parseEther('1000000'))
  
  // usdt address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  // wusdt address: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
  // keen address: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
  // wkeen address: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
  // dateTime address 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
  // keenConfig address 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
  // keenFactory address 0x0165878A594ca255338adfa4d48449f69242Eb8F
  // keenPair address 0x90fe37300e7DF485e9FeA8dF06bC8B638DfbF1C9
  // keenUser address 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6
  // keenRouter address 0x610178dA211FEF7D417bC0e6FeD39F05609AD788

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })

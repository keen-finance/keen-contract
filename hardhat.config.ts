require('babel-register')
require('babel-polyfill')
require('dotenv').config()

import '@nomiclabs/hardhat-truffle5'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-etherscan'
import "@typechain/hardhat";
import { getDeployParams } from './scripts/deploy/utils'

module.exports = {
  defaultNetwork: 'hardhat',
  typechain: {
    outDir: "types",
    target: "ethers-v5",
    alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    externalArtifacts: [], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
  },
  solidity: {
    compilers: [
      {
        version: '0.8.4',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.10',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.0',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.7.6',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.7.3',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.6.12',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.6.6',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.6.2',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.6.0',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.5.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.4.18',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.4.25',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ]
  },
  networks: {
    hardhat: {
      chainId: 1337,
      blockGasLimit: 10000000,
      gas: 10000000,
      initialBaseFeePerGas: 0,
      allowUnlimitedContractSize:true
    },
    local: {
      url: 'http://127.0.0.1:8545',
      blockGasLimit: 10000000,
      gas: 10000000,
      network_id: '*', // eslint-disable-line camelcase
    },
    matic: {
      url: 'https://polygon-rpc.com',
      blockGasLimit: 10000000,
      gas: 10000000,
      network_id: '*', // eslint-disable-line camelcase
      accounts:[process.env.PRIV_KEY]
    },
    deploy: getDeployParams()
  },
  gasReporter: {
    enabled: !!process.env.REPORT_GAS === true,
    currency: 'USD',
    gasPrice: 21,
    showTimeSpent: true
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
}

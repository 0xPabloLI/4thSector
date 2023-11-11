require('dotenv').config()

require('@openzeppelin/hardhat-upgrades')
require('@nomiclabs/hardhat-etherscan')
require('@nomiclabs/hardhat-waffle')
require('hardhat-gas-reporter')
require('solidity-coverage')
require('hardhat-contract-sizer')
require('hardhat-abi-exporter')
require('hardhat-log-remover')
require('@openzeppelin/hardhat-upgrades')

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

const PRIVATE_KEY = "d5a96ec9e91cfbd2ed0ae8a0c83b02efed1a7027c4cbf00a43d0a5b44afb259a";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.18',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      outputSelection: {
        '*': {
          '*': ['storageLayout'],
        },
      },
    },
  },
  networks: {
    hardhat: {
      initialBaseFeePerGas: 0, // workaround from https://github.com/sc-forks/solidity-coverage/issues/652#issuecomment-896330136 . Remove when that issue is closed.
      accounts: {
        mnemonic: process.env.SEED !== undefined ? process.env.SEED : '',
      },
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || '',
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    sepolia:{
      url: 'https://sepolia.infura.io/v3/d04fe3eb70274a71b9d7e23ee53d1f2d' ,
      accounts:[`${PRIVATE_KEY}`],      
    },
    goerli:{
      url: 'https://goerli.infura.io/v3/d04fe3eb70274a71b9d7e23ee53d1f2d' ,
      accounts:[`${PRIVATE_KEY}`],      
    },
    rinkeby: {
      url: process.env.RINKEBY_URL || '',
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    bscTestnet: {
      url: 'https://speedy-nodes-nyc.moralis.io/686e0bf9cdec5b8091a497be/bsc/testnet',
      accounts: [`${PRIVATE_KEY}`],
    },
    polygon: {
      url: 'https://polygon-mainnet.infura.io/v3/d04fe3eb70274a71b9d7e23ee53d1f2d' ,
      accounts:[`${PRIVATE_KEY}`],
    },
    polygonMumbai: {
      url: 'https://polygon-mumbai.infura.io/v3/d04fe3eb70274a71b9d7e23ee53d1f2d',
      accounts: [`${PRIVATE_KEY}`],
    },
    mainnet: {
      url: process.env.MAINNET_URL || '',
      accounts: [`${PRIVATE_KEY}`],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: 'USD',
    gasPrice: 200,
    showTimeSpent: true,
    coinmarketcap: process.env.COINMARKETCAP_API,
    // outputFile: './gasReporter',
    // noColors: true,
  },
  etherscan: {
    apiKey: {
      bscTestnet: 'BGRCJPSF33F57UGYGS8FW2NQ5YS8DV8I9Z',
      mainnet: process.env.ETHERSCAN_API_KEY,
      polygonMumbai: 'I8MVYPV97JZTE1PSB2BA8D4R87IX1B21I7',
      polygon: 'I8MVYPV97JZTE1PSB2BA8D4R87IX1B21I7',
      sepolia: 'DS63WJJHWAUBSZ2VEMV3J6HAVS116DNWQW',
      goerli: 'DS63WJJHWAUBSZ2VEMV3J6HAVS116DNWQW',
    }
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  abiExporter: [
    {
      path: './abi/',
      clear: true,
      flat: true,
      only: ['4thSector'],
      spacing: 2,
      pretty: true,
    },
    {
      path: './abi/ugly',
      only: ['4thSector'],
      clear: true,
      flat: true,
      pretty: false,
    },
  ],
}

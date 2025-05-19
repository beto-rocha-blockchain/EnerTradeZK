require("@nomicfoundation/hardhat-toolbox");
const path = require("path");
require('dotenv').config();
const snarkjs = require("snarkjs");
const fs = require("fs");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  resolver: {
    paths: [path.resolve(__dirname, "node_modules")]
  },
  networks: {
    infura: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [process.env.PRIVATE_KEY]
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [process.env.PRIVATE_KEY]
    },
    zkverifyTestnet: {
      url: "https://rpc.zkverify.xyz",
      chainId: 810180,
      accounts: [process.env.PRIVATE_KEY],
      verify: {
        etherscan: {
          apiUrl: "https://explorer.zkverify.xyz/api"
        }
      },
      httpHeaders: {
        "User-Agent": "Hardhat"
      }
    }
  }
};

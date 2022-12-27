import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";

dotenv.config();

const chainIds = {
  goerli: 5,
  hardhat: 31337,
  geth: 15,
};

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    geth: {
      url: "http://127.0.0.1:8545/",
      accounts: [process.env.WALLET_SECRET!],
      chainId: chainIds.geth,
    },
    goerli: {
      url: process.env.CHAIN_URL!,
      accounts: [process.env.WALLET_SECRET!],
      chainId: chainIds.goerli,
    },
  },
};

export default config;

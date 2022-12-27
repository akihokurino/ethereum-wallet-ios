import { ethers } from "hardhat";

async function main() {
  const SimpleToken = await ethers.getContractFactory("SimpleToken");
  const simpleToken = await SimpleToken.deploy(1000);
  await simpleToken.deployed();
  console.log("SimpleToken deployed to:", simpleToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

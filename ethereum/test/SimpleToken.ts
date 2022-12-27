import { expect } from "chai";
import { ethers } from "hardhat";

describe("SimpleToken", function () {
  it("should get balance", async function () {
    const [owner] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("SimpleToken");
    const contract = await Contract.deploy(1000);
    await contract.deployed();

    const balance = await contract.balanceOf(owner.address);
    expect(balance).to.equal(1000);
  });

  it("should send token", async function () {
    const [owner, other] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("SimpleToken");
    const contract = await Contract.deploy(1000);
    await contract.deployed();

    await contract.transfer(other.address, 100);

    const balance1 = await contract.balanceOf(owner.address);
    expect(balance1).to.equal(900);

    const balance2 = await contract.balanceOf(other.address);
    expect(balance2).to.equal(100);
  });
});

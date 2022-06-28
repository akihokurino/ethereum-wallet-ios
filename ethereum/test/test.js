const TokenA = artifacts.require("TokenA");
const TokenB = artifacts.require("TokenB");
const TokenC = artifacts.require("TokenC");

contract("TokenA", (accounts) => {
  it("should put 1000 Token in the first account", async () => {
    const contract = await TokenA.deployed();
    const balance = await contract.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), 1000, "1000 wasn't in the first account");
  });

  it("send 100 Token to the second account", async () => {
    const contract = await TokenA.deployed();
    await contract.transfer(accounts[1], 100);

    const balance1 = await contract.balanceOf.call(accounts[0]);
    assert.equal(balance1.valueOf(), 900, "900 wasn't in the first account");

    const balance2 = await contract.balanceOf.call(accounts[1]);
    assert.equal(balance2.valueOf(), 100, "100 wasn't in the second account");
  });
});

contract("TokenB", (accounts) => {
  it("should put 1000 Token in the first account", async () => {
    const contract = await TokenB.deployed();
    const balance = await contract.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), 1000, "1000 wasn't in the first account");
  });

  it("send 100 Token to the second account", async () => {
    const contract = await TokenB.deployed();
    await contract.transfer(accounts[1], 100);

    const balance1 = await contract.balanceOf.call(accounts[0]);
    assert.equal(balance1.valueOf(), 900, "900 wasn't in the first account");

    const balance2 = await contract.balanceOf.call(accounts[1]);
    assert.equal(balance2.valueOf(), 100, "100 wasn't in the second account");
  });
});

contract("TokenC", (accounts) => {
  it("should put 1000 Token in the first account", async () => {
    const contract = await TokenC.deployed();
    const balance = await contract.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), 1000, "1000 wasn't in the first account");
  });

  it("send 100 Token to the second account", async () => {
    const contract = await TokenC.deployed();
    await contract.transfer(accounts[1], 100);

    const balance1 = await contract.balanceOf.call(accounts[0]);
    assert.equal(balance1.valueOf(), 900, "900 wasn't in the first account");

    const balance2 = await contract.balanceOf.call(accounts[1]);
    assert.equal(balance2.valueOf(), 100, "100 wasn't in the second account");
  });
});

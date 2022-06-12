const Token = artifacts.require("Token");

contract("Token", (accounts) => {
  it("should put 1000 Token in the first account", async () => {
    const tokenInstance = await Token.deployed();
    const balance = await tokenInstance.balanceOf.call(accounts[0]);

    assert.equal(balance.valueOf(), 1000, "1000 wasn't in the first account");
  });
});

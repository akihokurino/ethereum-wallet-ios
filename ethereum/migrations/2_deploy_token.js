const TokenA = artifacts.require("TokenA");
const TokenB = artifacts.require("TokenB");
const TokenC = artifacts.require("TokenC");

module.exports = function (deployer) {
  deployer.deploy(TokenA, 1000, {
    gas: 2000000,
  });
  deployer.deploy(TokenB, 1000, {
    gas: 2000000,
  });
  deployer.deploy(TokenC, 1000, {
    gas: 2000000,
  });
};

const Token = artifacts.require("Token");

module.exports = function (deployer) {
  deployer.deploy(Token, 1000, {
    gas: 2000000,
  });
};

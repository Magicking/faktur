var FakturVerifier = artifacts.require("./FakturVerifier.sol");

module.exports = function(deployer) {
  deployer.deploy(FakturVerifier);
};

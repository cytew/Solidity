var EtherStore = artifacts.require("./EtherStore.sol");

module.exports = function(deployer) {
  deployer.deploy(EtherStore);
};

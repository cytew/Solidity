var EtherStore = artifacts.require("./EtherStore.sol");
var Attack = artifacts.require("./Attack.sol");

module.exports = function(deployer) {
  deployer.deploy(EtherStore).then(function(){
    return deployer.deploy(Attack,EtherStore.address);	


  });
};

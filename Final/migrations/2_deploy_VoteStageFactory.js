const VoteStageFactory = artifacts.require("VoteStageFactory");

module.exports = function(deployer) {
  deployer.deploy(VoteStageFactory,"test","10","3");
};

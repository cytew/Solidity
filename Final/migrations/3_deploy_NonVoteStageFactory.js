const NonVoteStageFactory = artifacts.require("NonVoteStageFactory");

module.exports = function(deployer) {
  deployer.deploy(NonVoteStageFactory,"test","10","3");
};

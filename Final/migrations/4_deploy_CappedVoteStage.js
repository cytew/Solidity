const CappedVoteStageFactory = artifacts.require("CappedVoteStageFactory");

module.exports = function(deployer) {
  deployer.deploy(CappedVoteStageFactory,"test","10","3");
};

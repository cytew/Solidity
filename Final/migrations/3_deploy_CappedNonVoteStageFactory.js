const CappedNonVoteStageFactory = artifacts.require("CappedNonVoteStageFactory");

module.exports = function(deployer) {
  deployer.deploy(CappedNonVoteStageFactory,"test","10","3");
};

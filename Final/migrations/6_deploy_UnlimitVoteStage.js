const UnlimitVoteStageFactory = artifacts.require("UnlimitVoteStageFactory");

module.exports = function(deployer) {
  deployer.deploy(UnlimitVoteStageFactory,"test","10","3");
};

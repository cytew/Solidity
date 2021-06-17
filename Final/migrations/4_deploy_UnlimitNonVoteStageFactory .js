const UnlimitNonVoteStageFactory = artifacts.require("UnlimitNonVoteStageFactory");

module.exports = function(deployer) {
  deployer.deploy(UnlimitNonVoteStageFactory,"test","10","3");
};

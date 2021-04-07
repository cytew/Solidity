  
var METoken = artifacts.require("METoken");
var METFaucet = artifacts.require("METFaucet");
var owner = web3.eth.accounts[0];

module.exports = function(deployer) {
  deployer.deploy(METoken, {from: owner}).then(function(){
	return deployer.deploy(METFaucet, METoken.address, owner);

	});
}

pragma solidity ^0.4.22;

import 'openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';


contract METFaucet {

	StandardToken public METoken;
	address public METOwner;

	function METFaucet(address _METoken, address _METOwner) public {

		METoken = StandardToken(_METoken);
		METOwner = _METOwner;
	}

	function withdraw(uint withdraw_amount) public {

    	require(withdraw_amount <= 1000);

		METoken.transferFrom(METOwner, msg.sender, withdraw_amount);
    }

	function () public payable { revert(); }

}

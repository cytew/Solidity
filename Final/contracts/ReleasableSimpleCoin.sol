pragma solidity ^0.4.23;

import "./ReleasableToken.sol";
import "./SimpleCoin.sol";

contract ReleasableSimpleCoin is ReleasableToken, SimpleCoin {
    bool public released = false;

    modifier canTransfer() {
        if(!released) {
            revert();
        }
        _;
    }

    constructor(uint256 _initialSupply) SimpleCoin(_initialSupply) public {}

    function release() onlyOwner public {
        released = true;
    }

    function transfer(address _to, uint256 _amount) canTransfer public {
        super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) canTransfer public returns (bool) {
        super.transferFrom(_from, _to, _amount);
    }
}

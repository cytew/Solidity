pragma solidity ^0.4.22;

// Our first contract is a faucet!

contract owned{
    address owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner,"Not contract owner");
        _;
    }
}

contract motal is owned {
    function destroy() public onlyOwner{
        selfdestruct(owner);
    }
}

contract Faucet is motal{
    
    event Withdrawal(address indexed to,uint amount);
    event Deposit(address indexed from,uint amout);

    function withdraw(uint withdraw_amount) public{
        
        require(withdraw_amount <= 0.1 ether,"Insufficient balance");
        
        msg.sender.transfer(withdraw_amount);
        emit Withdrawal(msg.sender,withdraw_amount);
    }
    
    function () external payable {
        emit Deposit(msg.sender, msg.value);
    }
}

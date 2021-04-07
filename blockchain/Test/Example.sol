pragma solidity ^0.5.16;

contract example{

  address contractOwner;

  constructor () public {
    contractOwner = msg.sender;
  }
}

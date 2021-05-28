pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;

interface ReleasableToken {
    function burn(uint256 _value) external;
    function getCoinBalance(address target) external returns(uint256) ;
    function mint(address _beneficiary, uint256 _numberOfTokens) external;
    function release() external;
    function transfer(address _to, uint256 _amount) external;
}

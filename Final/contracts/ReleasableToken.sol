pragma solidity ^0.4.23;

interface ReleasableToken {
    function burn(uint256 _value,address _investor) external;
    function getCoinBalance(address target) external returns(uint256) ;
    function mint(address _beneficiary, uint256 _numberOfTokens) external;
    function release() external;
    function transfer(address _to, uint256 _amount) external;
}

pragma solidity ^0.4.23;

import "./StageFactory.sol";
import "./VoteStageFactory.sol";

contract LimitStrategy{
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) public view returns (bool);
}

contract CappedStrategy is LimitStrategy {
    uint256 limitCap;

    constructor(uint256 _limitCap) public {
        require(_limitCap > 0);
        limitCap = _limitCap;
    }

    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) public view returns (bool) {
        bool check = _fullInvestmentReceived + _investment < limitCap;
        return check;
    }
}

contract UnlimitedStrategy is LimitStrategy {
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) public view returns (bool) {
        return true;
    }
}

contract CappedVoteStage is VoteStageFactory{
    uint256 limitCap;
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) VoteStageFactory(_name,_totalAmount,_numOfChoices) payable public{
    }
    function createLimitStrategy() internal returns (LimitStrategy) {
        return new CappedStrategy(10000); //Setting max limit!!
    }
}

contract UnlimitedVoteStage is VoteStageFactory{ // CappedVoteStage로 되어 있는데 변경 필요
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) VoteStageFactory(_name,_totalAmount,_numOfChoices)payable public{
    }
    function createLimitStrategy() internal returns (LimitStrategy){
        return new UnlimitedStrategy();
    }
}

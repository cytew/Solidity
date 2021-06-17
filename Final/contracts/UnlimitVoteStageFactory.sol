pragma solidity ^0.4.23;

import "./VoteStageFactory.sol";


contract UnlimitVoteStageFactory is VoteStageFactory { //이번에는 각 메뉴별 이 아니라 투자 금액에 따른 투표권을 부여받아 투표권으로 메뉴 선택

    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) VoteStageFactory(_name,_totalAmount,_numOfChoices) public{

    }
    function attendStage() public payable{
        require(isChoiceFinalized,"Need To Set Choice");
        //require(isValidInvestment(msg.value));

        address investor = msg.sender;
        uint256 investment = msg.value;


        info_participant[investor].investMoney += investment; // 여기 두줄은 추가적인 정보작성
        investmentReceived += investment;

        assignTokens(investor, investment); // 투자하였음으로 금액에 따른 코인을 부여받는다.

    }

}

pragma solidity ^0.4.23;

import "./NonVoteStageFactory.sol";

contract UnlimitNonVoteStageFactory is NonVoteStageFactory { //이번에는 각 메뉴별 이 아니라 투자 금액에 따른 투표권을 부여받아 투표권으로 메뉴 선택
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) NonVoteStageFactory(_name,_totalAmount,_numOfChoices) public{
    }

    function attendStage(uint _choice) public payable{//스테이지 참가 함수
        require(isChoiceFinalized,"Choice Not Finalized");
        //require(isValidInvestment(msg.value));
        require(!isInvestmentHigher);

        address investor = msg.sender;
        uint256 investment = msg.value;

        infoChoice[_choice].numOfParticipants++; // 초이스 참가 인원 추가
        infoChoice[_choice].investment_till_now += investment; // 초이스별 현재까지 투자받은 금액 += balance
        infoChoice[_choice].participantsOfChoice.push(investor);
        info_participant[investor].investMoney += investment; // 참가자의 현재까지 투자 금액
        info_participant[investor].choice_name =  infoChoice[_choice].choice_name; // 참가자의 투자 초이스 이름
    }
}

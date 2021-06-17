pragma solidity ^0.4.23;

import "./StageFactory.sol";

contract NonVoteStageFactory is StageFactory{
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) StageFactory(_name,_totalAmount,_numOfChoices) public{
        isFinalized = false; //초기값 false
        isTimesetOnce = 0;
        isInvestmentHigher = false;

    }

    function getChoiceInfo(uint _choiceId) public view returns(string,address,uint){//초이스들 자세하게 각각 확인 가능한 한 함수
        return (infoChoice[_choiceId].choice_name ,infoChoice[_choiceId].choice_address ,infoChoice[_choiceId].investment_till_now);
    }


    function checkMaxInvestment()internal returns(uint){ // 최대 투자 금액 뭔지 확인하는 함수
        uint max;
        max = infoChoice[0].investment_till_now;
        for(uint i =0;i<numOfChoices;i++){ // 최대 금액이 적힌 초이스 확인

            if (max < infoChoice[i].investment_till_now){
                max = infoChoice[i].investment_till_now;
                max_choice_index = i;
            }
        }
        require(max>= totalAmount,"There are no Choice ready"); // 적힌 금액이 총 모금액에 도달하는지 확인
        return max_choice_index;
    }





    function refund() public{ //투자 금액이 총 모금액에 도달하지 않았고 시간또한 초과 되었을때 함수
        //require(now>=endTime);
        require(isChoiceFinalized);
        require(!isFinalized);

        for(uint i =0;i<numOfChoices;i++){ // refund for those who are not selected
            for(uint k=0;k<infoChoice[i].numOfParticipants;k++){
                address notSelected = infoChoice[i].participantsOfChoice[k];
                notSelected.transfer(info_participant[notSelected].investMoney);
                info_participant[notSelected].investMoney -= info_participant[notSelected].investMoney;
            }
            infoChoice[i].investment_till_now = 0;
        }
        isFinalized=true;
    }


}

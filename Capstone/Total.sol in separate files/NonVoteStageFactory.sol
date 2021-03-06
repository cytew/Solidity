pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;

import "StageFactory.sol";

contract NonVoteStageFactory is StageFactory{
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) StageFactory(_name,_totalAmount,_numOfChoices) public{
    isFinalized = false; //초기값 false
    isTimeset = false;
    isInvestmentHigher = false;

  }

function getChoiceInfo(uint _choiceId) public view returns(string,address,uint){//초이스들 자세하게 각각 확인 가능한 한 함수
    return (infoChoice[_choiceId].choice_name ,infoChoice[_choiceId].choice_address ,infoChoice[_choiceId].investment_till_now);
}

function attendStage(uint _choice) public payable{//스테이지 참가 함수
    //require(isValidInvestment(msg.value));
    require(!isInvestmentHigher);

    infoChoice[_choice].numOfParticipants++; // 초이스 참가 인원 추가
    uint balance = msg.value;
    infoChoice[_choice].investment_till_now += balance; // 초이스별 현재까지 투자받은 금액 += balance
    infoChoice[_choice].participantsOfChoice.push(msg.sender);
    info_participant[msg.sender].investMoney += balance; // 참가자의 현재까지 투자 금액
    info_participant[msg.sender].choice_name =  infoChoice[_choice].choice_name; // 참가자의 투자 초이스 이름
}

  
function checkMaxInvestment()public returns(uint){ // 최대 투자 금액 뭔지 확인하는 함수
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



function finalizeStage(uint _max_choice_index) onlyOwner public{ // 투자 받은 금액이 총 모금액에 도달했을때 확인
    require(checkMaxInvestment()==_max_choice_index);
    require(!isFinalized);
    for(uint i =0;i<numOfChoices;i++){ // refund for those who are not selected

        if (i == _max_choice_index){ // 목표 금액에 도달했고 목표 금액 넘은 것 중에서 최대투자 금액 index
            infoChoice[i].choice_address.transfer(totalAmount); //사장님께 송금
            infoChoice[i].investment_till_now = 0;

            for(uint j=0;j<infoChoice[i].numOfParticipants;j++){ // 있어도 그만 없어도 그만
                address selected = infoChoice[i].participantsOfChoice[j];
                info_participant[selected].investMoney -= info_participant[selected].investMoney;
            }
        }
        else{
            for(uint k=0;k<infoChoice[i].numOfParticipants;k++){ // 얘네는 선택 받지 못한 애들이라서 돈 돌려줘야함
                address notSelected = infoChoice[i].participantsOfChoice[k];
                notSelected.transfer(info_participant[notSelected].investMoney);
                info_participant[notSelected].investMoney -= info_participant[notSelected].investMoney;
            }
            infoChoice[i].investment_till_now = 0;
        }
    }

    isFinalized=true;
}
//투자 금액이 총 모금액에 도달하지 않았고 시간또한 초과 되었을때 함수 만들어야함
}

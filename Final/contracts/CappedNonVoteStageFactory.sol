pragma solidity ^0.4.23;

import "./NonVoteStageFactory.sol";

contract CappedNonVoteStageFactory is NonVoteStageFactory { //이번에는 각 메뉴별 이 아니라 투자 금액에 따른 투표권을 부여받아 투표권으로 메뉴 선택
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) NonVoteStageFactory(_name,_totalAmount,_numOfChoices) public{
    }
    function attendStage(uint _choice) public payable{//스테이지 참가 함수
        require(isChoiceFinalized,"Choice Not Finalized");
        //require(isValidInvestment(msg.value));
        require(!isInvestmentHigher);

        address investor = msg.sender;
        uint256 investment = msg.value;
        uint256 refundinvestment;

        if(investment + infoChoice[_choice].investment_till_now > totalAmount){ // 최대 금액을 넘는 금액을 투자하였을때 넘는 금액은 되돌려준다.
            refundinvestment = investment - totalAmount + infoChoice[_choice].investment_till_now;
            investment = totalAmount - infoChoice[_choice].investment_till_now;
            investor.transfer(refundinvestment);
        }

        infoChoice[_choice].numOfParticipants++; // 초이스 참가 인원 추가
        infoChoice[_choice].investment_till_now += investment; // 초이스별 현재까지 투자받은 금액 += balance
        infoChoice[_choice].participantsOfChoice.push(investor);
        info_participant[investor].investMoney += investment; // 참가자의 현재까지 투자 금액
        info_participant[investor].choice_name =  infoChoice[_choice].choice_name; // 참가자의 투자 초이스 이름
    }
    function finalizeStage(uint _max_choice_index) onlyOwner public{// 투자 받은 금액이 총 모금액에 도달했을때 확인
        //require(now<endTime);
        require(isChoiceFinalized);
        require(checkMaxInvestment()==_max_choice_index,"Not a Max Choice");
        require(!isFinalized);
        for(uint i =0;i<numOfChoices;i++){ // refund for those who are not selected

            if (i == _max_choice_index){ // 목표 금액에 도달했고 목표 금액 넘은 것 중에서 최대투자 금액 index
                infoChoice[i].choice_address.transfer(totalAmount); //사장님께 송금
                infoChoice[i].investment_till_now -= totalAmount;

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
}

pragma solidity ^0.4.23;
//pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract StageFactory is Ownable{

    event NewStage(uint zombieId, string name, uint totalAmount);

    string public name;  // 스테이지 이름
    uint256 public totalAmount; // 총 모금액
    uint256 public numOfChoices; // 초이스 개수
    uint256 startTime;  // 모집 시작 시간
    uint256 endTime;    // 모집 종료 시간
    bool public isFinalized; // 현재 컨트랙트(스테이지) 종료 되었는지
    bool isTimeset;   // 현재 컨트랙트 기한이 세팅되었는지
    bool public isInvestmentHigher;
    bool public isRefundingAllowed;
    uint max_choice_index;  // 목표금액에 달성한다면 최초로 가장 많이 달성한 금액
    mapping(uint   => Choice)      infoChoice;        // 초이스 별 금액과 현재까지 투자받은 비용
    mapping(address=> Participant) info_participant; // 투자자에게 받은 금액과 선택 메뉴


    struct Choice{
        string choice_name;        // 초이스 이름 ex) chicken
        address choice_address;    // 사장님 돈 받을 주소
        uint investment_till_now;  // 현재까지 초이스별 투자받은 금액
        address[] participantsOfChoice; // 초이스별 참가한 사람들 이름
        uint256 numOfParticipants;  // 초이스별 참가한 사람들 숫자
        uint256 numOfVotes;         // 추후에 투표하기 위해서 만들어 놓음
    }

    struct Participant{
        uint256 investMoney;  //참가자의 어떤 초이스에 얼마나 투자 했는지(금액)
        string choice_name;   //참가자가 어떤 초이스에 투자 했는지(이름)
    }


constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) public{
    name=_name;
    totalAmount=_totalAmount*1000000000000000000; // ether to wei
    numOfChoices=_numOfChoices;
    isFinalized = false; //초기값 flas
    isTimeset = false;
    isInvestmentHigher = false;
    isRefundingAllowed = false;
}

function setTime(uint256 _endTime) public{ // one time only
    require(!isTimeset);
    startTime = now;
    endTime = startTime + _endTime*1 seconds; //편하게 초 단위로 설정했는데 매번 세팅하기 귀찮아서 뒤에서 안쓴다
    isTimeset = true;
}

function setChoices(uint _num,address _choice_address,string _choice_name) public{ //컨트랙트에 초이스를 적어두는 함수
    require(_num<=numOfChoices); // 최대 개수 제한
    infoChoice[_num].choice_name=_choice_name; // Choice 이름
    infoChoice[_num].choice_address =_choice_address; // Choice 즉 추후에 선정된다면 돈을 받을 사장님 address
}

/*
function getChoices()public view returns(string[]){ // 초이스들 한번에 확인 할 수 있는 함수 자세하게는 안됨
    string[] memory result = new string[](numOfChoices);
    uint counter= 0;
    for(uint i=0;i<numOfChoices;i++){
        result[counter] = infoChoice[i].choice_name;
        counter++;
    }
    return (result);
}
*/

function isValidInvestment(uint256 _investment) internal view returns(bool){ //금액 valid 확인 함수
    bool nonZeroInvestment = _investment != 0;
    bool withinPeriod = now >= startTime && now <= endTime;
    return nonZeroInvestment && withinPeriod;
}

function getParticipantInfo(address _participant) public view returns(uint256,string){
    return (info_participant[_participant].investMoney,info_participant[_participant].choice_name);
}

}

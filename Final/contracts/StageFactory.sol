pragma solidity ^0.4.23;
//pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract StageFactory is Ownable{

    event NewStage(uint zombieId, string name, uint totalAmount);

    string public name;  // 스테이지 이름
    uint256 public totalAmount; // 총 모금액
    uint256 public numOfChoices; // 초이스 개수
    uint256 public startTime;  // 모집 시작 시간
    uint256 public endTime;    // 모집 종료 시간
    bool public isFinalized; // 현재 컨트랙트(스테이지) 종료 되었는지
    uint isTimesetOnce;   // 현재 컨트랙트 기한이 세팅되었는지
    bool public isInvestmentHigher;
    bool public isRefundingAllowed;
    bool isChoiceFinalized;
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
        isFinalized = false; //초기값 false
        isChoiceFinalized =false;
        isTimesetOnce = 0;
        isInvestmentHigher = false;
        isRefundingAllowed = false;
    }
    modifier timelimitset() {
        require(isTimesetOnce == 1);
        _;
    }

    function setChoices(uint _num,string _choice_address,string _choice_name) public { //컨트랙트에 초이스를 적어두는 함수
        require(!isChoiceFinalized);
        require(_num<=numOfChoices); // 최대 개수 제한
        infoChoice[_num].choice_name=_choice_name; // Choice 이름
        infoChoice[_num].choice_address =parseAddr(_choice_address); // Choice 즉 추후에 선정된다면 돈을 받을 사장님 address
    }

    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function finalizeChoice() public{
        require(!isChoiceFinalized);
        isChoiceFinalized=true;
    }


    function setTime(uint256 _endTime) public{ // one time only
        require(isChoiceFinalized);
        require(isTimesetOnce==0);
        startTime = now;
        endTime = startTime + _endTime*1 seconds; //편하게 초 단위로 설정했는데 매번 세팅하기 귀찮아서 뒤에서 안쓴다
        isTimesetOnce++;
    }


    function isValidInvestment(uint256 _investment) internal view returns(bool){ //금액 valid 확인 함수
        bool nonZeroInvestment = _investment != 0;
        bool withinPeriod = now >= startTime && now <= endTime;
        return nonZeroInvestment && withinPeriod;
    }

    function getParticipantInfo(address _participant) public view returns(uint256,string){
        return (info_participant[_participant].investMoney,info_participant[_participant].choice_name);
    }

}

pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;

/* 추가하면 좋을점 unlimited limited 로 나누어서 진행할수 있게 추가
그리고 아직 너무 중복되는 함수가 많고 깔끔하지 않음 */
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract SimpleCoin {
    mapping (address => uint256) public coinBalance;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenAccount(address target, bool frozen);

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;

        mint(owner, _initialSupply);
    }

    function transfer(address _to, uint256 _amount) public {
        require(_to != 0x0);
        require(coinBalance[msg.sender] > _amount);
        require(coinBalance[_to] + _amount >= coinBalance[_to] );//check overflow
        coinBalance[msg.sender] -= _amount;
        coinBalance[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }

    function authorize(address _authorizedAccount, uint256 _allowance) public returns (bool success) {
        allowance[msg.sender][_authorizedAccount] = _allowance;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_to != 0x0);
        require(coinBalance[_from] > _amount);
        require(coinBalance[_to] + _amount >= coinBalance[_to] );
        require(_amount <= allowance[_from][msg.sender]);

        coinBalance[_from] -= _amount;
        coinBalance[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function mint(address _recipient, uint256  _mintedAmount) onlyOwner public {
        coinBalance[_recipient] += _mintedAmount;
        emit Transfer(owner, _recipient, _mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenAccount(target, freeze);
    }
    
    function getCoinBalance(address target)public returns(uint256) {
        return coinBalance[target];
    }
}

interface ReleasableToken {
    function getCoinBalance(address target) external returns(uint256) ;
    function mint(address _beneficiary, uint256 _numberOfTokens) external;
    function release() external;
    function transfer(address _to, uint256 _amount) external;
}

contract ReleasableSimpleCoin is ReleasableToken, SimpleCoin {
    bool public released = false;

    modifier canTransfer() {
        if(!released) {
            revert();
        }
        _;
    }

    constructor(uint256 _initialSupply) SimpleCoin(_initialSupply) public {}

    function release() onlyOwner public {
        released = true;
    }

    function transfer(address _to, uint256 _amount) canTransfer public {
        super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) canTransfer public returns (bool) {
        super.transferFrom(_from, _to, _amount);
    }
}

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

function getChoices()public view returns(string[]){ // 초이스들 한번에 확인 할 수 있는 함수 자세하게는 안됨
    string[] memory result = new string[](numOfChoices);
    uint counter= 0;
    for(uint i=0;i<numOfChoices;i++){
        result[counter] = infoChoice[i].choice_name;
        counter++;
    }
    return (result);
}

function getChoiceInfo(uint _choiceId) public view returns(string,address,uint){//초이스들 자세하게 각각 확인 가능한 한 함수
    return (infoChoice[_choiceId].choice_name ,infoChoice[_choiceId].choice_address ,infoChoice[_choiceId].investment_till_now);
}

function isValidInvestment(uint256 _investment) internal view returns(bool){ //금액 valid 확인 함수
    bool nonZeroInvestment = _investment != 0;
    bool withinPeriod = now >= startTime && now <= endTime;
    return nonZeroInvestment && withinPeriod;
}

function getParticipantInfo(address _participant) public view returns(uint256,string){
    return (info_participant[_participant].investMoney,info_participant[_participant].choice_name);
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
/* 추가하면 좋을점 unlimited limited 로 나누어서 진행할수 있게 추가
그리고 아직 너무 중복되는 함수가 많고 깔끔하지 않음 */
contract VoteStageFactory is StageFactory { //이번에는 각 메뉴별 이 아니라 투자 금액에 따른 투표권을 부여받아 투표권으로 메뉴 선택

  uint256 public investmentReceived;
  uint256 public investmentRefunded;
  uint256 public winningChoiceId;

  ReleasableToken  public VoteToken;

  constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) StageFactory(_name,_totalAmount,_numOfChoices) public{
    isFinalized = false; //초기값 false
    isTimeset = false;
    isInvestmentHigher = false;
    VoteToken = createToken();
  }

  function createToken() internal returns (ReleasableToken) {
    return new ReleasableSimpleCoin(0);
  }

  function calculateNumberOfTokens(uint256 _investment) internal view returns (uint256) { //총 투표권의 개수는 100으로 했다
    return (_investment * 100) / totalAmount;
  }

  function assignTokens(address _beneficiary, uint256 _investment) internal {

    uint256 _numberOfTokens = calculateNumberOfTokens(_investment);
    VoteToken.mint(_beneficiary, _numberOfTokens);
  }

  function attendStage() public payable{
    //require(isValidInvestment(msg.value));
    require(!isInvestmentHigher);

    address investor = msg.sender;
    uint256 investment = msg.value;
    uint256 refundinvestment;

    if(investment + investmentReceived > totalAmount){ // 최대 금액을 넘는 금액을 투자하였을때 넘는 금액은 되돌려준다.
        refundinvestment = investment - totalAmount + investmentReceived;
        investment = totalAmount - investmentReceived;
        investor.transfer(refundinvestment);
    }

    info_participant[investor].investMoney += investment; // 여기 두줄은 추가적인 정보작성
    investmentReceived += investment;

    assignTokens(investor, investment); // 투자하였음으로 금액에 따른 코인을 부여받는다.

    if(investmentReceived == totalAmount){
        isInvestmentHigher = true;
    }

  }

  function finalize() onlyOwner public {
    if (isFinalized) revert();

    bool isCrowdsaleComplete = true; // = now > endTime; 일단은 편하게 처리하기 위해 주석으로 처리
    bool investmentObjectiveMet = investmentReceived >= totalAmount;

    if(isCrowdsaleComplete){
        if (investmentObjectiveMet)
            VoteToken.release(); // 서로간 투표권 주고받을수 있다.
        else
            isRefundingAllowed = true;

        isFinalized = true;
    }
  }

  function refund() public { //시간 체크 modifer 추가해야한다.
    if (!isRefundingAllowed) revert();

    address investor = msg.sender;
    uint256 investment = info_participant[investor].investMoney;
    if (investment == 0) revert();
    info_participant[investor].investMoney = 0;
    investmentRefunded += investment;

    if (!investor.send(investment)) revert();
  }

  function Vote(uint _choiceId, uint _VoteToken) public{
      //time needs to be set for voting
      address voter = msg.sender;
      require(_VoteToken<=100);
      require(VoteToken.getCoinBalance(voter) != 0);
      require(VoteToken.getCoinBalance(voter) >= _VoteToken); // msg.sender has to have at least 1 coin to vote
      infoChoice[_choiceId].numOfVotes += _VoteToken;
      VoteToken.transfer(0x0000000000000000000000000000000000000000,_VoteToken);
  }

  function getVotes(uint _choiceId) public view returns(uint){ //각 초이스별 현재 투표수
      return (infoChoice[_choiceId].numOfVotes);
  }

  function tallyVotes() public returns(uint){ // 투표 최대 득표 확인 교재 내용
      uint winningVoteCount =0;
      uint winningChoiceIndex = 0;


      for (uint i=0;i<numOfChoices;i++){
          if(infoChoice[i].numOfVotes > winningVoteCount){
              winningVoteCount = infoChoice[i].numOfVotes;
              winningChoiceIndex=i;
          }
      }
      winningChoiceId=winningChoiceIndex;
  }

  function endVote(uint _winningChoiceId) onlyOwner public{// 최대 득표된 초이스 사장님한테 송금
      require(winningChoiceId==_winningChoiceId);
      infoChoice[_winningChoiceId].choice_address.transfer(totalAmount);
  }
}

/*
contract LimitStrategy{
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) public view returns (bool);
}

contract CappedStrategy is LimitStrategy {
    uint256 limitCap;

    constructor(uint256 _limitCap) public {
        require(_limitCap > 0);
        limitCap = _limitCap;
    }

    function isFullInvestmentWithinLimit(uint256 _investment, 
        uint256 _fullInvestmentReceived) 
        public view returns (bool) {
        
        bool check = _fullInvestmentReceived + _investment < limitCap; 
        return check;
    }
}

contract UnlimitedStrategy is LimitStrategy {
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) 
        public view returns (bool) {
        return true;
    }
}

contract CappedVoteStage is VoteStageFactory{
    uint256 limitCap;
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) StageFactory(_name,_totalAmount,_numOfChoices) payable public{
    }
    function createLimitStrategy() 
        internal returns (LimitStrategy) {
        
        return new CappedStrategy(10000); //Setting max limit!!
    }
}

contract UnlimitedVoteStage is VoteStageFactory{ // CappedVoteStage로 되어 있는데 변경 필요
    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) StageFactory(_name,_totalAmount,_numOfChoices)payable public{
    }
    function createLimitStrategy() 
        internal returns (LimitStrategy) {
        
        return new UnlimitedStrategy(); 
    }
}
*/

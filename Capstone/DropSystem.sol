pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract Ownable {
    address public owner;//#A

    constructor() public {
        owner = msg.sender;//#B
    }

    modifier onlyOwner() {
        require(msg.sender == owner);//#C
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

        mint(owner, _initialSupply);//#A
    }
    
    function transfer(address _to, uint256 _amount) public {
        require(_to != 0x0); 
        require(coinBalance[msg.sender] > _amount);
        require(coinBalance[_to] + _amount >= coinBalance[_to] );
        coinBalance[msg.sender] -= _amount;  
        coinBalance[_to] += _amount;   
        emit Transfer(msg.sender, _to, _amount);  
    }
    
    function authorize(address _authorizedAccount, uint256 _allowance) public returns (bool success) {
        allowance[msg.sender][_authorizedAccount] = _allowance; 
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_to != 0x0);  //#A
        require(coinBalance[_from] > _amount); //#B
        require(coinBalance[_to] + _amount >= coinBalance[_to] ); //#C
        require(_amount <= allowance[_from][msg.sender]); //#D 
    
        coinBalance[_from] -= _amount; //#E
        coinBalance[_to] += _amount; //#F
        allowance[_from][msg.sender] -= _amount;//#G
        emit Transfer(_from, _to, _amount);//H
        return true;
    }
    
    function mint(address _recipient, uint256  _mintedAmount) onlyOwner public { //#A
        coinBalance[_recipient] += _mintedAmount; 
        emit Transfer(owner, _recipient, _mintedAmount); 
    }
    
    function freezeAccount(address target, bool freeze) onlyOwner public { //#A
        frozenAccount[target] = freeze;  
        emit FrozenAccount(target, freeze);
    }
}

interface ReleasableToken {
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
    }

    struct Participant{
        uint256 investMoney;  //참가자의 어떤 초이스에 얼마나 투자 했는지(금액)
        string choice_name;   //참가자가 어떤 초이스에 투자 했는지(이름)
    }


constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) public{
    name=_name;
    totalAmount=_totalAmount;
    numOfChoices=_numOfChoices;
    isFinalized = false; //초기값 flas
    isTimeset = false;
    isInvestmentHigher = false;
    isRefundingAllowed = false;
}

function setTime(uint256 _endTime) public{ // one time only
    require(!isTimeset);
    startTime = now;
    endTime = startTime + _endTime*1 seconds;
    isTimeset = true;
}

function setChoices(uint _num,address _choice_address,string _choice_name) public{ //컨트랙트에 초이스를 적어두는 함수
    require(_num<=numOfChoices); // 최대 개수 제한
    infoChoice[_num].choice_name=_choice_name; 
    infoChoice[_num].choice_address =_choice_address;
}

function getChoices()public view returns(string[]){ // 초이스들 한번에 확인 할 수 있는 함수
    string[] memory result = new string[](numOfChoices);
    uint counter= 0;
    for(uint i=0;i<numOfChoices;i++){
        result[counter] = infoChoice[i].choice_name;
        counter++;
    }
    return (result);
}

function getChoiceInfo(uint _choiceId) public view returns(string,address,uint){
    return (infoChoice[_choiceId].choice_name ,infoChoice[_choiceId].choice_address ,infoChoice[_choiceId].investment_till_now);
}

function isValidInvestment(uint256 _investment) internal view returns(bool){ //금액 valid 확인 함수
    bool nonZeroInvestment = _investment != 0;
    bool withinPeriod = now >= startTime && now <= endTime;
    return nonZeroInvestment && withinPeriod;
}

function attendStage(uint _choice) public payable{
    //require(isValidInvestment(msg.value));
    require(!isInvestmentHigher);

    infoChoice[_choice].numOfParticipants++;
    uint balance = msg.value;
    infoChoice[_choice].investment_till_now += balance; // 초이스별 현재까지 투자받은 금액 += balance
    infoChoice[_choice].participantsOfChoice.push(msg.sender);
    info_participant[msg.sender].investMoney += balance; // 참가자의 현재까지 투자 금액
    info_participant[msg.sender].choice_name =  infoChoice[_choice].choice_name; // 참가자의 투자 초이스 이름
}

function getParticipantInfo(address _participant) public view returns(uint256,string){
    return (info_participant[_participant].investMoney,info_participant[_participant].choice_name);
}

function checkMaxInvestment()public returns(uint){
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

        if (i == _max_choice_index){
            infoChoice[i].choice_address.transfer(totalAmount);
            infoChoice[i].investment_till_now = 0;
            
            for(uint j=0;j<infoChoice[i].numOfParticipants;j++){
                address selected = infoChoice[i].participantsOfChoice[j];
                info_participant[selected].investMoney -= info_participant[selected].investMoney;
            }
        }
        else{
            for(uint k=0;k<infoChoice[i].numOfParticipants;k++){
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


contract VoteStageFactory is StageFactory {
    
  uint256 public investmentReceived;
  uint256 public investmentRefunded;
    
  ReleasableToken  public VoteToken; 
      
  constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) StageFactory(_name,_totalAmount,_numOfChoices) public{
    isFinalized = false; //초기값 flas
    isTimeset = false;
    isInvestmentHigher = false;
    VoteToken = createToken();
  }
  
  function createToken() internal returns (ReleasableToken) {
    return new ReleasableSimpleCoin(0);
  }
  
  function calculateNumberOfTokens(uint256 _investment) internal view returns (uint256) {
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
    
    if(investment + investmentReceived > totalAmount){
        refundinvestment = investment - totalAmount + investmentReceived;
        investment = totalAmount - investmentReceived;
        investor.transfer(refundinvestment);
    }
    
    info_participant[investor].investMoney += investment;
    investmentReceived += investment;
    
    assignTokens(investor, investment);
    
    if(investmentReceived == totalAmount){
        isInvestmentHigher = true;
    }
    
  }
  
  function finalize() onlyOwner public {
    if (isFinalized) revert();
    
    //bool isCrowdsaleComplete = now > endTime; 
    bool investmentObjectiveMet = investmentReceived >= totalAmount;
            
    if (investmentObjectiveMet)
        VoteToken.release();
    else 
        isRefundingAllowed = true;
    
    isFinalized = true;
                  
  }
  
  function refund() public {
    if (!isRefundingAllowed) revert();
    
    address investor = msg.sender;
    uint256 investment = info_participant[investor].investMoney;
    if (investment == 0) revert();
    info_participant[investor].investMoney = 0;
    investmentRefunded += investment;

    if (!investor.send(investment)) revert();
  }
}

contract VotingStage is VoteStageFactory,ReleasableSimpleCoin{

  constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) VoteStageFactory(_name,_totalAmount,_numOfChoices) public {
  
  }
  
  function Vote(uint _choiceId,uint256 _VoteToken) public{
      address voter = msg.sender;
      infoChoice[_choiceId].investment_till_now += _VoteToken;
  }
  
  function endVote() onlyOwner public{
      
  }
}

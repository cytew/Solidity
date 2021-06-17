pragma solidity ^0.4.23;

import "./StageFactory.sol";
import "./ReleasableToken.sol";
import "./ReleasableSimpleCoin.sol";

contract VoteStageFactory is StageFactory { //이번에는 각 메뉴별 이 아니라 투자 금액에 따른 투표권을 부여받아 투표권으로 메뉴 선택
    uint256 public investmentReceived;
    uint256 public investmentRefunded;
    uint256 public winningChoiceId;
    mapping(address => uint256) investorVote;
    bool public isVotingAllowed;

    ReleasableToken  public VoteToken;

    constructor(string _name, uint256 _totalAmount,uint256 _numOfChoices) StageFactory(_name,_totalAmount,_numOfChoices) public{
        isFinalized = false; //초기값 false
        isTimesetOnce = 0;
        isInvestmentHigher = false;
        isVotingAllowed = false;
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
        investorVote[_beneficiary]=_numberOfTokens;
        VoteToken.mint(_beneficiary, _numberOfTokens);
    }

    function attendStage() public payable{
    }

    function finalize() onlyOwner public {
        require(isChoiceFinalized);

        if (isFinalized) revert();

        bool isCrowdsaleCompleteWithinTime = true; // = now < endTime; 일단은 편하게 처리하기 위해 주석으로 처리
        bool investmentObjectiveMet = investmentReceived >= totalAmount;

        if(isCrowdsaleCompleteWithinTime){
            if (investmentObjectiveMet){
                isVotingAllowed = true;
                VoteToken.release(); // 서로간 투표권 주고받을수 있다.
            }
            else
                isRefundingAllowed = true;

            isFinalized = true;
        }
    }

    function refund() public { //시간 체크 modifer 추가해야한다.
        //require(now>=endTime);
        require(isChoiceFinalized);
        if (!isRefundingAllowed) revert();

        address investor = msg.sender;
        uint256 investment = info_participant[investor].investMoney;
        if (investment == 0) revert();
        info_participant[investor].investMoney = 0;
        investmentRefunded += investment;

        if (!investor.send(investment)) revert();
    }

    function Vote(uint _choiceId, uint _VoteToken) public{
        require(isVotingAllowed);
        require(isChoiceFinalized);
        //time needs to be set for voting
        address voter = msg.sender;
        require(VoteToken.getCoinBalance(voter) != 0);
        require(VoteToken.getCoinBalance(voter) >= _VoteToken); // msg.sender has to have at least 1 coin to vote
        infoChoice[_choiceId].numOfVotes += _VoteToken;
        VoteToken.burn(_VoteToken,msg.sender);
        investorVote[msg.sender] -=_VoteToken;
    }

    function getMyVoteNum() public view returns (uint){
        return investorVote[msg.sender];
    }

    function getChoiceInfoVotes(uint _choiceId) public view returns(string, uint){ //각 초이스별 현재 투표수
        return (infoChoice[_choiceId].choice_name,infoChoice[_choiceId].numOfVotes);
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

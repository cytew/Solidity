const NonVoteStageFactory = artifacts.require("NonVoteStageFactory");
const CappedVoteStageFactory = artifacts.require("CappedVoteStageFactory");
const UnlimitVoteStageFactory = artifacts.require("UnlimitVoteStageFactory");
/*
contract("NonVoteStageFactory", function (accounts) {
  it("1,10,7 투자 그리고 사장한테 10 송금 확인", async () => {
    let instance = await NonVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];
      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();

      //await instance.setChoices(2, address3, 'hik');

      let val1 = 1;
      let val2 = 10;
      let val3 = 1;
      await instance.attendStage(0, {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage(1, {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage(2, {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });

      let chicken = await instance.getChoiceInfo(0);
      console.log(chicken);
      let pizza = await instance.getChoiceInfo(1);
      console.log(pizza);
      let hamburger = await instance.getChoiceInfo(2);
      console.log(hamburger);


      await instance.finalizeStage(1);
    } catch (e) {
      var err = e;
      console.log(e);
    }
    //assert.isOk(err instanceof Error, "final");
  });
});

contract("NonVoteStageFactory", function (accounts) {
  it("4,1,7 투자 그리고 실패했음으로 Refund 실행", async () => {

    let instance = await NonVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];
      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();

      let val1 = 4;
      let val2 = 1;
      let val3 = 7;
      await instance.attendStage(0, {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage(1, {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage(2, {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });

      let chicken = await instance.getChoiceInfo(0);
      console.log(chicken);
      let pizza = await instance.getChoiceInfo(1);
      console.log(pizza);
      let hamburger = await instance.getChoiceInfo(2);
      console.log(hamburger);

      await instance.refund();
    }catch (e1) {
      var err1 = e1;
      console.log(e1);
    }

  });
});

contract("NonVoteStageFactory", function (accounts) {
  it("1,1,1 투자 그리고 10 달성실패로 There is No Choice Ready 확인", async () => {
    let instance = await NonVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];
      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();


      let val1 = 1;
      let val2 = 1;
      let val3 = 1;
      await instance.attendStage(0, {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage(1, {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage(2, {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });

      let chicken = await instance.getChoiceInfo(0);
      console.log(chicken);
      let pizza = await instance.getChoiceInfo(1);
      console.log(pizza);
      let hamburger = await instance.getChoiceInfo(2);
      console.log(hamburger);


      await instance.finalizeStage(1);
    } catch (e) {
      var err = e;
      console.log(e);
    }
    //assert.isOk(err instanceof Error, "final");
  });
});

contract("CappedVoteStageFactory", function (accounts) {
  it("5,3,2 투자 그리고 각각 투표수 확인 50장 30장 20장 있어야 하고 투표 진행 후 결과 확인", async () => {
    let instance = await CappedVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];
      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();


      let val1 = 5;
      let val2 = 3;
      let val3 = 2;
      await instance.attendStage( {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });

      let voteNumAddress1 = await instance.getMyVoteNum({from: address1});
      let voteNumAddress2 = await instance.getMyVoteNum({from: address2});
      let voteNumAddress3 = await instance.getMyVoteNum({from: address3});

      let testVoteNumAddress1 =50;
      let testVoteNumAddress2 =30;
      let testVoteNumAddress3 =20;

      assert.equal(voteNumAddress1, testVoteNumAddress1);
      assert.equal(voteNumAddress2, testVoteNumAddress2);
      assert.equal(voteNumAddress3, testVoteNumAddress3);

      await instance.finalize();

      await instance.Vote(0,50,{from:address1});
      await instance.Vote(1,30,{from:address2});
      await instance.Vote(0,10,{from:address3});

      let chickenVote = await instance.getChoiceInfoVotes(0);
      console.log(chickenVote);
      let pizzaVote = await instance.getChoiceInfoVotes(1);
      console.log(pizzaVote);
      let hamburgerVote = await instance.getChoiceInfoVotes(2);
      console.log(hamburgerVote);

      assert.equal(chickenVote.toString(), "chicken,60");
      assert.equal(pizzaVote.toString(), "pizza,30");
      assert.equal(hamburgerVote.toString(), "hamburger,0");

      await instance.tallyVotes();

      await instance.endVote(0);


    } catch (e) {
      var err = e;
      console.log(e);
    }

  });
});
*/
contract("CappedVoteStageFactory", function (accounts) {
  it("5,3,1 투자 그리고 각각 투표수 확인 50장 30장 20장 있어야 하고 목표 금액 못채웠음으로 Refund 성공", async () => {
    let instance = await CappedVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];

      console.log('Before investment');
      let address1Balance = await web3.eth.getBalance(address1);
      console.log(address1Balance);
      let address2Balance = await web3.eth.getBalance(address2);
      console.log(address2Balance);
      let address3Balance = await web3.eth.getBalance(address3);
      console.log(address3Balance);

      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();


      let val1 = 5;
      let val2 = 3;
      let val3 = 1;
      await instance.attendStage( {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });

      let voteNumAddress1 = await instance.getMyVoteNum({from: address1});
      let voteNumAddress2 = await instance.getMyVoteNum({from: address2});
      let voteNumAddress3 = await instance.getMyVoteNum({from: address3});

      let testVoteNumAddress1 =50;
      let testVoteNumAddress2 =30;
      let testVoteNumAddress3 =10;

      assert.equal(voteNumAddress1, testVoteNumAddress1);
      assert.equal(voteNumAddress2, testVoteNumAddress2);
      assert.equal(voteNumAddress3, testVoteNumAddress3);

      await instance.finalize();
      console.log('After investment');
      let beforeAddress1Invest = await web3.eth.getBalance(address1);
      console.log(beforeAddress1Invest);
      let beforeAddress2Invest = await web3.eth.getBalance(address2);
      console.log(beforeAddress2Invest);
      let beforeAddress3Invest = await web3.eth.getBalance(address3);
      console.log(beforeAddress3Invest);

      await instance.refund({from:address1}); //Refund each time
      await instance.refund({from:address2});
      await instance.refund({from:address3});
      console.log('After Refund');
      let afterAddress1Invest = await web3.eth.getBalance(address1);
      console.log(afterAddress1Invest);
      let afterAddress2Invest = await web3.eth.getBalance(address2);
      console.log(afterAddress2Invest);
      let afterAddress3Invest = await web3.eth.getBalance(address3);
      console.log(afterAddress3Invest);



    } catch (e) {
      var err = e;
      console.log(e);
    }

  });
});

/*
contract("CappedVoteStageFactory", function (accounts) {
  it("6,4,2 투자 그러나 2 투자 시도에서 실패", async () => {
    let instance = await CappedVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];
      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();


      let val1 = 6;
      let val2 = 4;
      let val3 = 2;
      await instance.attendStage( {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });


    } catch (e) {
      var err = e;
      console.log(e);
    }

  });
});

contract("UnlimitVoteStageFactory", function (accounts) {
  it("6,4,12 투자 10 넘겼음에도 12 투자 시도에서 성공 투표할때 한명이 여러곳에 투표 투표한다음 그만큼 투표수 감소 확인", async () => {
    let instance = await UnlimitVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];
      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();


      let val1 = 6;
      let val2 = 4;
      let val3 = 12;
      await instance.attendStage( {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });

      let voteNumAddress1 = await instance.getMyVoteNum({from: address1});
      console.log(voteNumAddress1);
      let voteNumAddress2 = await instance.getMyVoteNum({from: address2});
      console.log(voteNumAddress2);
      let voteNumAddress3 = await instance.getMyVoteNum({from: address3});
      console.log(voteNumAddress3);

      let testVoteNumAddress1 =60;
      let testVoteNumAddress2 =40;
      let testVoteNumAddress3 =120;

      assert.equal(voteNumAddress1, testVoteNumAddress1);
      assert.equal(voteNumAddress2, testVoteNumAddress2);
      assert.equal(voteNumAddress3, testVoteNumAddress3);

      await instance.finalize();

      await instance.Vote(0,50,{from:address1});
      await instance.Vote(1,30,{from:address2});
      await instance.Vote(0,10,{from:address3});
      await instance.Vote(0,40,{from:address3});
      await instance.Vote(0,50,{from:address3});

      let AftervoteNumAddress1 = await instance.getMyVoteNum({from: address1});
      console.log(AftervoteNumAddress1);
      let AftervoteNumAddress2 = await instance.getMyVoteNum({from: address2});
      console.log(AftervoteNumAddress2);
      let AftervoteNumAddress3 = await instance.getMyVoteNum({from: address3});
      console.log(AftervoteNumAddress3);


    } catch (e) {
      var err = e;
      console.log(e);
    }

  });
});

contract("UnlimitVoteStageFactory", function (accounts) {
  it("6,4,12 투자 10 넘겼음에도 12 투자 시도에서 성공 finalize 안하면 투표 못하는거 확인", async () => {
    let instance = await UnlimitVoteStageFactory.deployed();

    try {
      let address1 = accounts[0];
      let address2 = accounts[1];
      let address3 = accounts[2];
      let company1 = accounts[3];
      let company2 = accounts[4];
      let company3 = accounts[5];
      await instance.setChoices(0, company1, "chicken");
      await instance.setChoices(1, company2, "pizza");
      await instance.setChoices(2, company3, "hamburger");

      await instance.finalizeChoice();


      let val1 = 6;
      let val2 = 4;
      let val3 = 12;
      await instance.attendStage( {
        from: accounts[0],
        value: web3.toWei(val1.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[1],
        value: web3.toWei(val2.toString(), "ether"),
      });
      await instance.attendStage( {
        from: accounts[2],
        value: web3.toWei(val3.toString(), "ether"),
      });

      let voteNumAddress1 = await instance.getMyVoteNum({from: address1});
      console.log(voteNumAddress1);
      let voteNumAddress2 = await instance.getMyVoteNum({from: address2});
      console.log(voteNumAddress2);
      let voteNumAddress3 = await instance.getMyVoteNum({from: address3});
      console.log(voteNumAddress3);

      let testVoteNumAddress1 =60;
      let testVoteNumAddress2 =40;
      let testVoteNumAddress3 =120;

      assert.equal(voteNumAddress1, testVoteNumAddress1);
      assert.equal(voteNumAddress2, testVoteNumAddress2);
      assert.equal(voteNumAddress3, testVoteNumAddress3);

      //await instance.finalize();

      await instance.Vote(0,50,{from:address1});
      await instance.Vote(1,30,{from:address2});
      await instance.Vote(0,10,{from:address3});
      await instance.Vote(0,40,{from:address3});
      await instance.Vote(0,50,{from:address3});

      let AftervoteNumAddress1 = await instance.getMyVoteNum({from: address1});
      console.log(AftervoteNumAddress1);
      let AftervoteNumAddress2 = await instance.getMyVoteNum({from: address2});
      console.log(AftervoteNumAddress2);
      let AftervoteNumAddress3 = await instance.getMyVoteNum({from: address3});
      console.log(AftervoteNumAddress3);


    } catch (e) {
      var err = e;
      console.log(e);
    }

  });
});
*/

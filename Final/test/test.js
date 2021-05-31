const NonVoteStageFactory = artifacts.require("NonVoteStageFactory");

contract("NonVoteStageFactory", function (accounts) {
  it("test choice", async () => {
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

      let checkMaxInvestment = await instance.checkMaxInvestment();
      console.log(checkMaxInvestment);

      await instance.finalizeStage(1);
    } catch (e) {
      var err = e;
      console.log(e);
    }
    //assert.isOk(err instanceof Error, "final");
  });
});
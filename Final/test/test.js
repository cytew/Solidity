const NonVoteStageFactory = artifacts.require("NonVoteStageFactory");

contract("NonVoteStageFactory", function (accounts) {
  it("test choice", async () => {
    let instance = await NonVoteStageFactory.deployed();

    try {
      let address1 = accounts[7];
      let address2 = accounts[8];
      let address3 = accounts[9];
      await instance.setChoices(0, address1, "hak");
      await instance.setChoices(1, address2, "hek");

      await instance.finalizeChoice();

      //await instance.setChoices(2, address3, 'hik');

      let val = 12;
      let val2 = 5;
      await instance.attendStage(0, {
        from: accounts[3],
        value: web3.toWei(val.toString(), "ether"),
      });
      await instance.attendStage(1, {
        from: accounts[4],
        value: web3.toWei(val2.toString(), "ether"),
      });

      let hak = await instance.getChoiceInfo(0);
      console.log(hak);
      let hek = await instance.getChoiceInfo(1);
      console.log(hek);

      await instance.finalizeStage(0);
    } catch (e) {
      var err = e;
      console.log(e);
    }
    //assert.isOk(err instanceof Error, "final");
  });
});

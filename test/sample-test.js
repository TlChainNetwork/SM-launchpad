const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Test start", function () {
  it("You should see success at the end", async function () {
    const all = await ethers.getSigners();
    const deployer = all[0];
    const user1 = all[1];
    const user2 = all[2];
    var signer = deployer;
    const MainToken = await ethers.getContractFactory("MainToken");
    const mainToken = await MainToken.deploy();
    await mainToken.deployed();
    console.log("MainToken is deployed at:" + mainToken.address)
    console.log("TLX decimal is " + await mainToken.decimals())
    const TheLuxuryStake = await ethers.getContractFactory("TheLuxuryStake");
    const stake = await TheLuxuryStake.deploy(mainToken.address);
    await stake.deployed();
    console.log("STAKE is deployed at:" + stake.address)
    console.log('deployer token balance is ' + (await mainToken.balanceOf(deployer.address)))
    await mainToken.transfer(stake.address, "10000000000000000000000000");
    await mainToken.connect(signer).approve(stake.address, "10000000000000000000000000")
    await stake.stakeTokens("1000000000000000000000000", 1);
    await stake.stakeTokens("2000000000000000000000000", 2);
    var stakeAmounts = await stake.getUserStakes();
    stakeAmounts.map((v, ind) => {
      var period = v.period;
      period = parseInt(period.toString());
      var amount = ethers.utils.formatEther(v.amount);
      // 1 TLX = 0.1% power - 1 luna
      // 1 TLX = 0.3% power  - 3 luni
      // 1 TLX = 0.5% power  - 6 luni
      // 1 TLX = 0.7% power  - 1 an 
      // 1 TLX = 1% power  - 3 ani
      var power = 0;
      var months = 0;
      switch(period){
        case 0:
          power = 0.1; months = 1; break;
        case 1:
          power = 0.3; months = 3;  break;
        case 2:
          power = 0.5; months = 6;  break;
        case 3:
          power = 0.7; months = 12;  break;
        case 4:
          power = 1; months = 36;  break;
      }
      power *= amount;
      console.log(`${ind}. You staked ${amount} TLX for ${months} months, and your power is ${power}%`);
    })
    
  });
});

const secondsInMonth = 2592000;
const delay = ms => new Promise(res => setTimeout(res, ms));
const increaseTime = async (_seconds) => {
  await network.provider.send("evm_increaseTime", [_seconds])
  await network.provider.send("evm_mine")
}

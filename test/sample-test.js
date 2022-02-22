const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Test start", function () {
  it("You should see success at the end", async function () {
    const all = await ethers.getSigners();
    const deployer = all[0];
    const user1 = all[1];
    const user2 = all[2];
    var signer = deployer;
    const LSO = await ethers.getContractFactory("LSO");
    const lso = await LSO.deploy();
    await lso.deployed();
    console.log("LSO is deployed at:" + lso.address)
    const TLX = await ethers.getContractFactory("TLX");
    const tlx = await TLX.deploy();
    await tlx.deployed();
    console.log("TLX is deployed at:" + tlx.address)

    const STAKE = await ethers.getContractFactory("STAKE");
    const stake = await STAKE.deploy(lso.address, tlx.address, {value:ethers.utils.parseEther("9000.0")});
    await stake.deployed();
    console.log("STAKE is deployed at:" + stake.address)
    // console.log(ethers)
    console.log("STAKE balance:" + await ethers.provider.getBalance(stake.address))
    // await signer.sendTransaction({to: stake.address, value:ethers.utils.parseEther("10.0")})
    console.log('deployer tlx balance is ' + (await tlx.balanceOf(deployer.address)))
    console.log('stake contract tlx balance is ' + (await tlx.balanceOf(stake.address)))
    await tlx.connect(signer).transfer(user1.address, "1000000000000000000000000000")
    await tlx.connect(signer).transfer(user2.address, "1000000000000000000000000000")
    await tlx.connect(signer).transfer(stake.address, "10000000000000000000000000000")
    await lso.connect(signer).transfer(stake.address, "10000000000000000000000000000")
    await lso.connect(signer).transfer(user1.address, "10000000000000000000000000000")
    console.log('deployer tlx balance is ' + (await tlx.balanceOf(deployer.address)))
    console.log('stake contract tlx balance is ' + (await tlx.balanceOf(stake.address)))
    //start TLC staking and unstaking
    console.log("--------starting TLC staking and unstaking test--------------")
    signer = user1;
    console.log('user1 TLC balance in wei before stake =' +await ethers.provider.getBalance(signer.address))
    console.log('staking 100 TLC')
    await stake.connect(signer).stakeTLC("100000000000000000000", { value: "100000000000000000000" });
    await increaseTime(secondsInMonth*36)
    console.log('yield amount after 3 years = ' +await stake.connect(signer).yieldedTLCAmount())
    await stake.connect(signer).unstakeTLC();
    console.log('user1 TLC balance in wei after unstaking =' +await ethers.provider.getBalance(signer.address))
    //start TLX staking and unstaking
    console.log("--------starting TLX staking and unstaking test--------------")
    await tlx.connect(signer).approve(stake.address, "200000000000000000000")
    console.log('user1 tlx balance before  1 year staking =' +await tlx.balanceOf(signer.address))
    console.log('staking 100 TLX')
    await stake.connect(signer).stakeTLX("100000000000000000000");

    await increaseTime(secondsInMonth*12);
    console.log("yield tlx amount after 1 year staking = ",await stake.connect(signer).yieldedTLXAmount())
    await stake.connect(signer).unstakeTLX();
    console.log('user1 tlx balance after  1 year staking =' +await tlx.balanceOf(signer.address))
    //start LSO staking and unstaking
    console.log("--------starting LSO staking and unstaking test--------------")
    await lso.connect(signer).approve(stake.address, "200000000000000000000")
    console.log('user1 LSO balance before  6 month staking =' +await lso.balanceOf(signer.address))
    console.log('staking 100 LSO')
    await stake.connect(signer).stakeLSO("100000000000000000000");

    await increaseTime(secondsInMonth*6);
    console.log("yield lso amount after 6 month staking = ",await stake.connect(signer).yieldedLSOAmount())
    await stake.connect(signer).unstakeLSO();
    console.log('user1 lso balance after  6 month staking =' +await lso.balanceOf(signer.address))
    
    console.log("success");
  });
});

const secondsInMonth = 2592000;
const delay = ms => new Promise(res => setTimeout(res, ms));
const increaseTime = async (_seconds) => {
  await network.provider.send("evm_increaseTime", [_seconds])
  await network.provider.send("evm_mine")
}
// const SIGNING_DOMAIN_NAME = "WEB3CLUB";
// const SIGNING_DOMAIN_VERSION = "1";



// describe("NFT", function () {
//   it("NFT test start", async function () {
//     const NCT = await ethers.getContractFactory("NameChangeToken");
//     const nct = await NCT.deploy("NCT", "NCT");
//     await nct.deployed();
//     console.log(`NCT is deployed at ${nct.address}`);

//     const Mask = await ethers.getContractFactory("Masks");
//     const mask = await Mask.deploy("Mask", "Mask", nct.address);
//     await mask.deployed();
//     console.log(`Masks is deployed at ${mask.address}`);
//     const [owner, addr1] = await ethers.getSigners();  
//     var chainId = await owner.getChainId();
//     console.log('chain id= ', chainId)
//     var sign = await SignHelper.getSign(owner, mask.address, chainId, 10, 'Web3');
//     console.log(sign)

//     var ret = await mask.check(10, 'Web3', sign.signature);
//     console.log(ret);
//     console.log(owner.address)

//   });
// });


// describe("Greeter", function () {
//   it("Should return the new greeting once it's changed", async function () {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
//     await greeter.deployed();
//
//     expect(await greeter.greet()).to.equal("Hello, world!");
//
//     const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
//
//     // wait until the transaction is mined
//     await setGreetingTx.wait();
//
//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });

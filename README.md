1 - npm install
2 - npx hardhat node
3 - open another terminal
4 - npx hardhat test --network localhost

**********important part**************
const rpc_url = "HTTP://127.0.0.1:8545";
const web3 = new Web3(rpc_url)
    const stakeContract = new web3.eth.Contract(TheLuxuryStakeABI.abi, stake.address)
    var stakeAmounts =[];
    stakeAmounts = await stakeContract.methods.getUserStakes(signer.address).call()
    // var stakeAmounts = await stake.getUserStakes(signer.address);
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
**********************end important part******************************

******************I made some tweaks on smart contract(TheLuxuryStake.sol)*************************
1. added constructor parameter for continuous deployment of 2 contracts
     constructor(address _token) {
2. added wallet address parameter for getting staked amount, So can call this function on backend or frontend without metamask and privatekey.
    function getUserStakes(address user) public view returns(Stake[] memory) {
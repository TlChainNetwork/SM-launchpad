// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TheLuxuryStake is Ownable {

    /*
    * Constructor since this contract is not ment to be used without inheritance
    * push once to stakeholders for it to work proplerly
    */
    constructor(address _token) {
        _stake_address = msg.sender;
        tokenAddress = _token;
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();

        // populate rewards
        _rewards.push(uint(1534)); // 15.35%
        _rewards.push(uint(2125)); // 21.25%
        _rewards.push(uint(2968)); // 29.68%
        _rewards.push(uint(4056)); // 40.56%
        _rewards.push(uint(8612)); // 86.12%s

        // populate periods with monts
        _periods.push(uint(1));
        _periods.push(uint(3));
        _periods.push(uint(6));
        _periods.push(uint(12));
        _periods.push(uint(36));
    }

    /**
    * A stake struct is used to represent the way we store stakes, 
    * A Stake will contain the users address, the amount staked and a timestamp, 
    * Since which is when the stake was made
    */
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        uint    period;      // this represent the stake interval - values 0 - 1 month, 1 - 3 months, 2 - 6 months, 3 - 12 months
        uint256 claimable;   // This claimable field is new and used to tell how big of a reward is currently available
    }

    /**
    * Stakeholder is a staker that has active stakes
    */
    struct Stakeholder{
        address user;
        Stake[] address_stakes;
    }

    /**
    * StakingSummary is a struct that is used to contain all stakes performed by a certain account
    */ 
     struct StakingSummary{
         uint256 total_amount;
         Stake[] stakes;
    }

    /**
    * @dev Details of each transfer
    * @param contract_ contract address of ER20 token to transfer
    * @param to_ receiving account
    * @param amount_ number of tokens to transfer to_ account
    * @param failed_ if transfer was successful or not
    */
    
    /** CONSTANTS **/

    // address immutable tokenAddress = 0xEA255909E46A54d54255219468991C69ca0e659D;
    address  tokenAddress = 0xC3A288D556453024Bbd9A09d57f23ff785f5718F;


    /** VARIABLES **/

    /*
    *   This is a array where we store all Stakes that are performed on the Contract
    *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
    */
    Stakeholder[] internal stakeholders;

    uint[] private _rewards;
    uint[] private _periods;

    address private _stake_address; // the addres where all stakes will deposit 

    /*
    * stakes is used to keep track of the INDEX for the stakers in the stakes array
    */
    mapping(address => uint256) internal stakes;

    ERC20 public ERC20Interface;

    uint256 public _total_staked;
    uint256 public _total_reward;

    /** EVENTS **/

    event StakeSuccessful(address indexed user, uint256 amount, uint256 index, uint256 timestamp, uint period);
    event StakeFailed(address indexed from_, address indexed to_, uint256 amount_);

    event WithdrawStakeSuccessful(address indexed user, uint256 amount, uint period);
    event WithdrawStakeFailed(address indexed to_, uint256 amount_);

    /** METHODS **/

    /**
    * getRewards will get the reward value for a specific period
    */
    function getRewards(uint index_) public view returns (uint) {
        return _rewards[index_];
    }

    /**
    * getRewards will get the reward value for a specific period
    */
    function setRewards(uint index_, uint256 percent_) external {
        require(index_ >= 0,'Index out of range');
        require(index_ < 5,'Index out of range');
         _rewards[index_] = percent_;
    }

    /**
    * getPeriod will get the period in months for a specific index
    */
    function getPeriod(uint index_) public view returns (uint) {
        return _periods[index_];
    }

    function getStakedAmount() public view returns (uint256) {
        return _total_staked;
    }

    function getTotalRewards() public view returns (uint256) {
        return _total_reward;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }


    /** BUSINESS LOGIC */

    /**
      * calculateStakeReward is used to calculate how much a user should be rewarded for their stakes
      * It depend on stake period
     */
    function calculateStakeReward(uint256 amount_, uint period_) internal view returns(uint256){
        uint reward = getRewards(period_);
        return (amount_*reward)/10000; // reward = (amount*(percent/100))/100 => reward = (amount * percent)/10000
    }

    /*
    *  _addStakeholder add a stakeholder to the stakeholders array
    */
    function _addStakeholder(address staker) internal returns (uint256){
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

    /*
    * method that handles transfer of ERC20 tokens to other address
    * it assumes the calling address has approved this contract as spender
    * @param amount_ numbers of token to transfer
    * @param period_ number of monts to stakes
    */
    function stakeTokens(uint256 amount_, uint period_) external {
        // Simple check so that user does not stake 0 
        require(amount_ > 0, "Cannot stake nothing");

        // first we try to create the stake
        address from_ = msg.sender;

        ERC20Interface =  ERC20(tokenAddress);
        if(amount_ > ERC20Interface.allowance(from_, address(this))) {
            emit StakeFailed(from_, address(this), amount_);
            revert();
        }

        // IMPORTANT !!! //
        // Before calling transferFrom, you need to call approve on the token contract for this contract address
        require(ERC20Interface.transferFrom(from_, address(this), amount_), 'Failed to transfer tokens to locker');

        // The stake is created, now we need to store the values inside the contract

        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];

        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;

        // See if the staker already has a staked index or if its the first time
        if(index == 0){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
        }

        uint256 reward = calculateStakeReward(amount_, period_);

        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(Stake(msg.sender, amount_, timestamp, period_, reward));

        // Emit an event that the stake has occured
        emit StakeSuccessful(from_, amount_, index,timestamp, period_);

        // update the total staked amount
        _total_staked = _total_staked + amount_;
        _total_reward = _total_reward + reward;
    }

    /**
     * @notice
     * _withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
    */
    function _withdrawStake(address beneficiary_, uint256 index_) internal{
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender]; // msg sender is the beneficiary_
        
        // identify the stake by stake index
        Stake memory current_stake = stakeholders[user_index].address_stakes[index_];
        uint256 amount = current_stake.amount;
        uint256 reward = current_stake.claimable;
        
        // check the conditions
        require (amount >= address(this).balance, 'We cannot process your request right now. Please come back later. Not enough amount in the contract storage.');
        
        // now checking the periods
        // check to see if the stake is locked
        uint stakeAge = (block.timestamp - current_stake.since)/(3600*24); // number of days
        uint period = getPeriod(current_stake.period) * 30; // number of days for lock

        require (stakeAge >= period, "Stake is locked for the initial defined period");

        // we can make the transfer now
        uint256 total = amount + reward;
        require(ERC20Interface.approve(address(this), total), 'Failed to approve tokens');
        require(ERC20Interface.transferFrom(address(this), beneficiary_, total), 'Failed to transfer tokens to beneficiary');
        
        // Remove by subtracting the money unstaked 
        current_stake.amount = current_stake.amount - amount;
        
        // If stake is empty, 0, then remove it from the array of stakes
        delete stakeholders[user_index].address_stakes[index_];

        // update the total staked amount
        _total_staked = _total_staked - amount;
        _total_reward = _total_reward + reward;

        emit WithdrawStakeSuccessful(beneficiary_, amount, period);
    }

    function withdrawStake(address beneficiary_, uint256 index_) external payable{
        require(stakes[msg.sender] != 0, 'User has no stake!');

        // do the magic
        _withdrawStake(beneficiary_, index_);
    }

    // getUserStakes will return all stakes for a user
    function getUserStakes(address user) public view returns(Stake[] memory) {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[user];
        // identify the stake by stake index
        Stake[] memory user_stakes = new Stake[](stakeholders[user_index].address_stakes.length);
        for (uint i=0 ; i < stakeholders[user_index].address_stakes.length; i++) {
            user_stakes[i] = stakeholders[user_index].address_stakes[i];
        }
        return user_stakes;
    }

    /**
    * @dev allow contract to receive funds
    */
    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
    * @dev withdraw funds from this contract
    * @param beneficiary address to receive ether
    */
    function withdraw(address payable beneficiary) public payable onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

}

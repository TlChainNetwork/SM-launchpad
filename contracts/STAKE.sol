// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

struct _stakeInfo{
    uint _time;
    uint _amount;
}

contract STAKE is ReentrancyGuard{
    using SafeMath for uint256;
    using SafeMath for uint8;
    using SafeMath for uint;
    IERC20 _lso;
    IERC20 _tlx;
    address _owner;
    address contractAddress;
    uint secondsInMonth = 2592000;
    uint[] powers_tlc = [1, 3, 5, 7, 10]; //div by 100
    uint[] months_tlc = [1 ,3, 6, 12, 36];
    uint[] powers_tlx = [10, 30, 50, 70, 100]; //div by 100
    uint[] months_tlx = [1 ,3, 6, 12, 36];
    uint[] powers_lso = [10, 30, 50, 70, 100]; //div by 100
    uint[] months_lso = [1 ,3, 6, 12, 36];
    uint powerAmount_tlc = 18750;
    uint powerAmount_tlx = 3000;
    uint powerAmount_lso = 42857;
    mapping(address => uint256) private stakedCountPerAddress_tlc;
    mapping(address => mapping(uint256 => _stakeInfo)) stakedInfo_tlc;
    mapping(address => uint256) private stakedCountPerAddress_tlx;
    mapping(address => mapping(uint256 => _stakeInfo)) stakedInfo_tlx;
    mapping(address => uint256) private stakedCountPerAddress_lso;
    mapping(address => mapping(uint256 => _stakeInfo)) stakedInfo_lso;

    event staked(address _staker, uint _stakedAmount, uint8 stakeType); //type=0: TLC token , type=1: TLX token, type=2: LSO token
    event unstaked(address _unstaker, uint _stakedAmount, uint8 stakeType); //type=0: TLC token , type=1: TLX token, type=2: LSO token


    constructor(address lso_, address tlx_) payable{
        _lso = IERC20(lso_);
        _tlx = IERC20(tlx_);
        _owner = msg.sender;
        contractAddress = address(this);
    }

    function stakeTLC(uint stakeAmount) public payable nonReentrant{
        require(msg.value == stakeAmount, "You have to pay stakeAmount");
        stakedCountPerAddress_tlc[msg.sender] = stakedCountPerAddress_tlc[msg.sender].add(1);
        uint256 count = stakedCountPerAddress_tlc[msg.sender];
        stakedInfo_tlc[msg.sender][count] = _stakeInfo(
            block.timestamp,
            stakeAmount
        );
        emit staked(msg.sender, stakeAmount, 0);
    }   

    function yieldedTLCAmount() public view returns(uint){
        
        uint count = 1;
        uint _staked = 0;
        for(;count<= stakedCountPerAddress_tlc[msg.sender]; count++){
            _stakeInfo memory info = stakedInfo_tlc[msg.sender][count];
            uint months = (block.timestamp - info._time) / secondsInMonth;
            uint power = powers_tlc[0];
            
            for(uint index=1; index<5; index++){
                if(months >= months_tlc[index]){
                    power = powers_tlc[index];                   
                }else{
                    break;
                }
            }
            _staked = _staked.add(power.mul(info._amount).mul(powerAmount_tlc).div(10000));
        }
        return _staked;
    }

    function unstakeTLC() public nonReentrant{
        uint _staked = yieldedTLCAmount();        
        payable(msg.sender).transfer(_staked);
        stakedCountPerAddress_tlc[msg.sender] = 0;
        emit unstaked(msg.sender, _staked, 0);
    }

    function stakeTLX(uint stakeAmount) public nonReentrant{
        require(_tlx.allowance(msg.sender, contractAddress) >= stakeAmount, "Approved amount is less than staking amount.");
        _tlx.transferFrom(msg.sender, contractAddress, stakeAmount);
        stakedCountPerAddress_tlx[msg.sender] = stakedCountPerAddress_tlx[msg.sender].add(1);
        uint256 count = stakedCountPerAddress_tlx[msg.sender];
        stakedInfo_tlx[msg.sender][count] = _stakeInfo(
            block.timestamp,
            stakeAmount
        );
        emit staked(msg.sender, stakeAmount, 1);
    }

    function yieldedTLXAmount() public view returns(uint){
        
        uint count = 1;
        uint _staked = 0;
        for(;count<= stakedCountPerAddress_tlx[msg.sender]; count++){
            _stakeInfo memory info = stakedInfo_tlx[msg.sender][count];
            uint months = (block.timestamp - info._time) / secondsInMonth;
            uint power = powers_tlx[0];
            
            for(uint index=1; index<5; index++){
                if(months >= months_tlx[index]){
                    power = powers_tlx[index];                   
                }else{
                    break;
                }
            }
            _staked = _staked.add(power.mul(info._amount).mul(powerAmount_tlx).div(10000));
        }
        return _staked;
    }

    function unstakeTLX() public nonReentrant{
        uint _staked = yieldedTLXAmount();        
        _tlx.transfer(msg.sender, _staked);
        stakedCountPerAddress_tlx[msg.sender] = 0;
        emit unstaked(msg.sender, _staked, 1);
    }

    function stakeLSO(uint stakeAmount) public nonReentrant{
        require(_lso.allowance(msg.sender, contractAddress) >= stakeAmount, "Approved amount is less than staking amount.");
        _lso.transferFrom(msg.sender, contractAddress, stakeAmount);
        stakedCountPerAddress_lso[msg.sender] = stakedCountPerAddress_lso[msg.sender].add(1);
        uint256 count = stakedCountPerAddress_lso[msg.sender];
        stakedInfo_lso[msg.sender][count] = _stakeInfo(
            block.timestamp,
            stakeAmount
        );
        emit staked(msg.sender, stakeAmount, 2);
    }

    function yieldedLSOAmount() public view returns(uint){
        
        uint count = 1;
        uint _staked = 0;
        for(;count<= stakedCountPerAddress_lso[msg.sender]; count++){
            _stakeInfo memory info = stakedInfo_lso[msg.sender][count];
            uint months = (block.timestamp - info._time) / secondsInMonth;
            uint power = powers_lso[0];
            
            for(uint index=1; index<5; index++){
                if(months >= months_lso[index]){
                    power = powers_lso[index];                   
                }else{
                    break;
                }
            }
            _staked = _staked.add(power.mul(info._amount).mul(powerAmount_lso).div(10000));
        }
        return _staked;
    }

    function unstakeLSO() public nonReentrant{
        uint _staked = yieldedLSOAmount();        
        _lso.transfer(msg.sender, _staked);
        stakedCountPerAddress_lso[msg.sender] = 0;
        emit unstaked(msg.sender, _staked, 2);
    }
}
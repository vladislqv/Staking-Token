// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 public stakingRate;
    bool public stakingEnabled;

    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTS;

    constructor(address initialOwner)
        ERC20("MyToken", "MTK")
        Ownable(initialOwner)
    {
        _mint(initialOwner, 1000000 * (10 ** uint256(decimals())));
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0");
        require(balanceOf(msg.sender) >= amount, "Cannot stake more than you have");
        require(stakingRate > 0, "Staking rate not set");
        _transfer(msg.sender, address(this), amount);
        if(staked[msg.sender] > 0) {
            claim();
        }
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Cannot unstake 0");
        require(staked[msg.sender] >= amount, "Cannot unstake more than you have staked");
        claim();
        staked[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }

    function claim() public {
        require(staked[msg.sender] > 0, "Nothing to claim");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 ONE_YEAR = 3.154e7;
        uint256 rewards = (staked[msg.sender] * secondsStaked * stakingRate / 100) / ONE_YEAR;
        stakedFromTS[msg.sender] = block.timestamp;
        _mint(msg.sender, rewards);
    }

    function setStakingRate(uint256 newRate) external onlyOwner {
        stakingRate = newRate;
    }

    function switchStaking() external onlyOwner {
        stakingEnabled = !stakingEnabled;
    }
}
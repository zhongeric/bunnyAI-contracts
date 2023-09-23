// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BunnyAIController {
    address public owner;
    address public immutable token;
    address public immutable baseCurrency;
    uint256 public exchangeRate;

    event OwnershipTransferred(address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "BunnyAIController: not owner");
        _;
    }

    constructor(address _token, address _baseCurrency, uint256 _exchangeRate) {
        owner = msg.sender;
        token = _token;
        baseCurrency = _baseCurrency;
        // how many tokens are needed to redeem 1 baseCurrency
        exchangeRate = _exchangeRate;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(owner);
    }

    function redeem(uint256 amount) external {
        require(amount > 0, "BunnyAIController: amount is zero");
        uint256 balance = IERC20(token).balanceOf(msg.sender);
        require(balance >= amount, "BunnyAIController: insufficient balance");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 baseCurrencyAmount = amount / exchangeRate;
        IERC20(baseCurrency).transfer(msg.sender, baseCurrencyAmount);
    }

    function setExchangeRate(uint256 _exchangeRate) external onlyOwner {
        exchangeRate = _exchangeRate;
    }

    function sweep(address _token, uint256 amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, amount);
    }
}

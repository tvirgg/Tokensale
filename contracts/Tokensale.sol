// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tokensale is Ownable {
    event Purchase(
        address indexed buyer,
        address indexed token,
        uint256 amount
    );
    constructor() Ownable(msg.sender) {}

    function buy(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        IERC20 token = IERC20(tokenAddress);
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );
        emit Purchase(msg.sender, tokenAddress, amount);
    }

    function withdraw(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        require(token.transfer(owner(), balance), "Withdrawal failed");
    }
}

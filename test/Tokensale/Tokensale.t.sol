// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../contracts/Tokensale.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/StdCheats.sol";
contract MockERC20 is ERC20 {
    constructor() ERC20("USD Token", "USDT") {
        _mint(msg.sender, 10000000 * 10 ** 18);
    }
}

contract TokenVaultTest is Test {
    Tokensale tokensale;
    MockERC20 token;
    address payable nonOwner;

    function setUp() public {
        tokensale = new Tokensale();
        token = new MockERC20();
        token.approve(address(tokensale), type(uint256).max);
        nonOwner = payable(address(0x1));
    }

    function testFuzzingBuy(uint256 randomBalance, uint256 amountToBuy) public {
        address buyer = address(0x123);

        // Ensure that randomBalance is strictly greater than zero
        vm.assume(randomBalance > 0);

        // Set a random token balance for the buyer
        deal(address(token), buyer, randomBalance);

        // Ensure that amountToBuy is also strictly greater than zero and does not exceed randomBalance
        vm.assume(amountToBuy > 0 && amountToBuy <= randomBalance);

        // Prepare the environment: ensure that the tokens can be spent by the tokensale contract
        vm.startPrank(buyer);
        token.approve(address(tokensale), amountToBuy);

        // Execute the buy operation as the buyer
        tokensale.buy(address(token), amountToBuy);
        vm.stopPrank();

        // Verify that the tokens were transferred from the buyer to the Tokensale contract
        assertEq(
            token.balanceOf(buyer),
            randomBalance - amountToBuy,
            "Incorrect buyer token balance after buy"
        );
        assertEq(
            token.balanceOf(address(tokensale)),
            amountToBuy,
            "Tokensale contract did not receive the tokens"
        );
    }

    /// @notice Tests the invariant that only the owner can successfully call the withdraw function
    function testInvariantWithdrawNotOwner() public {
        // Attempt to call the withdraw function as a non-owner, which should fail
        vm.prank(nonOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        tokensale.withdraw(address(tokensale));
    }
}

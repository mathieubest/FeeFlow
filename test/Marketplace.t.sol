// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MarketplaceListing.sol";
import "../src/MarketplaceBuying.sol";

contract MarketplaceTest is Test {
    MarketplaceListing public listing;
    MarketplaceBuying public buying;
    address public owner;
    address public seller;
    address public buyer;

    function setUp() public {
        owner = address(this);
        seller = makeAddr("seller");
        buyer = makeAddr("buyer");
        
        // Deploy contracts
        listing = new MarketplaceListing();
        buying = new MarketplaceBuying(address(listing));
        
        // Give some ETH to seller and buyer
        vm.deal(seller, 100 ether);
        vm.deal(buyer, 100 ether);
    }

    // Mock price oracle function
    function getETHUSDPrice() external pure returns (uint256) {
        return 2000_00; // $2000.00 per ETH
    }

    function testListingAndBuying() public {
        // List an item
        vm.startPrank(seller);
        uint256 itemId = listing.listItem(
            "Test Item",
            1000_00,    // $1000.00
            1000        // 10% APY
        );
        vm.stopPrank();

        // Verify item was listed
        MarketplaceListing.Item memory item = listing.getItem(itemId);
        assertEq(item.name, "Test Item");
        assertEq(item.priceUSD, 1000_00);
        assertEq(item.lenderAPY, 1000);
        assertTrue(item.isActive);
    }

    function testFailInvalidCollateralAmount() public {
        // List an item
        vm.startPrank(seller);
        uint256 itemId = listing.listItem(
            "Test Item",
            1000_00,    // $1000.00
            1000        // 10% APY
        );
        vm.stopPrank();

            // Try to pay wrong collateral amount
            vm.startPrank(buyer);
            vm.expectRevert("Incorrect collateral amount");
            buying.payCollateral{value: 1 ether}(itemId, 12);
            vm.stopPrank();
        }

    function testSuccessfulCollateralPayment() public {
        // List an item
        vm.startPrank(seller);
        uint256 itemId = listing.listItem(
            "Test Item",
            1000_00,    // $1000.00
            1000        // 10% APY
        );
        vm.stopPrank();

        // Calculate the correct collateral
        uint256 correctCollateral = buying.calculateRequiredCollateral(itemId, 12);
        console.log("Required collateral:", correctCollateral);

        // Check buyer's balance before
        uint256 buyerBalanceBefore = address(buyer).balance;
        console.log("Buyer balance before:", buyerBalanceBefore);

        // Pay correct collateral amount
        vm.startPrank(buyer);
        buying.payCollateral{value: correctCollateral}(itemId, 12);
        vm.stopPrank();

        // Verify the payment was successful
        MarketplaceListing.Item memory item = listing.getItem(itemId);
        assertEq(item.buyer, buyer);
        assertEq(item.collateralPaid, correctCollateral);
        
        // Verify buyer's balance decreased by correct amount
        uint256 buyerBalanceAfter = address(buyer).balance;
        assertEq(buyerBalanceAfter, buyerBalanceBefore - correctCollateral);
    }
}

    
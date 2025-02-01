// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMarketplaceTypes.sol";
import "./MarketplaceListing.sol";

contract MarketplaceBuying is Ownable, IMarketplaceTypes {
    MarketplaceListing public listingContract;
    uint256 public constant PROTOCOL_FEE = 100; // 1% in basis points

    event CollateralPaid(
        uint256 indexed id,
        address indexed buyer,
        uint256 collateralAmount
    );

    constructor(address _listingContract) Ownable(msg.sender) {
        listingContract = MarketplaceListing(_listingContract);
    }

    function calculateRequiredCollateral(
        uint256 _itemId,
        uint256 _months
    ) public view returns (uint256) {
        Item memory item = listingContract.getItem(_itemId);
        require(item.isActive, "Item not active");
        require(_months > 0 && _months <= 60, "Invalid month range"); // Max 5 years

        // All calculations done with 2 decimal places (like priceUSD)
        
        // A = price of item
        uint256 A = item.priceUSD;
        
        // B = price of item multiplied by APY lender
        uint256 B = (A * item.lenderAPY) / 10000;
        
        // C = fees protocol (1% of item price)
        uint256 C = (A * PROTOCOL_FEE) / 10000;
        
        // D = APY lender
        uint256 D = item.lenderAPY;
        
        // E = number of months
        uint256 E = _months;
        
        // F = 12 (months in a year)
        uint256 F = 12;

        // Calculate: ((A + B) + C) / (D * (E / F))
        uint256 monthlyFactor = (E * 10000) / F;  // Multiply by 10000 for precision
        uint256 denominator = D * monthlyFactor;
        uint256 numerator = ((A + B) + C) * 10000; // Multiply by 10000 for precision
        
        uint256 collateralUSD = numerator / denominator;
        
        return listingContract.convertUSDtoETH(collateralUSD);
    }

    function payCollateral(uint256 _itemId, uint256 _months) external payable {
        require(_months > 0 && _months <= 60, "Invalid month range");
        
        Item memory item = listingContract.getItem(_itemId);
        require(item.isActive, "Item not active");
        require(item.buyer == address(0), "Item already has a buyer");
        
        uint256 requiredCollateral = calculateRequiredCollateral(_itemId, _months);
        require(msg.value == requiredCollateral, "Incorrect collateral amount");

        // Store collateral payment info
        // Note: We'll need to add storage for this in a real implementation
        
        emit CollateralPaid(_itemId, msg.sender, msg.value);
    }
}
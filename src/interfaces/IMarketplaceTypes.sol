// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IMarketplaceTypes {
    struct Item {
        uint256 id;
        string name;
        uint256 priceUSD;      // Price in USD (with 2 decimals)
        uint256 priceETH;      // Price in ETH (in wei)
        uint256 lenderAPY;     // APY in basis points (e.g., 500 = 5%)
        bool isActive;
        address payable seller;
        address buyer;
        uint256 collateralPaid;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is Ownable {
    struct Item {
        uint256 id;
        string name;
        uint256 priceUSD;  // Price in USD (with 2 decimals, e.g., 10000 = $100.00)
        uint256 priceETH;  // Price in ETH (in wei)
    }

    // Storage
    mapping(uint256 => Item) public items;
    uint256 private _itemIds;

    // Events
    event ItemListed(
        uint256 indexed id,
        string name,
        uint256 priceUSD,
        uint256 priceETH
    );

    constructor() Ownable(msg.sender) {}

    // For this example, we'll use a fixed ETH price of $2000
    function getETHPrice() public pure returns (uint256) {
        return 2000_00; // $2000.00
    }

    // Convert USD to ETH
    function convertUSDtoETH(uint256 _priceUSD) public pure returns (uint256) {
        uint256 ethPrice = getETHPrice();
        // Convert to wei with proper decimal handling
        return (_priceUSD * 1e18) / ethPrice;
    }

    // Only store owner can list items
    function listItem(
        string memory _name,
        uint256 _priceUSD    // Price in USD with 2 decimals (e.g., 10000 = $100.00)
    ) external onlyOwner returns (uint256) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_priceUSD > 0, "Price must be greater than 0");

        // Convert USD price to ETH
        uint256 priceETH = convertUSDtoETH(_priceUSD);

        // Increment item ID
        _itemIds++;

        // Create and store the item
        items[_itemIds] = Item({
            id: _itemIds,
            name: _name,
            priceUSD: _priceUSD,
            priceETH: priceETH
        });

        emit ItemListed(_itemIds, _name, _priceUSD, priceETH);
        return _itemIds;
    }

    // View functions
    function getItem(uint256 _id) external view returns (Item memory) {
        require(_id > 0 && _id <= _itemIds, "Item does not exist");
        return items[_id];
    }

    function getLatestItemId() external view returns (uint256) {
        return _itemIds;
    }
}
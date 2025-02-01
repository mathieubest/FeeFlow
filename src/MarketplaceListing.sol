// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMarketplaceTypes.sol";

contract MarketplaceListing is Ownable, IMarketplaceTypes {
    // Storage
    mapping(uint256 => Item) public items;
    uint256 private _itemIds;

    // Events
    event ItemListed(
        uint256 indexed id,
        string name,
        uint256 priceUSD,
        uint256 priceETH,
        uint256 lenderAPY
    );

    constructor() Ownable(msg.sender) {}

    function getETHPrice() public pure returns (uint256) {
        return 2000_00; // $2000.00
    }

    function convertUSDtoETH(uint256 _priceUSD) public pure returns (uint256) {
        uint256 ethPrice = getETHPrice();
        return (_priceUSD * 1e18) / ethPrice;
    }

    function listItem(
        string memory _name,
        uint256 _priceUSD,
        uint256 _lenderAPY
    ) external onlyOwner returns (uint256) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_priceUSD > 0, "Price must be greater than 0");
        require(_lenderAPY > 0 && _lenderAPY <= 5000, "APY must be between 0% and 50%");

        uint256 priceETH = convertUSDtoETH(_priceUSD);

        _itemIds++;
        items[_itemIds] = Item({
            id: _itemIds,
            name: _name,
            priceUSD: _priceUSD,
            priceETH: priceETH,
            lenderAPY: _lenderAPY,
            isActive: true,
            seller: payable(msg.sender),
            buyer: address(0),
            collateralPaid: 0
        });

        emit ItemListed(_itemIds, _name, _priceUSD, priceETH, _lenderAPY);
        return _itemIds;
    }

    function getItem(uint256 _id) external view returns (Item memory) {
        require(_id > 0 && _id <= _itemIds, "Item does not exist");
        return items[_id];
    }

    function getLatestItemId() external view returns (uint256) {
        return _itemIds;
    }
}
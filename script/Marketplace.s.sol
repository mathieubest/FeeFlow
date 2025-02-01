// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Marketplace.sol";

contract MarketplaceScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy contract
        Marketplace marketplace = new Marketplace();
        
        // List a test item ($100.00)
        marketplace.listItem("Test Item", 10000);
        
        vm.stopBroadcast();
        
        console.log("Marketplace deployed to:", address(marketplace));
    }
}
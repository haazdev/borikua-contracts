// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {HelloWorld} from "../contracts/HelloWorld.sol";

contract DeployScript is Script {
    function run() external {
        // Get the private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the contract
        HelloWorld helloWorld = new HelloWorld();
        
        // Log the deployed contract address
        console.log("HelloWorld deployed to:", address(helloWorld));
        console.log("Owner:", helloWorld.getOwner());
        console.log("Initial message:", helloWorld.getMessage());
        
        // Stop broadcasting
        vm.stopBroadcast();
    }
}
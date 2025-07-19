// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PRFlag} from "../contracts/PRFlag.sol";

contract DeployPRFlagScript is Script {
    function run() external {
        // Get the private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the contract
        PRFlag prFlag = new PRFlag();
        
        // Log the deployed contract address
        console.log("PRFlag deployed to:", address(prFlag));
        console.log("Creator:", prFlag.creator());
        console.log("Name:", prFlag.name());
        console.log("Symbol:", prFlag.symbol());
        console.log("Deployment Block:", prFlag.deploymentBlock());
        
        // Stop broadcasting
        vm.stopBroadcast();
    }
}
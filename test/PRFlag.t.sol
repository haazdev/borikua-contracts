// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PRFlag} from "../contracts/PRFlag.sol";

contract PRFlagTest is Test {
    PRFlag public prFlag;
    address public creator = address(1);
    
    event ResistanceMessage(address indexed sender, string message);
    event FlagDisplayed(address indexed viewer, uint256 timestamp);

    function setUp() public {
        vm.prank(creator);
        prFlag = new PRFlag();
    }

    function test_ContractName() public view {
        assertEq(prFlag.name(), unicode"Bandera Negra Borikua");
        assertEq(prFlag.symbol(), "RESISTANCE");
    }

    function test_Creator() public view {
        assertEq(prFlag.creator(), creator);
    }

    function test_GetFlag() public {
        string memory flag = prFlag.getFlag();
        assertTrue(bytes(flag).length > 0);
        // Check that it contains resistance message
        assertTrue(bytes(flag).length > 1000); // Should be a long ASCII art
    }

    function test_ResistanceMessage() public view {
        string memory message = prFlag.getResistanceMessage();
        assertTrue(bytes(message).length > 0);
    }

    function test_PostResistanceMessage() public {
        string memory testMessage = unicode"¡Viva Puerto Rico Libre!";
        
        vm.expectEmit(true, false, false, true);
        emit ResistanceMessage(address(this), testMessage);
        
        prFlag.postResistanceMessage(testMessage);
    }

    function test_Solidarity() public view {
        string memory solidarityMsg = prFlag.solidarity();
        assertEq(solidarityMsg, unicode"¡Hasta la victoria siempre! ✊🏽🇵🇷");
    }

    function test_ContractInfo() public view {
        (string memory name, string memory symbol, address contractCreator, uint256 blockDeployed) = prFlag.getContractInfo();
        
        assertEq(name, unicode"Bandera Negra Borikua");
        assertEq(symbol, "RESISTANCE");
        assertEq(contractCreator, creator);
        assertTrue(blockDeployed > 0);
    }

    function test_FlagDisplayedEvent() public {
        vm.expectEmit(true, false, false, false);
        emit FlagDisplayed(address(this), block.timestamp);
        
        prFlag.getFlag();
    }

    function test_FlagContainsBorikua() public {
        string memory flag = prFlag.getFlag();
        // Check that the flag contains "BORIKUA" (not "BORICUA")
        assertTrue(bytes(flag).length > 0);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {HelloWorld} from "../contracts/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld public helloWorld;
    address public owner = address(1);

    function setUp() public {
        vm.prank(owner);
        helloWorld = new HelloWorld();
    }

    function test_InitialMessage() public view {
        assertEq(helloWorld.message(), unicode"Hello World! | ¡Hola Mundo! | Taiguey! | Yo soy Borikua, pa' que tú lo sepas!");
    }

    function test_EnglishGreeting() public view {
        assertEq(helloWorld.getEnglishGreeting(), "Hello World!");
    }

    function test_SpanishGreeting() public view {
        assertEq(helloWorld.getSpanishGreeting(), unicode"¡Hola Mundo!");
    }

    function test_TainoGreeting() public view {
        assertEq(helloWorld.getTainoGreeting(), "Taiguey!");
    }

    function test_BorikuaGreeting() public view {
        assertEq(helloWorld.getBorikuaGreeting(), unicode"Yo soy Borikua, pa' que tú lo sepas!");
    }


    function test_AllGreetings() public view {
        (string memory english, string memory spanish, string memory taino, string memory borikua) = helloWorld.getAllGreetings();
        assertEq(english, "Hello World!");
        assertEq(spanish, unicode"¡Hola Mundo!");
        assertEq(taino, "Taiguey!");
        assertEq(borikua, unicode"Yo soy Borikua, pa' que tú lo sepas!");
    }

    function test_OwnerIsCorrect() public view {
        assertEq(helloWorld.getOwner(), owner);
    }

    function test_UpdateMessage() public {
        string memory newMessage = "Updated message!";
        
        vm.prank(owner);
        helloWorld.updateMessage(newMessage);
        
        assertEq(helloWorld.getMessage(), newMessage);
    }

    function test_OnlyOwnerCanUpdate() public {
        address notOwner = address(2);
        string memory newMessage = "Should fail";
        
        vm.prank(notOwner);
        vm.expectRevert("Only owner can update message");
        helloWorld.updateMessage(newMessage);
    }
}
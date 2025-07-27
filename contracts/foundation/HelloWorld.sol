// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HelloWorld {
    string public message;
    address public owner;
    
    event MessageUpdated(string newMessage, address updatedBy);
    
    constructor() {
        owner = msg.sender;
        message = unicode"Hello World! | ¡Hola Mundo! | Taiguey! | Yo soy Borikua, pa' que tú lo sepas!";
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    function getEnglishGreeting() public pure returns (string memory) {
        return "Hello World!";
    }
    
    function getSpanishGreeting() public pure returns (string memory) {
        return unicode"¡Hola Mundo!";
    }
    
    function getTainoGreeting() public pure returns (string memory) {
        return "Taiguey!";
    }
    
    function getBorikuaGreeting() public pure returns (string memory) {
        return unicode"Yo soy Borikua, pa' que tú lo sepas!";
    }
    
    
    function getAllGreetings() public pure returns (string memory english, string memory spanish, string memory taino, string memory borikua) {
        return ("Hello World!", unicode"¡Hola Mundo!", "Taiguey!", unicode"Yo soy Borikua, pa' que tú lo sepas!");
    }
    
    function updateMessage(string memory _newMessage) public {
        require(msg.sender == owner, "Only owner can update message");
        message = _newMessage;
        emit MessageUpdated(_newMessage, msg.sender);
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
}
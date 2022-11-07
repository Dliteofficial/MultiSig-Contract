/*
Smart-Contract created by Dliteofficial
Date Created: 12 July 2022
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract multiSig {

    address [] owners;

    address public initialOwner;
    mapping (address => bool) public isOwner;

// Constructor
// set the initial owner to the address that initiated the contract
// Automatically set the address as a validator/signature.
    constructor () {
        initialOwner = msg.sender;
        owners.push(initialOwner);
        isOwner[initialOwner] = true;
    }

// Events to emit information about deposits and withdrawals 
    event DepositInfo(address sender, uint _amount);
    event WithdrawalInfo(address _reciever, uint _amount);

// Modifiers
    modifier onlyOwner () {
        require (msg.sender == initialOwner, "ERR! You do not own this Smart Contract...");
        _;
    }

    modifier validSignature(address _owner) {
        require (isOwner[_owner], "YOU ARE NOT AUTHORIZED!!!");
        _;
    }

// This Function add signatories for transaction validation
// only the owner of the smart contract can add signatories
    function addSignatories (address _address) public onlyOwner{
        isOwner[_address] = true;
        owners.push (_address);
    }

// This function removes transaction validators
// Only the owner of the smart contract can remove a signatory
    function removeSignatories (address _address) public onlyOwner {
       for (uint i = 0; i < owners.length; i++) {
           if (owners[i] == _address){
               isOwner[_address] = false;
               owners[i] = owners[owners.length - 1];
               break;
           }
       }owners.pop();
    }

// This functions replaces a signatory with a new one
// Only the owner of the smart contract can do this
    function replaceSignatories(address oldAddress, address newAddress) public onlyOwner{
        for (uint i = 0; i < owners.length; i++){
            if (owners[i] == oldAddress){
                isOwner[oldAddress] = false;
                owners[i] = newAddress;
                isOwner[newAddress] = true;
            }
        }
    }

//This function returns the signatories of the smart contract
    function getSignatories () public view returns(address[] memory){
           return owners;
    }

// Function sends funds to the smart contract
    receive () external payable validSignature (msg.sender) {
        require (msg.value > 0 && msg.sender.balance >= msg.value);
        emit DepositInfo(msg.sender, msg.value);
    }

// Function withdraws funds from the smart contract
// Only a signatory can withdraw funds from the smart contract
    function withdrawFunds (address payable _to, uint _amount) public validSignature (msg.sender) {
        require(address(this).balance >= _amount);
        _to.transfer(_amount);
        emit WithdrawalInfo(_to, _amount);
    }

// Function returns wallet's Balance
    function getWalletBalance () public view returns (uint){
        return address(this).balance;
    }
}

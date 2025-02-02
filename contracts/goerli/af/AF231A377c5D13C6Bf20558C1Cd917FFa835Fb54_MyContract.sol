/**
 *Submitted for verification at Etherscan.io on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    string _name;
    uint _balance;

    // Function ที่ถูกรันครั้งแรกและครั้งเดียวเมื่อ Contract ถูกสร้าง
    constructor(string memory name, uint balance){
        _name = name;
        _balance = balance;
    }

    function getBalance() public view returns(uint balance){
        return _balance;
    }

    function deposit(uint amount) public{
        _balance = _balance + amount;
    }
}
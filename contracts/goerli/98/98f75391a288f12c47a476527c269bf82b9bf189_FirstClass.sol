/**
 *Submitted for verification at Etherscan.io on 2022-12-17
*/

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.12;

contract FirstClass {

    string count = "Thank you!";

    function my_function1() public view returns(string memory){
       return count;
    }

    function my_function_buy() public payable{
       count;
    }

}
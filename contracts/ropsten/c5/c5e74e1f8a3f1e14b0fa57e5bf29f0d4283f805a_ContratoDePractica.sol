/**
 *Submitted for verification at Etherscan.io on 2022-08-03
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.8.0; 

contract ContratoDePractica{
    string texto;  

    function escribir(string calldata _texto) public{ 
         texto = _texto;
    }  

    function Leer() public view returns (string memory) {
        return texto; 
    }
 }
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract HelloWorld {

  string public yourName ;

    constructor(){
        yourName = "Linhne" ;
    }

    function setName(string memory name) public {
        yourName = name;
    }
}

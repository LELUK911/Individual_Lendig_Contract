// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract mockWeth is ERC20 {
    constructor(uint256 initialSupply) ERC20("mockWeth", "Mweth") {
        _mint(msg.sender, initialSupply);
    }
}
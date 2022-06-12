pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(uint256 initialSupply) ERC20("CustomToken", "CMTN") {
        _mint(msg.sender, initialSupply);
    }
}

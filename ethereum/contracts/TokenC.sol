pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract TokenC is ERC20 {
    constructor(uint256 initialSupply) ERC20("C", "CT") {
        _mint(msg.sender, initialSupply);
    }
}

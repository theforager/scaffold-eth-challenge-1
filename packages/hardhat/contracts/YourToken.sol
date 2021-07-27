pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YourToken is ERC20("Forager Coins", "FORG") {
    
    constructor(uint256 amount) public {
        _mint(msg.sender, amount);
    }
    
}

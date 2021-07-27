pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() public payable {
    uint256 newTokenAmount = msg.value * tokensPerEth;
    emit BuyTokens(msg.sender, msg.value, newTokenAmount);

    yourToken.transfer(msg.sender, newTokenAmount);
  }

  function sellTokens(uint256 tokenAmount) public {
    address seller = msg.sender;
    uint256 ethToReturn = tokenAmount / tokensPerEth;

    emit SellTokens(seller, tokenAmount, ethToReturn);

    yourToken.transferFrom(seller, address(this), tokenAmount);

    (bool success, ) = seller.call{value: ethToReturn}("");
    require(success, 'Token sale not successful');
  }

  function withdraw() public onlyOwner {
    uint256 balance = yourToken.balanceOf(address(this));
    yourToken.transfer(this.owner(), balance);
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Withdraw failed");
  }
}

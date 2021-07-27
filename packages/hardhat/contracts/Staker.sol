pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  event Stake(address staker, uint256 amount);

  mapping(address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint deadline;

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = now + 30 seconds;
  }

  modifier onlyAfterDeadline() {
    require(timeLeft() == 0, "Staking deadline not passed");
    _;
  }

  modifier notCompleted() {
    bool isComplete = exampleExternalContract.completed();
    require(!isComplete, "External contract already executed");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable notCompleted {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);

    if (timeLeft() == 0 && address(this).balance >= threshold) {
      execute();
    }
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public onlyAfterDeadline notCompleted {
    uint256 bal = address(this).balance;

    require(bal >= threshold);

    exampleExternalContract.complete{value: bal}();
    console.log("Contract executed");
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw(address addy) public onlyAfterDeadline notCompleted {
    require(addy == msg.sender, "Requested withdraw address does not match sender");
    
    address user = msg.sender;
    uint256 bal = address(this).balance;

    require(bal < threshold, "Withdraw unavailable until executed");

    uint256 userBal = balances[user];
    balances[user] = 0; // Set new balance to zero

    (bool success, ) = user.call{value: userBal}("");
    require(success, "Withdraw failed to send Ether");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    return now >= deadline ? 0 : deadline - now;
  }
}
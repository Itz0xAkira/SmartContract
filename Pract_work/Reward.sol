// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract DeltaWovlesReward is ERC20, ERC20Burnable, Ownable {

  mapping(address => bool) controllers;

  bool public IsBuyingAllowed = false;
  uint256 public DW_Price = 0.1 ether;
  uint256 public AmountPerTx = 100;
  
  constructor() ERC20("DeltaWovlesReward", "DW") { }

  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    _mint(to, amount);
  }

  function burnFrom(address account, uint256 amount) public override {
      if (controllers[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

  function buyDW(uint256 amount) external payable{
    require(IsBuyingAllowed, "Buying is not available");
    require(msg.value >= DW_Price, "Insufficient payment");
    _mint(msg.sender, amount);
  }

  function toggleSale() external onlyOwner {
    IsBuyingAllowed = !IsBuyingAllowed;
  }

  function setAmount(uint256 _amount) external onlyOwner {
    AmountPerTx = _amount;
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }
}
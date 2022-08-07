// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DST is ERC20 {
  constructor() ERC20("DonkeySwapToken", "DST") {
  }

  function mint(address account, uint256 amount) public {
    _mint(account, amount);
  }

  function decimals() public pure override returns (uint8) {
    return 9;
  }
}
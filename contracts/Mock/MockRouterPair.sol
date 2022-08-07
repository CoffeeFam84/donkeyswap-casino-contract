// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockRouterPair {
  constructor() {
  }
  
  function getReserves() external pure returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
    return (0, 0, 0);
  }

  function getAmountOut(uint amountIn, uint, uint) external pure returns (uint) {
    return amountIn;
  }
}
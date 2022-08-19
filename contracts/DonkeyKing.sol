// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

interface IERC20 {
  function transferFrom(address, address, uint256) external returns (bool);
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract DonkeyKingTrade is Ownable {

  using ECDSA for bytes32;
  using Strings for uint256;

    IERC20 public dst = IERC20(0x3969Fe107bAe2537cb58047159a83C33dfbD73f9);
    address payable public casinoWallet = payable(0x9E3f95e648E15B0E5B85Dc6481f0B336c3D68832);
    address payable public devWallet1 = payable(0x6b96AEdb09cA958f5e9409baf09190131525b27b);
    address payable public devWallet2 = payable(0xBD861551F6C6D5f6472A843c325E50b6bb849dce);
    IUniswapV2Pair public uniswapV2Pair = IUniswapV2Pair(0x7123431162c1efF257578D1574014e5305Eb7bd4);
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0xe779e189a865e880CCCeBC75bC353E38DE487030);

    uint256 public feeRate = 30;
    bool _takeFee = true;
    mapping(address => bool) public blockTransaction;
    mapping(address => bool) public _isExcludedFromFee;

    mapping(uint256 => bool) private nonces;

    event BUYCHIPS(address buyer, uint256 amount);
    event SELLCHIPS(address seller, uint256 amount);

    constructor() {
    }

    function buyChips(uint amount) public payable {
      require(blockTransaction[msg.sender] == false, "Transaction blocked");
      uint256 dstAmount = amount * 10 ** 9;
      dst.transferFrom(msg.sender, casinoWallet, dstAmount);

      //calculate transaction fee
      bool takeFee = _takeFee;

      if (_isExcludedFromFee[msg.sender] == true) {
        takeFee = false;
      }

      if (takeFee) {
        takeTransactionFee(dstAmount);
      }

      emit BUYCHIPS(msg.sender, amount);
    }

    function sellChips(uint amount, uint nonce, bytes memory signature) public payable {
      require(_verify(amount, nonce, signature) == true, "Input not verified");

      require(blockTransaction[msg.sender] == false, "Transaction blocked");
      uint256 dstAmount = amount * 10 ** 9;
      dst.transferFrom(casinoWallet, msg.sender, dstAmount);

      //calculate transaction fee
      bool takeFee = _takeFee;

      if (_isExcludedFromFee[msg.sender] == true) {
        takeFee = false;
      }

      if (takeFee) {
        takeTransactionFee(dstAmount);
      }

      emit SELLCHIPS(msg.sender, amount);
    }

    function excludeFromFee(address account) public onlyOwner {
      _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
      _isExcludedFromFee[account] = false;
    }

    function setTransactionFee(uint fee) public onlyOwner {
      feeRate = fee;
    }

    function enableTxFee() public onlyOwner {
      _takeFee = true;
    }

    function disableTxFee() public onlyOwner {
      _takeFee = false;
    }

    function blockWallet(address account) public onlyOwner {
      blockTransaction[account] = true;
    }
    
    function unblockWallet(address account) public onlyOwner {
      blockTransaction[account] = false;
    }

    function setUniswapPair(address account) public onlyOwner {
      uniswapV2Pair = IUniswapV2Pair(account);
    }

    function setUniswapRouter(address account) public onlyOwner {
      uniswapV2Router = IUniswapV2Router02(account);
    }

    function setDSTAddress(address _dst) public onlyOwner {
      dst = IERC20(_dst);
    }

    function setCasinoWallet(address account) public onlyOwner {
      casinoWallet = payable(account);
    }

    function setDev1Wallet(address account) public onlyOwner {
      devWallet1 = payable(account);
    }

    function setDev2Wallet(address account) public onlyOwner {
      devWallet2 = payable(account);
    }

    function takeTransactionFee(uint256 dstAmount) internal {
      uint feeAmount = getTransactionFee(dstAmount);
      require(msg.value >= feeAmount, "Insufficient Tx Fee");
      uint256 casinoFee = feeAmount * 60 / 100;
      uint256 devFee = feeAmount * 20 / 100;
      (bool success, ) = casinoWallet.call{value:casinoFee}("");
      require(success, "Transfer failed.");
      (success, ) = devWallet1.call{value: devFee}("");
      require(success, "Transfer failed.");
      (success, ) = devWallet2.call{value: address(this).balance}("");
      require(success, "Transfer failed.");
    }

    function txFeeEnabled() public view returns (bool) {
      return _takeFee;
    }

    function getTransactionFee(uint256 dstAmount) public view returns (uint) {
      (uint112 reserve0, uint112 reserve1,) = uniswapV2Pair.getReserves();
      uint bnbAmount = uniswapV2Router.getAmountOut(dstAmount, reserve0, reserve1);
      uint feeAmount = bnbAmount * feeRate / 1000;
      return feeAmount;
    }

    function _verify(uint256 amount, uint256 nonce, bytes memory signature) public returns (bool) {
      require(nonces[nonce] == false, "Invalid nonce");
      nonces[nonce] = true;
      string memory messageHash = string(abi.encodePacked(amount.toString(), nonce.toString()));
      bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", (bytes(messageHash).length).toString(), messageHash));
      return digest.recover(signature) == casinoWallet;
    }
}
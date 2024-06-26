// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IERC20.sol';


contract SushiCalculator {
    constructor() {}

    function getPairInfo(
        address pair
    ) public view returns (
        uint256 reserveA,
        uint256 reserveB,
        uint256 decimalsA,
        uint256 decimalsB,
        string memory symbolA,
        string memory symbolB
    ) {
        require(pair != address(0), "The pair doesn't exist");

        address tokenA = IUniswapV2Pair(pair).token0();
        address tokenB = IUniswapV2Pair(pair).token1();
        decimalsA = IERC20(tokenA).decimals();
        decimalsB = IERC20(tokenB).decimals();
        symbolA = IERC20(tokenA).symbol();
        symbolB = IERC20(tokenB).symbol();

        (reserveA, reserveB, ) = IUniswapV2Pair(pair).getReserves();
    }
}

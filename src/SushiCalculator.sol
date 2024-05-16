// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IERC20.sol';

contract SushiCalculator {
    // states for sushiswap factory and router
    IUniswapV2Factory public sushiFactory;
    IUniswapV2Router02 public sushiRouter;

    // denominator
    uint256 public denominator = 100_000_000_000;

    constructor(address _factory, address _router) {    
        sushiFactory = IUniswapV2Factory(_factory);
        sushiRouter = IUniswapV2Router02(_router);
    }

    function getPair(address tokenA, address tokenB) public view returns (address pair) {
        require(address(sushiFactory) != address(0), "Should define the address of sushiswap factory cotract");

        pair = sushiFactory.getPair(tokenA, tokenB);
    }

    function getPriceFromPoolTokens(address tokenA, address tokenB) public view returns (uint256 tokenAInTokenB, uint256 tokenBInTokenA) {
        // get the decimals of both tokens
        uint256 decimalsA = IERC20(tokenA).decimals();
        uint256 decimalsB = IERC20(tokenB).decimals();

        // get the address of pair pool
        address pair = getPair(tokenA, tokenB);
        require(pair != address(0), "There is no pool for such tokens in sushiswapv2");

        // get the amount of reserves for both of tokens
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        (uint256 reserveA, uint256 reserveB) = tokenA < tokenB ? (reserve0, reserve1) : (reserve1, reserve0);

        tokenAInTokenB = reserveB * (10 ** decimalsA) * denominator / (reserveA * (10 ** decimalsB));
        tokenBInTokenA = reserveA * (10 ** decimalsB) * denominator / (reserveB * (10 ** decimalsA));
    }

    function getAvaliableTokenAmountFromPriceRange() public {

    }
}

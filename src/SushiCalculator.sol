// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IERC20.sol';

import './library/IntegralMath.sol';

contract SushiCalculator {
    using IntegralMath for uint256;

    // states for sushiswap factory and router
    IUniswapV2Factory public sushiFactory;
    IUniswapV2Router02 public sushiRouter;

    // denominator
    uint256 public denominator = 100_000_000_000_000;

    constructor(address _factory, address _router) {    
        sushiFactory = IUniswapV2Factory(_factory);
        sushiRouter = IUniswapV2Router02(_router);
    }

    function getPair(address tokenA, address tokenB) public view returns (address pair) {
        require(address(sushiFactory) != address(0), "Should define the address of sushiswap factory cotract");

        pair = sushiFactory.getPair(tokenA, tokenB);
    }

    function getPriceFromPoolTokens(
        address pair
    ) public view returns (
        uint256 tokenAInTokenB,
        uint256 tokenBInTokenA,
        string memory symbolA,
        string memory symbolB
    ) {
        // get the address of pair pool
        require(pair != address(0), "The pool of such tokens doesn't exist");

        address tokenA = IUniswapV2Pair(pair).token0();
        address tokenB = IUniswapV2Pair(pair).token1();

        // get the decimals of both tokens
        uint256 decimalsA = IERC20(tokenA).decimals();
        uint256 decimalsB = IERC20(tokenB).decimals();
        symbolA = IERC20(tokenA).symbol();
        symbolB = IERC20(tokenB).symbol();

        // get the amount of reserves for both of tokens
        (uint256 reserveA, uint256 reserveB, ) = IUniswapV2Pair(pair).getReserves();

        tokenAInTokenB = reserveB * (10 ** decimalsA) / (reserveA * (10 ** decimalsB)) * denominator;
        tokenBInTokenA = reserveA * (10 ** decimalsB) / (reserveB * (10 ** decimalsA)) * denominator;
    }

    function getAvaliableTokenAmountFromPriceRange(
        address pair,
        uint256 tokenOrder,
        uint256 priceFrom,
        uint256 priceTo
    ) public view returns (uint256 reserve, uint256 fromReserve, uint256 toReserve, uint256 decimals, string memory symbolA, string memory symbolB) {
        // revert if pair address is invalid
        require(pair != address(0), "The pair of such tokens doesn't exist");

        address tokenA = IUniswapV2Pair(pair).token0();
        address tokenB = IUniswapV2Pair(pair).token1();

        // verify input argument
        require(priceFrom < priceTo, "Invalid price interval");
        // verify input price range
        require(priceFrom != 0 && priceTo != 0, "Price range cannot include zero value");

        // get the decimals of both tokens
        uint256 decimalsA = IERC20(tokenA).decimals();
        uint256 decimalsB = IERC20(tokenB).decimals();
        symbolA = IERC20(tokenA).symbol();
        symbolB = IERC20(tokenB).symbol();

        // get the amount of reserves for both of tokens
        (fromReserve, toReserve, ) = IUniswapV2Pair(pair).getReserves();
        uint256 K = fromReserve * toReserve;

        if (tokenOrder == 0) {
            reserve = fromReserve;
            decimals = decimalsA;
        } else {
            reserve = toReserve;
            decimals = decimalsB;
            decimalsB = decimalsA;
            decimalsA = decimals;
        }

        fromReserve = K * denominator / priceFrom * (10 ** decimalsA) / (10 ** decimalsB);
        fromReserve = fromReserve.floorSqrt();

        toReserve = K * denominator / priceTo * (10 ** decimalsA) / (10 ** decimalsB);
        toReserve = toReserve.floorSqrt();
    }
}

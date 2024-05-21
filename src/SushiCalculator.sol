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
    uint256 public denominator = 100_000_000_000;

    constructor(address _factory, address _router) {    
        sushiFactory = IUniswapV2Factory(_factory);
        sushiRouter = IUniswapV2Router02(_router);
    }

    function getPair(address tokenA, address tokenB) public view returns (address pair) {
        require(address(sushiFactory) != address(0), "Should define the address of sushiswap factory cotract");

        pair = sushiFactory.getPair(tokenA, tokenB);
    }

    function getPriceFromPoolTokens(
        address tokenA,
        address tokenB
    ) public view returns (
        uint256 tokenAInTokenB,
        uint256 tokenBInTokenA,
        string memory symbolA,
        string memory symbolB
    ) {
        // get the decimals of both tokens
        uint256 decimalsA = IERC20(tokenA).decimals();
        uint256 decimalsB = IERC20(tokenB).decimals();
        symbolA = IERC20(tokenA).symbol();
        symbolB = IERC20(tokenB).symbol();

        // get the address of pair pool
        address pair = getPair(tokenA, tokenB);
        require(pair != address(0), "The pool of such tokens doesn't exist");

        // get the amount of reserves for both of tokens
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        (uint256 reserveA, uint256 reserveB) = tokenA < tokenB ? (reserve0, reserve1) : (reserve1, reserve0);

        tokenAInTokenB = reserveB * (10 ** decimalsA) * denominator / (reserveA * (10 ** decimalsB));
        tokenBInTokenA = reserveA * (10 ** decimalsB) * denominator / (reserveB * (10 ** decimalsA));
    }

    function getAvaliableTokenAmountFromPriceRange(
        address tokenA,
        address tokenB,
        uint256 priceFrom,
        uint256 priceTo
    ) public view returns (uint256 reserveA, uint256 fromReserve, uint256 toReserve, uint256 decimalsA, string memory symbolA, string memory symbolB) {
        // verify input token address
        require(tokenA != address(0), "Invalid tokenA address");
        require(tokenB != address(0), "Invalid tokenB address");
        // verify input argument
        require(priceFrom < priceTo, "Invalid price interval");
        // verify input price range
        require(priceFrom != 0 && priceTo != 0, "Price range cannot include zero value");

        // get the decimals of both tokens
        decimalsA = IERC20(tokenA).decimals();
        uint256 decimalsB = IERC20(tokenB).decimals();
        symbolA = IERC20(tokenA).symbol();
        symbolB = IERC20(tokenB).symbol();

        // get the address of pair pool
        address pair = getPair(tokenA, tokenB);
        require(pair != address(0), "The pool of such tokens doesn't exist");

        // get the amount of reserves for both of tokens
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        (reserveA, ) = tokenA < tokenB ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 k = reserve0 * reserve1;

        fromReserve = k * (10 ** decimalsA) * denominator / ((10 ** decimalsB) * priceFrom);
        fromReserve = fromReserve.floorSqrt();

        toReserve = k * (10 ** decimalsA) * denominator / ((10 ** decimalsB) * priceTo);
        toReserve = toReserve.floorSqrt();
    }
}

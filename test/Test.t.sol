// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SushiCalculator} from "../src/SushiCalculator.sol";

contract BaseTest is Test {
    uint256 mainnetFork;
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    SushiCalculator public calculator;

    function setUp() public {
        mainnetFork = vm.createSelectFork("mainnet");

        address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        address router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

        calculator = new SushiCalculator(factory, router);
    }

    function test_getPairAddress() public view {
        address pair = calculator.getPair(USDC, WETH);

        console.log(pair);
    }

    function test_getPriceFromPoolTokens() public view {
        (uint256 wethPerUSDC, uint256 usdcPerWETH, ,) = calculator.getPriceFromPoolTokens(WETH, USDC);
        console.log(wethPerUSDC);
        console.log(usdcPerWETH);
    }

    function test_getAvaliableTokenAmountFromPriceRange() public view {
        (
            uint256 reserveA,
            uint256 reserveFrom,
            uint256 reserveTo,
            uint256 decimals,
            ,
        ) = calculator.getAvaliableTokenAmountFromPriceRange(WETH, USDC, 3000 * 10 ** 11, 3300 * 10 ** 11);

        console.log(reserveA);
        console.log(reserveFrom);
        console.log(reserveTo);
        console.log(decimals);
    }
}

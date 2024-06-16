// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SushiBuyer} from "../src/SushiBuyer.sol";
import "../src/interfaces/IERC20.sol";
import "../src/interfaces/ISwapRouter.sol";

contract MainTest is Test {
    uint256 public mainnetFork;

    SushiBuyer public buyer;

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address public alice = makeAddr('Alice');

    function setUp() public {
        mainnetFork = vm.createSelectFork('mainnet');

        buyer = new SushiBuyer();
    }

    function test_v3swap() public {
        deal(WETH, alice, 5 ether);

        vm.startPrank(alice);
        IERC20(WETH).approve(address(buyer), 5 ether);

        ISwapRouter.ExactOutputSingleParams memory param = ISwapRouter.ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: USDT,
            fee: 500,
            recipient: alice,
            deadline: 0,
            amountOut: 2000000,
            amountInMaximum: 600508872915740,
            sqrtPriceLimitX96: 0
        });

        buyer.exactOutputSingle(param);
        vm.stopPrank();
        console.log(IERC20(WETH).balanceOf(alice));
        console.log(IERC20(USDT).balanceOf(alice));
    }

    function test_v2swap() public {
        deal(WETH, alice, 5 ether);

        vm.startPrank(alice);
        IERC20(WETH).approve(address(buyer), 5 ether);
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = USDT;

        buyer.swapTokensForExactTokens(
            2000000,
            600508872915740,
            path,
            alice,
            0
        );
        vm.stopPrank();

        console.log(IERC20(WETH).balanceOf(alice));
        console.log(IERC20(USDT).balanceOf(alice));
    }
}

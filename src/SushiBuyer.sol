// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./Ownable.sol";

import "./interfaces/ISwapRouter.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPool.sol";

contract SushiBuyer is Ownable {
    address public V3_ROUTER = 0x2E6cd2d30aa43f40aa81619ff4b6E0a41479B13F;
    address public V2_ROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    ISwapRouter internal routerV3;
    IUniswapV2Router02 internal routerV2;

    constructor() Ownable(msg.sender) {
        routerV3 = ISwapRouter(V3_ROUTER);
        routerV2 = IUniswapV2Router02(V2_ROUTER);
    }

    function approveForRouter(address token, uint256 amount, address router) public {
        IERC20 tokenErc = IERC20(token);
        tokenErc.approve(router, amount);
    }

    function resetAllowance(address token, address router) public {
        IERC20 tokenErc = IERC20(token);
        tokenErc.approve(router, 0);
    }

    function readPool(address poolAddress)
        public
        view
        returns (
            uint256 sqrtPriceX96,
            uint256 liquidity,
            int24 tickSpacing
        )
    {
        IPool pool = IPool(poolAddress);
        IPool.Slot0 memory slot0 = pool.slot0();

        sqrtPriceX96 = slot0.sqrtPriceX96;
        liquidity = pool.liquidity();
        tickSpacing = pool.tickSpacing();
    }

    function exactOutputSingle(
        ISwapRouter.ExactOutputSingleParams memory params
    )
        public
        returns (
            uint256 amountIn
        )
    {
        IERC20(params.tokenIn).transferFrom(
            msg.sender,
            address(this),
            params.amountInMaximum
        );

        approveForRouter(params.tokenIn, params.amountInMaximum, V3_ROUTER);
        if (params.deadline == 0) {
            params.deadline = block.timestamp;
        }
        amountIn = routerV3.exactOutputSingle(params);

        if (amountIn < params.amountInMaximum) {
            IERC20(params.tokenIn).transfer(
                msg.sender,
                params.amountInMaximum - amountIn
            );
        }

        resetAllowance(params.tokenIn, V3_ROUTER);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns(
        uint256 amountIn
    ) {
        address tokenIn = path[0];

        IERC20(tokenIn).transferFrom(
            msg.sender,
            address(this),
            amountInMax
        );

        approveForRouter(tokenIn, amountInMax, V2_ROUTER);
        if (deadline == 0) {
            deadline = block.timestamp;
        }
        amountIn = routerV2.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline)[0];

        if (amountIn < amountInMax) {
            IERC20(tokenIn).transfer(
                msg.sender,
                amountInMax - amountIn
            );
        }

        resetAllowance(tokenIn, V2_ROUTER);
    }

    function setRouterV3(address _router) external onlyOwner {
        require(_router != address(0), "Invalid zero address");

        V3_ROUTER = _router;
        routerV3 = ISwapRouter(V3_ROUTER);
    }
    
    function setRouterV2(address _router) external onlyOwner {
        require(_router != address(0), "Invalid zero address");

        V2_ROUTER = _router;
        routerV2 = IUniswapV2Router02(V2_ROUTER);
    }
}
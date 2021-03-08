pragma solidity ^0.6.0;

import '../distribution/FUSDUSDTPool.sol';
import '../distribution/FUSDBAGSPool.sol';
import '../distribution/FUSDHBTCPool.sol';
import '../distribution/FUSDHTPool.sol';
import '../distribution/FUSDHUSDPool.sol';
import '../distribution/FUSDXFINPool.sol';
import '../interfaces/IDistributor.sol';

contract InitialCashDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IERC20 public cash;
    IRewardDistributionRecipient[] public pools;
    uint256 public totalInitialBalance;

    constructor(
        IERC20 _cash,
        IRewardDistributionRecipient[] memory _pools,
        uint256 _totalInitialBalance
    ) public {
        require(_pools.length != 0, 'a list of BAC pools are required');

        cash = _cash;
        pools = _pools;
        totalInitialBalance = _totalInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialCashDistributor: you cannot run this function twice'
        );

        for (uint256 i = 0; i < pools.length; i++) {
            uint256 amount;
            if (i == 0) {
                amount = totalInitialBalance.mul(30).div(100);
            } else {
                if (i != pools.length - 1) {
                    amount = totalInitialBalance.mul(14).div(100);
                } else {
                    uint256 amount1 = totalInitialBalance.mul(30).div(100);
                    uint256 amount2 = totalInitialBalance.mul(56).div(100);
                    amount = totalInitialBalance.sub(amount1).sub(amount2);
                }
            }

            cash.transfer(address(pools[i]), amount);
            pools[i].notifyRewardAmount(amount);

            emit Distributed(address(pools[i]), amount);
        }

        once = false;
    }
}

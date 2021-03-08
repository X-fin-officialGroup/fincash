pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../interfaces/IDistributor.sol';
import '../interfaces/IRewardDistributionRecipient.sol';

contract InitialShareDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IERC20 public fcs;
    IRewardDistributionRecipient public husdFcsLPPool;
    uint256 public husdFcsInitialBalance;
    IRewardDistributionRecipient public husdFusdLPPool;
    uint256 public husdFusdInitialBalance;

    constructor(
        IERC20 _fcs,
        IRewardDistributionRecipient _husdFcsLPPool,
        uint256 _husdFcsInitialBalance,
        IRewardDistributionRecipient _husdFusdLPPool,
        uint256 _husdFusdInitialBalance
    ) public {
        fcs = _fcs;
        husdFcsLPPool = _husdFcsLPPool;
        husdFcsInitialBalance = _husdFcsInitialBalance;
        husdFusdLPPool = _husdFusdLPPool;
        husdFusdInitialBalance = _husdFusdInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialShareDistributor: you cannot run this function twice'
        );

        fcs.transfer(address(husdFcsLPPool), husdFcsInitialBalance);
        husdFcsLPPool.notifyRewardAmount(husdFcsInitialBalance);
        emit Distributed(address(husdFcsLPPool), husdFcsInitialBalance);

        fcs.transfer(address(husdFusdLPPool), husdFusdInitialBalance);
        husdFusdLPPool.notifyRewardAmount(husdFusdInitialBalance);
        emit Distributed(address(husdFusdLPPool), husdFusdInitialBalance);

        once = false;
    }
}

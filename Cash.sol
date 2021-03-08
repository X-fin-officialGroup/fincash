pragma solidity ^0.6.0;

import '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';
import './owner/Operator.sol';

contract Cash is ERC20Burnable, Operator {

    address public feeAddress;
    // threshold of service charge
    uint256 public thresholdPrice = 9 * 10 ** 17;
    uint256 public initialPrice = 10 ** 18;
    uint256 public price = initialPrice;
    uint256 public rate = 20;
    mapping (address => bool) public isBlackListed;

    /**
     * @notice Constructs the Basis Cash ERC-20 contract.
     */
    constructor() public ERC20('FUSD', 'FUSD') {
        // Mints 1 Basis Cash to contract creator for initial Uniswap oracle deployment.
        // Will be burned after oracle deployment
        _mint(msg.sender, 1 * 10 ** 18);
    }

    function setFeeAddress(address _address) public onlyOperator returns (bool) {
        feeAddress = _address;
        return true;
    }

    function setThresholdPrice(uint256 _price) public onlyOperator returns (bool) {
        thresholdPrice = _price;
        return true;
    }

    function setPrice(uint256 _price) public onlyOperator returns (bool) {
        price = _price;
        return true;
    }

    function setRate(uint256 _rate) public onlyOperator returns (bool) {
        rate = _rate;
        return true;
    }

    function addBlackList(address _user) public onlyOperator {
        isBlackListed[_user] = true;
    }

    function removeBlackList(address _user) public onlyOperator {
        isBlackListed[_user] = false;
    }

    //    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    //        super._beforeTokenTransfer(from, to, amount);
    //        require(
    //            to != operator(),
    //            "basis.cash: operator as a recipient is not allowed"
    //        );
    //    }

    /**
     * @notice Operator mints basis cash to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of basis cash to mint to
     * @return whether the process has been done
     */
    function mint(address recipient_, uint256 amount_)
    public
    onlyOperator
    returns (bool)
    {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);

        return balanceAfter > balanceBefore;
    }

    function burn(uint256 amount) public override onlyOperator {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyOperator {
        super.burnFrom(account, amount);
    }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (price < thresholdPrice && isBlackListed[recipient]) {

            (uint256 feeAmount) = feeCalculate(amount);
            require(balanceOf(sender) >= feeAmount.add(amount), "ERC20: transfer amount and fee exceeds balance");

            _transfer(sender, recipient, amount);
            uint256 allowanceAmount = allowance(sender, _msgSender()).sub(amount, "ERC20: transfer amount exceeds allowance");
            _approve(sender, _msgSender(), allowanceAmount);

            _transfer(sender, feeAddress, feeAmount);

        } else {
            super.transferFrom(sender, recipient, amount);
        }

        return true;
    }

    function feeCalculate(uint256 amount) private view returns (uint256 feeAmount) {
        feeAmount = amount.div(10 ** 3).mul(rate);
    }
}

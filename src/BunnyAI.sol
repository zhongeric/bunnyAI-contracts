// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";

abstract contract FeeOnTransfer {
    // Fees in bps
    uint256 public fee;
    address public feeRecipient;
    mapping(address => bool) public exemptFromFee;

    event FeeChanged(uint256 fee);
    event FeeRecipientChanged(address feeRecipient);
    event FeeExemptionAdded(address exempt);
}

contract BunnyAI is ERC20, FeeOnTransfer {
    address public owner;
    uint256 public constant BPS = 10_000;
    uint256 public constant MAX_FEE = 1_000; // 10%

    event OwnershipTransferred(address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "BunnyAI: not owner");
        _;
    }

    constructor(uint256 initialSupply) ERC20("BunnyAI", "HONK", 18) {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
        exemptFromFee[msg.sender] = true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (fee > 0 && !exemptFromFee[msg.sender]) {
            require(feeRecipient != address(0), "BunnyAI: zero fee recipient");
            uint256 feeCalc = amount * fee / BPS;
            super.transfer(feeRecipient, feeCalc);
            amount -= feeCalc;
        }
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (fee > 0 && !exemptFromFee[sender]) {
            require(feeRecipient != address(0), "BunnyAI: zero fee recipient");
            uint256 feeCalc = amount * fee / BPS;
            super.transferFrom(sender, feeRecipient, feeCalc);
            amount -= feeCalc;
        }
        return super.transferFrom(sender, recipient, amount);
    }

    function setFee(uint256 _fee) external onlyOwner {
        require(_fee < MAX_FEE, "BunnyAI: fee too high");
        fee = _fee;
        emit FeeChanged(fee);
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
        emit FeeRecipientChanged(feeRecipient);
    }

    function addFeeExemption(address _exempt) external onlyOwner {
        exemptFromFee[_exempt] = true;
        emit FeeExemptionAdded(_exempt);
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOwner {
        _burn(_from, _amount);
    }

    function transferOwnership(address _owner) external onlyOwner {
        owner = _owner;
        emit OwnershipTransferred(owner);
    }
}

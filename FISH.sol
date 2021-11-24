// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;
import "./ERC20.sol";
import "./Minter.sol";

interface ApproveAndCallFallBack {
    function receiveApproval(address sender, uint256 amount, address token, bytes calldata extraData) external returns(bool);
}

contract FISH is ERC20("Chubby Cat FISH Token","FISH"), Minter {
    
    function mint(address account, uint256 amount) external onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
    
    function approveAndCall(address spender, uint256 amount, bytes calldata extraData) external returns (bool) {
        _approve(msg.sender, spender, amount);
        if(!ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData)){
            revert("ERC20: approveAndCall execution failed");
        }
        return true;
    }
}
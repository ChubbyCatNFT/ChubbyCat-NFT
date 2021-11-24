// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IMinter {
    function canCall(address src, address dst, bytes4 sig) external view returns (bool);
}

contract Minter is Ownable {
    address private _minter;
    
    function minterOf() external view onlyOwner returns (address) {
        return _minter;
    }
    
    function setMinter(address minter) external onlyOwner {
        require(address(0) != minter, "Minter: new minter is the zero address");
        _minter = minter;
    }
    
    function isMinter(address src, bytes4 sig) internal view returns (bool) {
        if (src == owner()) {
            return true;
        } else if (_minter == address(0)) {
            return false;
        }else {
            return IMinter(_minter).canCall(src, address(this), sig);
        }
    }
    
    modifier onlyMinter {
        require(isMinter(msg.sender, msg.sig));
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;
import "./ERC721.sol";
import "./Minter.sol";

interface ApproveAndCallFallBack {
    function receiveApproval(address sender, uint256 tokenId, address token, bytes calldata extraData) external returns(bool);
}

contract ERC721Token is ERC721, Minter {
    using Strings for uint256;
    string private _baseTokenURI;
    
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    
    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_exists(tokenId), "ERC721: ERC721Metadata URI query for nonexistent token");
        string memory uri = tokenId.toString();
        return bytes(_baseTokenURI).length > 0 ? string(abi.encodePacked(_baseTokenURI,uri)) : uri;
    }
    
    function setBaseURI(string memory newBaseTokenURI) external onlyMinter returns (bool){
        _baseTokenURI = newBaseTokenURI;
        return true;
    }
    
    function mint(address to, uint256 tokenId) external onlyMinter returns (bool) {
        _mint(to,tokenId);
        return true;
    }
    
    function burn(uint256 tokenId) external onlyMinter returns (bool) {
        _burn(tokenId);
        return true;
    }
    
    function approveAndCall(address to, uint256 tokenId, bytes calldata extraData) external returns (bool) {
        approve(to,tokenId);
        if(!ApproveAndCallFallBack(to).receiveApproval(msg.sender, tokenId, address(this), extraData)){
            revert("ERC721: approveAndCall execution failed");
        }
        return true;
    }
}
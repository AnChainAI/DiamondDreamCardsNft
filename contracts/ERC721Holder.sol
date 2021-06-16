pragma solidity ^0.5.0;

import "./standards/IERC721Receiver.sol";

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

pragma solidity ^0.5.0;

import "./NftCardsERC721Full.sol";
import "./NftCardsMinting.sol";
import "./standards/IERC721Metadata.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 */
contract NftCardsERC721Full is NftCardsMinting, IERC721Metadata {
  bytes private __uriBase;
  string private __name;
  string private __symbol;

  bytes4 private constant _INTERFACE_ID_ERC721Metadata = 0x5b5e139f;

  /// @notice Contract constructor
  constructor () public {
    __name = "Baseball cards";
    __symbol = "BCD";
    __uriBase = "http://diamonddream.cards/";

    _registerInterface(_INTERFACE_ID_ERC721Metadata);
  }

  /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
  /// @dev Throws if `_tokenId` is not a valid NFT.
  /// @param tokenId The tokenId of the token of which to retrieve the URI.
  /// @return (string) The URI of the token.
  function tokenURI(uint256 tokenId) external view returns (string memory){
    //Note: changed visibility to public
    require(_exists(tokenId));
    uint256 _tokenId = tokenId;

    uint maxLength = 100;
    bytes memory reversed = new bytes(maxLength);
    uint i = 0;
    while (_tokenId != 0) {
        uint8 remainder = uint8(_tokenId % 10);
        _tokenId /= 10;
        reversed[i++] = byte(48 + remainder);
    }

    bytes memory s = new bytes(__uriBase.length + i);
    uint j;
    for (j = 0; j < __uriBase.length; j++) {
        s[j] = __uriBase[j];
    }
    for (j = 0; j < i; j++) {
        s[j + __uriBase.length] = reversed[i - 1 - j];
    }
    return string(s);
  }

  /// @notice A descriptive name for a collection of NFTs in this contract
  function name() external view returns (string memory _name){
    _name = __name;
  }

  /// @notice An abbreviated name for NFTs in this contract
  function symbol() external view returns (string memory _symbol){
    _symbol = __symbol;
  }

  /// @notice Set URI
  function setURI(string calldata _uriBase) onlyCOO external {
    __uriBase = bytes(_uriBase);
  }

  function setTokenMessage(uint tokenId, string calldata message) external {
    require(ownerOf(tokenId) == msg.sender);

    bytes memory byteMessage = bytes(message);
    require(byteMessage.length <= 120);

    _tokenMessage[tokenId] = byteMessage;
  }

}

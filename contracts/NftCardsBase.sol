pragma solidity ^0.5.0;

import './NftCardsAccessControl.sol';

contract NftCardsBase is NftCardsAccessControl {
  // todo: change rarity to enums
  struct Group {
    uint size;
    uint rarity;
    uint64 createdAt;
    string other;
  }

  struct Entity {
    string name;
    uint16 birthYear;
    string other;
  }

  uint public entityBitSize;
  uint public groupBitSize;
  uint public seqBitSize;

  uint internal eMask;
  uint internal gMask;
  uint internal sMask;

  // current available entity (inclusive)
  uint public entitySize;

  mapping (uint => Entity) internal _entityInfo;
  mapping (uint => Group ) internal _entityGroupInfo;
  mapping (uint => bytes) internal _tokenMessage;

  constructor () public {

    // 000....000-000...000-000......000
    // [entityId]-[groupId]-[sequenceId]
    // [======egId========]-[sequenceId]
    // [==========tokenId==============]


    // todo: put them as arguments
    entityBitSize = 4;
    groupBitSize = 4;
    seqBitSize = 4;

    eMask = 2 ** entityBitSize - 1;
    gMask = 2 ** groupBitSize - 1;
    sMask = 2 ** seqBitSize - 1;
  }

  function getTokenInfo(uint tokenId) public view
    returns (string memory name, uint16 birthYear, uint rarity, uint64 createdAt, uint size, uint sId, string memory eOther, string memory gOther, string memory message)
  {
    require(isTokenExist(tokenId) == true);

    uint egId;
    uint eId;
    uint gId;
    (egId, sId) = splitEGStoEG_S(tokenId);
    (eId, gId) = splitEG(egId);

    (name, birthYear, eOther) = getEntityInfo(eId);
    (rarity, createdAt, size, gOther) = getGroupInfo(joinEG(eId, gId));
    message = string(_tokenMessage[tokenId]);
  }



  // @notice returns info from entity and group
  function getEntityGroupInfo(uint eId, uint gId) public view
    returns (string memory name, uint16 birthYear, uint rarity, uint64 createdAt, uint size, string memory eOther, string memory gOther)
  {

    (name, birthYear, eOther) = getEntityInfo(eId);
    (rarity, createdAt, size, gOther) = getGroupInfo(joinEG(eId, gId));

  }

  function getEntityInfo(uint eId) public view returns (string memory name, uint16 birthYear, string memory other) {
    require(eId < entitySize);
    return (_entityInfo[eId].name, _entityInfo[eId].birthYear, _entityInfo[eId].other);
  }

  function getGroupInfo(uint egId) internal view returns (uint rarity, uint64 createdAt, uint size, string memory other) {
    require(isEGExist(egId) == true);
    return (_entityGroupInfo[egId].rarity, _entityGroupInfo[egId].createdAt, _entityGroupInfo[egId].size, _entityGroupInfo[egId].other);
  }

  function setEntityOther(uint eId, string calldata other) external onlyCOO {
    require(eId < entitySize);
    _entityInfo[eId].other = other;
  }

  function setEntityGroupOther(uint eId, uint gId, string calldata other) external onlyCOO {
    uint egId = joinEG(eId, gId);
    require(isEGExist(egId) == true);
    _entityGroupInfo[egId].other = other;
  }

  function joinEG(uint eId, uint gId) internal view returns (uint) {
    eId = (eMask & eId) << groupBitSize;
    return eId | (gId & gMask);
  }

  function splitEG(uint egId) internal view returns (uint, uint) {
    uint gId = egId & gMask;
    uint eId = egId >> groupBitSize;
    return (eId, gId);
  }

  function joinEGS(uint eId, uint gId, uint sId) internal view returns (uint) {
    uint egId = joinEG(eId, gId) << seqBitSize;
    return egId | (sMask & sId);
  }

  function splitEGStoEG_S(uint tokenId) internal view returns (uint, uint) {
    uint sId = tokenId & sMask;
    uint egId = tokenId >> seqBitSize;
    return (egId, sId);
  }

  function isEGExist(uint egId) internal view returns (bool) {
    return _entityGroupInfo[egId].size > 0;
  }

  function isTokenExist(uint tokenId) internal view returns (bool) {
    uint egId;
    uint sId;
    (egId, sId) = splitEGStoEG_S(tokenId);
    return (sId < _entityGroupInfo[egId].size);
  }
}

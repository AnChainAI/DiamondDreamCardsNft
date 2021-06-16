pragma solidity ^0.5.0;

import "./NftCardsOwnership.sol";

contract NftCardsMinting is NftCardsOwnership {

  /**
   * Mint event indicates the starting index and endIndex (exclusive)
   */
  event Mint(uint startIndex, uint endIndex);
  event Burn(uint tokenId);

  /**
   * @dev Public function to mint new tokens with creation of new entity and new group.
   * @param eId The entity id
   * @param gId The group id
   * @param size The size of the token that you want to mint
   * @param name The name of the new entity
   * @param birthYear The birthYear of the new entity
   */
  function mintNewEntity(uint eId, uint gId, uint size, string calldata name, uint16 birthYear, string calldata eOther, string calldata gOther)
    external
    onlyCOO
  {
    // todo: assign the rarity
    uint rarity = 0;

    require(eId == entitySize);
    require(eId <= eMask);
    require(gId <= gMask);
    require(size <= sMask);
    require(size > 0);

    _entityInfo[eId] = Entity(name, birthYear, eOther);
    entitySize += 1;

    _entityGroupInfo[joinEG(eId, gId)] = Group(size, rarity, uint64(now), gOther);

    _ownedTokensCount[cooAddress].add(size);

    uint start = joinEGS(eId, gId, 0);
    uint end = joinEGS(eId, gId, size);

    addNewToken(start, end);
    emit Mint(start, end);
  }

  /**
   * @dev Public function to mint new tokens with creation of new group but existing entity.
   * @param eId The entity id
   * @param gId The group id
   * @param size The size of the token that you want to mint
   */
  function mintNewGroup(uint eId, uint gId, uint size, string calldata gOther) external onlyCOO {

    // todo: assign the rarity
    uint rarity = 0;

    require(eId < entitySize);

    require(gId <= gMask);
    require(size <= sMask);

    require(size > 0);

    require(isEGExist(joinEG(eId, gId)) == false, "Entity group already existed.");

    _entityGroupInfo[joinEG(eId, gId)] = Group(size, rarity, uint64(now), gOther);

    _ownedTokensCount[cooAddress].add(size);

    uint start = joinEGS(eId, gId, 0);
    uint end = joinEGS(eId, gId, size);
    addNewToken(start, end);
    emit Mint(start, end);
  }

  /**
   * @dev Public function to mint new tokens with creation of existing entity and group.
   * @param eId The entity id
   * @param gId The group id
   * @param size The size of the token that you want to mint
   */
  function mintExistingGroup (uint eId, uint gId, uint size) public onlyCOO {
    // todo: check the rarity
    uint egId = joinEG(eId, gId);
    require(isEGExist(egId) == true);
    require(size > 0);

    require(_entityGroupInfo[egId].size + size <= sMask);

    _entityGroupInfo[egId].size =  _entityGroupInfo[egId].size + size;

    _ownedTokensCount[cooAddress].add(size);

    uint start = joinEGS(eId, gId, _entityGroupInfo[egId].size - size);
    uint end = joinEGS(eId, gId, _entityGroupInfo[egId].size);
    addNewToken(start, end);
    emit Mint(start, end);
  }

  function addNewToken (uint startIndex, uint endIndex) internal {
    for (uint i = startIndex; i < endIndex; i ++) {

      tokenTokenIndexes[i] = ownerTokenIndexes[cooAddress].length;
      ownerTokenIndexes[cooAddress].push(i);

      indexTokens[i] = tokenIndexes.length;
      tokenIndexes.push(i);
    }
  }

  /**
   * @dev Public function to burn a specific token.
   * Reverts if the token does not exist.
   * @param tokenId uint256 ID of the token being burned
   */
  function burn(uint256 tokenId) public onlyCOO {
      require(_exists(tokenId));

      _clearApproval(tokenId);
      address owner = ownerOf(tokenId);

      _ownedTokensCount[owner].decrement();
      _ownedTokensCount[address(-1)].increment();
      _tokenOwner[tokenId] = address(-1);

      // owner enumerable
      uint oldIndex = tokenTokenIndexes[tokenId];
      if(oldIndex != ownerTokenIndexes[owner].length - 1){
         //Move last token to old index
         ownerTokenIndexes[owner][oldIndex] = ownerTokenIndexes[owner][ownerTokenIndexes[owner].length - 1];
         //update token self reference to new pos
         tokenTokenIndexes[ownerTokenIndexes[owner][oldIndex]] = oldIndex;
      }
      ownerTokenIndexes[owner].length--;
      delete tokenTokenIndexes[tokenId];

      // total token enumerable
      oldIndex = indexTokens[tokenId];
      if(oldIndex != tokenIndexes.length - 1){
         //Move last token to old index
         tokenIndexes[oldIndex] = tokenIndexes[tokenIndexes.length - 1];
         indexTokens[ tokenIndexes[oldIndex] ] = oldIndex;
      }
      tokenIndexes.length--;
      delete indexTokens[tokenId];

      emit Burn(tokenId);
  }

}

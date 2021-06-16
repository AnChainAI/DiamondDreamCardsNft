pragma solidity ^0.5.0;

contract NftCardsAccessControl {
  // There are two roles managed here:
  //
  // The CEO: The CEO can reassign other roles, including themself
  // The COO: The COO can mint, burn, setEntityOther, setEntityGroupOther, setURI

  address public ceoAddress;
  address public cooAddress;

  /**
   * @dev The Ownable constructor sets the original `CEO` and `COO` of the contract to the sender
   * account.
   */
  constructor () public {
    cooAddress = msg.sender;
    ceoAddress = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the COO.
   */

  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }

  function setCOO(address _newCOO) external onlyCEO{
    require(_newCOO != address(0));

    cooAddress = _newCOO;
  }

  function setCEO(address _newCEO) external onlyCEO{
    require(_newCEO != address(0));

    ceoAddress = _newCEO;
  }


}

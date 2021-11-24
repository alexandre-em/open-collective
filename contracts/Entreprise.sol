// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "./User.sol";

contract Entreprises is Users {
  struct Entreprise {
    string entrepriseName;
    address payable owner;
    address[] members;
    uint256 entrepriseBalance;
    bool registered;
  }

  mapping(address => Entreprise) private entreprises;

  event EntrepriseOpened(address indexed ownerAddress, Entreprise indexed entreprise);

  /**
   * @dev Open a Entreprise account
   * @param _name {string}
   * @param _balance {uint}
   */
  function openEntreprise(string memory _name, uint256 _balance)
    public
    payable
  {
    require(users[msg.sender].registered, "User not registered");
    require(entreprises[msg.sender].registered, "Already have a company");
    require(bytes(_name).length > 0, "Insert a valid name");
    entreprises[msg.sender] = Entreprise(_name, payable(msg.sender), new address[](1000), _balance, true);
    emit EntrepriseOpened(msg.sender, entreprises[msg.sender]);
  }

  /**
   * @dev An utilitary function to check if the member is already in the group
   * @param newMember {address} member to check
   * @return {bool}
   */
  function contains(address newMember) private view returns (bool) {
    for (uint256 i = 0; i < entreprises[msg.sender].members.length; i++) {
      if (newMember == entreprises[msg.sender].members[i]) {
        return true;
      }
    }
    return false;
  }

  /**
   * @dev The owner of the contract (Entreprise) add a member to his group
   * @param newMember {address} the member added
   */
  function addMember(address newMember) external payable {
    require(entreprises[msg.sender].registered, "Your organisation is not registered");
    require(newMember != msg.sender, "You can't add yourself");
    require(contains(newMember), "The member is already a collaborator");
    entreprises[msg.sender].members.push(newMember);
  }

  /**
   * @dev Remove a member from the group
   */
  function removeMember(address oldMember) external payable {
    require(entreprises[msg.sender].registered, "Your organisation is not registered");
    require(msg.sender != oldMember, "You can't remove yourself");
    for (uint256 i = 0; i < entreprises[msg.sender].members.length; i++) {
      if (entreprises[msg.sender].members.length > 0 && oldMember == entreprises[msg.sender].members[i]) {
        delete entreprises[msg.sender].members[i];
      }
    }
  }
}

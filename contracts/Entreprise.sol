// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "./User.sol";

contract Entreprises is Users {
  struct Entreprise {
    string entrepriseName;
    address owner;
    address[] members;
    uint256 entrepriseBalance;
    bool registered;
  }

  mapping(address => Entreprise) private entreprises;

  event EntrepriseOpened(address indexed ownerAddress, Entreprise indexed entreprise);

  function entreprise(address corpAddr) public view returns (Entreprise memory){
    return entreprises[corpAddr];
  }
  function getMembers() public view returns (address[] memory) {
    require(entreprises[msg.sender].registered, "You do not own any entreprise");
    return entreprises[msg.sender].members;
  } 

  /**
   * @dev Open a Entreprise account
   * @param _name {string}
   */
  function openEntreprise(string memory _name)
    public
    payable
  {
    require(bytes(_name).length > 1, "Insert a valid name");
    require(msg.value > 0, "Amount of the transaction < 0");
    entreprises[msg.sender] = Entreprise(_name, msg.sender, new address[](0), msg.value, true);
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
  function addMember(address newMember) external {
    require(entreprises[msg.sender].registered, "Your organisation is not registered");
    require(newMember != msg.sender, "You can't add yourself");
    require(!contains(newMember), "The member is already a collaborator");
    entreprises[msg.sender].members.push(newMember);
  }

  /**
   * @dev Remove a member from the group
   */
  function removeMember(address oldMember) external {
    require(entreprises[msg.sender].registered, "Your organisation is not registered");
    require(msg.sender != oldMember, "You can't remove yourself");
    for (uint256 i = 0; i < entreprises[msg.sender].members.length; i++) {
      if (entreprises[msg.sender].members.length > 0 && oldMember == entreprises[msg.sender].members[i]) {
        delete entreprises[msg.sender].members[i];
      }
    }
  }

  //ADD
  function depositOnEntreprise() external payable {
    require(entreprises[msg.sender].registered, "Your organisation is not registered");
    require(msg.value > 0, "Amount of the transaction < 0");
    entreprises[msg.sender].entrepriseBalance += msg.value;
  }

  function withdraw(uint256 amount) external {
    require(entreprises[msg.sender].registered, "Your organisation is not registered");
    require(amount > 0, "Amount of the transaction < 0");
    require(entreprises[msg.sender].entrepriseBalance >= amount, "Account balance is downer than your transaction amount");
    entreprises[msg.sender].entrepriseBalance -= amount;
    address payable _owner = payable(msg.sender);
    _owner.transfer(amount);
  }

  function paySalary(address member, uint256 amount) external {
    require(entreprises[msg.sender].registered, "Your organisation is not registered");
    require(amount > 0, "Amount of the transaction < 0");
    require(entreprises[msg.sender].entrepriseBalance >= amount, "Account balance is downer than your transaction amount");
    entreprises[msg.sender].entrepriseBalance -= amount;
    address payable _owner = payable(member);
    _owner.transfer(amount);
  }
}

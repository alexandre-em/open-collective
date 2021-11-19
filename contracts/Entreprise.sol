// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract Entreprise {
    string public entrepriseName;
    address payable private owner;
    address[] private members;
    uint private entrepriseBalance;

    /** 
    * @dev Constructor for the Entreprise contract
    * Payable constructor can receive Ether
    * @param _name {string}
    * @param _balance {uint}
    */ 
    constructor(string memory _name, uint _balance) payable {
        require(bytes(_name).length > 0, "insert a valid name");
        owner = payable(msg.sender);
        entrepriseName = _name;
        entrepriseBalance = _balance;
    }

    /**
    * @dev An utilitary function to check if the member is already in the group
    * @param newMember {address} member to check
    * @return {bool}
    */
    function contains(address newMember) private view returns (bool){
        for (uint i=0; i < members.length; i++) {
            if (newMember == members[i]) {
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
        require(msg.sender == owner, "You are not authorized");
                require(newMember != owner, "You can't add yourself");
        if (!contains(newMember)) {
            members.push(newMember);
        }
    }
    
    /**
    * @dev Remove himself from the group
    */
    function removeMember() external payable {
        require(members.length > 0, "You're not from the group");
                require(msg.sender != owner, "You can't remove yourself");
        address member = msg.sender;
        for (uint i=0; i < members.length; i++) {
            if (members.length > 0 && member == members[i]) {
                delete members[i];
            }
        }
    }
}

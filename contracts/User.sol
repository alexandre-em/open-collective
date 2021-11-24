// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract Users {
  address ownerAddress;
  address[] usersAddress;

  struct User {
    string username;
    uint256 balance;
    uint256 nbTransactions;
    bool registered;
  }

  // users[address] = User;
  mapping(address => User) internal users;

  constructor() payable {
    ownerAddress = msg.sender;
    openAccount("Owner");
  }

  function getOwnerAddress() public view returns (address, string memory) {
    return (ownerAddress, users[ownerAddress].username);
  }

  event UserAdded(
    address add,
    string username,
    uint256 balance,
    uint256 nbTransactions
  );

  function openAccount(string memory _username) public payable {
    require(bytes(_username).length > 0, "Username not valid");
    require(
      !users[msg.sender].registered,
      "Account already openned for this User"
    );
    users[msg.sender] = User(_username, 0, 0, true);
    usersAddress.push(msg.sender);
    emit UserAdded(msg.sender, _username, 0, 0);
  }

  event moneyReceived(
    address add,
    string username,
    uint256 balance,
    uint256 receivedMoney
  );

  /** function only for receive money
   * Click on Transact on Remix Website with an amount of value
   * If User exists, so add deposit to the balance of the user's account
   * Else create a new account with dummy username and add the deposit in this account
   */
  receive() external payable {
    if (users[msg.sender].registered) {
      users[msg.sender].balance += msg.value;
      users[msg.sender].nbTransactions++;
      emit moneyReceived(
        msg.sender,
        users[msg.sender].username,
        users[msg.sender].balance,
        msg.value
      );
    } else {
      openAccount("NoUsername");
      users[msg.sender].nbTransactions++;
      users[msg.sender].balance += msg.value;
    }
  }

  function checkUserBalance()
    external
    view
    returns (
      address,
      string memory,
      uint256,
      uint256
    )
  {
    return (
      msg.sender,
      users[msg.sender].username,
      users[msg.sender].balance,
      users[msg.sender].nbTransactions
    );
  }

  /**
   * address(this) : Contract address
   * address(this).balance : Total balance (all deposit of Users) of the Contract
   */
  function checkContractBalance() external view returns (address, uint256) {
    return (address(this), address(this).balance);
  }

  function changeUsername(string memory _username) external payable {
    require(bytes(_username).length > 0, "Username not valide");
    users[msg.sender].username = _username;
  }

  /**
   * Total Contract Balance will be send to the last sender
   * Contract balance will be update auto.
   */
  function withdrawUserBalance() external {
    address payable _owner = payable(msg.sender);
    _owner.transfer(users[msg.sender].balance);
    users[msg.sender].balance = 0;
  }

  /**
   * Total User Balance will be send to the user
   * each balance of each user account will be put at 0
   */
  function withdrawContractBalance() external {
    require(
      msg.sender == ownerAddress,
      "Only owner can withdraw contract balance"
    );
    address payable _owner = payable(msg.sender);
    _owner.transfer(address(this).balance);
    for (uint256 i = 0; i < usersAddress.length; i++) {
      users[usersAddress[i]].balance = 0;
    }
  }

  function sendMoney(address add, uint256 amount) external payable {
    require(users[msg.sender].registered, "Sender no account");
    require(users[add].registered, "Receiver no account");
    require(amount > 0, "Amount of the transaction need to be upper than 0");
    users[msg.sender].balance -= amount;
    users[add].balance += amount;
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }
}

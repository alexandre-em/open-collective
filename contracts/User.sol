// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract Users {

    struct User {
        address ownerAddress;
        string username;
        uint userBalance;
        uint nbDepositTransactions;
        uint nbWithdrawTransactions;
        bool registered;
    }

    // users[address] = User;
    mapping(address => User) private users;
    
    event UserAdded(address add, string username, uint balance, uint nbDepositTransactions, uint nbWithdrawTransactions);
    
    function openAccount(string memory _username) public payable {
        require(!users[msg.sender].registered, "Account already openned for this User");
        require(bytes(_username).length > 0, "Username not valide");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender] = User(msg.sender, _username, msg.value, 1, 0, true);
        emit UserAdded(msg.sender, _username, msg.value, 1, 0);
    }
    
    event moneyReceived(address add, string username, uint balance, uint receivedMoney);
    
    /** function only for receive money
     * Click on Transact on Remix Website with an amount of value
     * If User exists, so add deposit to the balance of the user's account
     * Else create a new account with dummy username and add the deposit in this account
     */
    receive() external payable {
        require(users[msg.sender].registered,"No account openned for this User");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender].userBalance += msg.value;
        users[msg.sender].nbDepositTransactions++;
        emit moneyReceived(msg.sender, users[msg.sender].username, users[msg.sender].userBalance, msg.value);
    }

    /** 
    * @dev An utilitary function to deposit an amount in the contract
    * Select a value to deposit
    * Click on deposit
    * msg.value will automatically add on contract balance
    * Check the balance
    */
    function deposit() external payable {
        require(users[msg.sender].registered,"No account openned for this User");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender].userBalance += msg.value;
        users[msg.sender].nbDepositTransactions++;
        emit moneyReceived(msg.sender, users[msg.sender].username, users[msg.sender].userBalance, msg.value);
    }
    
    function checkUserBalance() external view returns (address, string memory, uint, uint, uint) {
        return (msg.sender, users[msg.sender].username, users[msg.sender].userBalance, users[msg.sender].nbDepositTransactions, users[msg.sender].nbWithdrawTransactions);
    }
    
    function changeUsername(string memory _username) external payable {
        require(users[msg.sender].registered,"No account openned for this User");
        require(bytes(_username).length > 0, "Username not valide");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender].username = _username;
        users[msg.sender].userBalance += msg.value;
        users[msg.sender].nbDepositTransactions++;
    }
    
    /**
     * Total Contract Balance will be send to the last sender
     * Contract balance will be update auto.
     */
    function withdrawUserBalance(uint amount) external {
        require(users[msg.sender].registered,"No account openned for this User");
        require(amount > 0, "Amount of the transaction need to be upper than 0");
        require(users[msg.sender].userBalance >= amount, "Account balance is downer than your withdraw amount");
        address payable _owner = payable(msg.sender);
        _owner.transfer(amount);
        users[msg.sender].userBalance -= amount;
        users[msg.sender].nbWithdrawTransactions++;
    }
    
    function sendMoney(address add, uint amount) external {
        require(users[msg.sender].registered, "No account openned for the sender");
        require(users[add].registered, "No account openned for the receiver");
        require(amount > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender].userBalance -= amount;
        users[add].userBalance += amount;
    }
}

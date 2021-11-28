// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract Users {

    struct User {
        address ownerAddress;
        string username;
        uint256 userBalance;
        uint nbDepositTransactions;
        uint nbWithdrawTransactions;
        bool registered;
    }

    // Each wallet address is mapped with a User in users list
    mapping(address => User) private users;
    
    event UserAdded(address add, string username, uint256 balance, uint nbDepositTransactions, uint nbWithdrawTransactions);
    
    /**
    * @dev An utilitary function for create a new account for the msg.sender (User)
    * If the User have already an account, this User cannot open an other account
    * Each username need to be valide
    * msg.value will be added with the User account balance
    * @param _username { string }
    */
    function openAccount(string memory _username) public payable {
        require(!users[msg.sender].registered, "Account already openned for this User");
        require(bytes(_username).length > 0, "Username not valide");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender] = User(msg.sender, _username, msg.value, 1, 0, true);
        emit UserAdded(msg.sender, _username, msg.value, 1, 0);
    }
    
    event moneyReceived(address add, string username, uint256 balance, uint receivedMoney);
    
    /** 
    * @dev solidity standard function to deposit an amount without msg.data
    */
    receive() external payable {
        require(users[msg.sender].registered,"No account openned for this User");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender].userBalance += msg.value;
        users[msg.sender].nbDepositTransactions++;
        emit moneyReceived(msg.sender, users[msg.sender].username, users[msg.sender].userBalance, msg.value);
    }

    /** 
    * @dev An utilitary function to deposit an amount in the msg.sender (User) account balance
    * msg.value is added with the msg.sender (User) account balance
    */
    function deposit() external payable {
        require(users[msg.sender].registered,"No account openned for this User");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        users[msg.sender].userBalance += msg.value;
        users[msg.sender].nbDepositTransactions++;
        emit moneyReceived(msg.sender, users[msg.sender].username, users[msg.sender].userBalance, msg.value);
    }
    
    /**
    * @dev An utilitary function to get the msg.sender (User) account details
    * return { address, string, uint, uint, uint }
    */
    function checkUserBalance() external view returns (address, string memory, uint256, uint, uint) {
        require(users[msg.sender].registered,"No account openned for this User");
        return (msg.sender, users[msg.sender].username, users[msg.sender].userBalance, users[msg.sender].nbDepositTransactions, users[msg.sender].nbWithdrawTransactions);
    }
    
    /**
    * @dev An utilitary function to change the msg.sender (User) account username
    * @param _username { string }
    */
    function changeUsername(string memory _username) external payable {
        require(users[msg.sender].registered,"No account openned for this User");
        require(bytes(_username).length > 0, "Username not valide");
        users[msg.sender].username = _username;
    }
    
    /**
    * @dev An utilitary function to withdraw an amount to the msg.sender (User) account
    * the amount will be send to the msg.sender (User)
    * This amount will be deducted from the msg.sender (User) account balance
    * @param amount { uint }
    */
    function withdrawUserBalance(uint256 amount) external {
        require(users[msg.sender].registered,"No account openned for this User");
        require(amount > 0, "Amount of the transaction need to be upper than 0");
        require(users[msg.sender].userBalance >= amount, "Account balance is downer than your withdraw amount");
        address payable _owner = payable(msg.sender);
        _owner.transfer(amount);
        users[msg.sender].userBalance -= amount;
        users[msg.sender].nbWithdrawTransactions++;
    }
    
    /**
    * @dev An utilitary function to send money to the receiver account
    * the amount will be send to the receiver account on the contract
    * This amount will be deducted from the msg.sender (User) account
    * @param amount { address, uint }
    */
    function sendMoney(address add, uint256 amount) external {
        require(users[msg.sender].registered, "No account openned for the sender");
        require(users[add].registered, "No account openned for the receiver");
        require(amount > 0, "Amount of the transaction need to be upper than 0");
        require(users[msg.sender].userBalance >= amount, "Account balance is downer than your transaction amount");
        users[msg.sender].userBalance -= amount;
        users[add].userBalance += amount;
    }
}
pragma solidity >=0.4.22 <0.9.0;

/**
* public : function can be called out of the contract
* private : function can be called only in the contract
* internal : function can be called only in the contract
* external : function can be called only out of the contract
*/

/** Test
 * Part 1 :
 * Select an account, openAccount : "Mike"
 * Choose a value : 10 and click on Transact
 * Select an other account, openAccount : "Hello"
 * Choose a value : 6 and click on Transact
 * Select an other account but not openAccount
 * Choose a value : 3 and click on Transact
 * Select each account and checkUserBalance
 * Check contract balance with checkContractBalance
 * 
 * Part 2 
 * Select an other account, Choose a value : 10, click on Transact and verify the amount of the wallet (account balance ETH with -10 ETH and User balance = 10)
 * Click on UserWithdraw and verify the amount of the wallet (account balance ETH with +10 ETH and User balance = 0)
 * Click on ContractWithdraw (blalance = 50) and verify the amount of the wallet (account balance ETH with +50 ETH and Contract balance = 0)
*/

contract UsersCollective {

    uint minimumTransfer = 0 wei;

    struct User {
        string username;
        uint balance;
        uint numTrnasactions;
        bool registered;
    }

    // users[address] = User;
    mapping(address => User) private users;

    event UserAdded(address add, string username, uint balance, uint nbTransactions);
    
    function openAccount(string memory _username) public payable returns (bool) {
        require(bytes(_username).length > 0);
        if(!users[msg.sender].registered){
            users[msg.sender] = User(_username, 0, 0, true);
            emit UserAdded(msg.sender, _username, 0, 0);
            return true;
        }
        else{
            return false;
        }
    }
    
    event moneyReceived(address add, string username, uint balance, uint receivedMoney);
    
    /** function only for receive money
     * Click on Transact on Remix Website with an amount of value
     * If User exists, so add deposit to the balance of the user's account
     * Else create a new account with dummy username and add the deposit in this account
     */
    receive() external payable {
        if(!users[msg.sender].registered){
            users[msg.sender].balance += msg.value;
            users[msg.sender].numTrnasactions++;
            emit moneyReceived(msg.sender, users[msg.sender].username, users[msg.sender].balance, msg.value);
        }
        else {
            openAccount("NoUsername");
            users[msg.sender].numTrnasactions++;
            users[msg.sender].balance += msg.value;
        }
    }
    
    function checkUserBalance() external view returns (address, string memory, uint, uint) {
        return (msg.sender, users[msg.sender].username, users[msg.sender].balance, users[msg.sender].numTrnasactions);
    }
    
    /**
     * address(this) : Contract address
     * address(this).balance : Total balance (all deposit of Users) of the Contract
     */
    function checkContractBalance() external view returns (address, uint) {
        return (address(this), address(this).balance);
    }
    
    function changeUsername(string calldata _username) external payable {
        users[msg.sender].username = _username;
    }
    
    /**
     * Total Contract Balance will be send to the last sender
     * Contract balance will be update auto. [NOT IMPLEMENTED]
     */
    function withdrawUserBalance() external payable {
        address payable _owner = payable(msg.sender);
        _owner.transfer(users[msg.sender].balance);
        users[msg.sender].balance = 0;
    }
    
    /**
     * Total User Balance will be send to the user
     * each balance of each user account will be put at 0
     */
    // function withdrawContractBalance() external payable {
    //     address payable _owner = payable(msg.sender);
    //     _owner.transfer(address(this).balance);
    // }
    
    /*
    function sendMoney(address add) public payable returns (bool) {
        if(users[msg.sender].registered && users[add].registered){
            require(msg.value >= minimumTransfer);
            users[msg.sender].balance -= msg.value;
            users[add].balance += msg.value;
            return true;
        }
        else{
            return false;
        }
    }
    */
}

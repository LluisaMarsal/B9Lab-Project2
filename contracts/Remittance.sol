pragma solidity ^0.4.19;

contract Remittance {

    address public owner;
    
    struct RemittanceBox {
       address sentFrom;
       address moneyChanger; 
       address sendVia;
       uint amount;
       uint deadline; 
    }
    // for every bytes32 there is a newRemittance and that namespace (struct) will be called RemittanceBox
    mapping (bytes32 => RemittanceBox) public newRemittance; 

    event LogClaim(address sentFrom, uint amount);
    event LogWithdrawal(address sentFrom, uint amount);
    event LogOwnerChanged(address owner, address newOwner);  
    
    function Remittance(address sentFrom) public {
        sentFrom = msg.sender; 
    }

    function claimRemittance(bytes32 password1, bytes32 password2) public returns(bool success) {
        bytes32 hashedPassword = keccak256(password1, password2);
        RemittanceBox memory r = newRemittance[hashedPassword]; // this is the code the user implicitly sent
        require(r.amount > 0); // if this box is empty, disallow
        r.sendVia.transfer(r.amount);
        LogClaim(msg.sender, r.amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword) public returns(bool success) {
        require(newRemittance[hashedPassword].sendVia == msg.sender);
        require(newRemittance[hashedPassword].amount >= 0);
        require(newRemittance[hashedPassword].deadline < now); 
        return true;
    }
    
    function sendRemittance(bytes32 hashedPassword) public payable returns(bool success) {
        newRemittance[hashedPassword].amount += msg.value;
        newRemittance[hashedPassword].sentFrom = msg.sender;
        newRemittance[hashedPassword].moneyChanger.transfer(msg.value);
        newRemittance[hashedPassword].amount += 0;
        LogWithdrawal(msg.sender, newRemittance[hashedPassword].amount);
        return true;
    }

    function changeOwner(address newOwner) public {
        require (owner == msg.sender);
        owner = newOwner;
        LogOwnerChanged(owner, newOwner);
    }

    function killMe() public returns (bool) {
        require (owner == msg.sender);
        selfdestruct(owner);
        return true;
    }
}
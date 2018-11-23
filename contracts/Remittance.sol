pragma solidity ^0.4.19;

contract Remittance {

    address public sentFrom;
    
    struct RemittanceBox {
       address moneyChanger; 
       address sendVia;
       uint amount;
       uint deadline; 
    }
    // for every bytes32 there is a newRemittance and that namespace (struct) will be called RemittanceBox
    mapping (bytes32 => RemittanceBox) public newRemittance; 

    event LogClaim(address sentFrom, uint amount);
    event LogWithdrawal(address sentFrom, uint amount);
    event LogSenderChanged(address sentFrom, address newSender);  
    
    function Remittance() public {
        sentFrom = msg.sender; 
    }

    function claimRemittance(address moneyChanger, bytes32 password1, bytes32 password2) public returns(bool success) {
        bytes32 hashedPassword = keccak256(password1, password2);
        newRemittance[hashedPassword] = RemittanceBox(moneyChanger, sendVia, amount, 30);
        RemittanceBox memory r = newRemittance[hashedPassword]; // this is the code the user implicitly sent
        require(r.amount > 0); // if this box is empty, disallow
        newRemittance[hashedPassword].sendVia.transfer(amount);
        LogClaim(msg.sender, amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword) public payable returns(bool success) { 
        require(sentFrom = newRemittance[hashedPassword].sendVia);
        require(newRemittance[hashedPassword].amount += 0);
        require(now > newRemittance[hashedPassword].deadline); 
        newRemittance[hashedPassword].moneyChanger.transfer(newRemittance.amount);
        LogWithdrawal(msg.sender, newRemittance[hashedPassword].amount);
        newRemittance[hashedPassword].amount -= 0;
        return true;
    }

    function changeSender(address newSender) public {
        require (sentFrom == msg.sender);
        sentFrom = newSender;
        LogSenderChanged(sentFrom, newSender);
    }

    function killMe() public returns (bool) {
        require (sentFrom == msg.sender);
        selfdestruct(sentFrom);
        return true;
    }
}
pragma solidity ^0.4.19;

contract Remittance {
 
    struct NewRemittance {
       address recipient1; 
       address recipient2;
       uint amount;
       uint deadline; 
       bytes32 passHash1;
       bytes32 passHash2;
    }
    
    mapping (bytes32 => NewRemittance) public remittanceBoxes; 

    event LogToken(address recipient1, bytes32 passHash1, bytes32 passHash2);
    event LogWithdrawal(address owner, uint amount);
    event LogWithdrawalDate(uint constant date); 
    event LogTransferEther(address sender, address recipient1, uint value); 
    event LogReceipt(address recipient2, uint amount); 
    event LogOwnerChanged(address owner, address newOwner);  
    
    function Remittance(address recipient1, address recipient2, uint amount, uint deadline, bytes32 passHash1, bytes32 passHash2) public {
        address owner = msg.sender;
        remittanceBoxes[owner] = NewRemittance(recipient1, recipient2, amount, 30, passHash1, passHash2);
    }

    function token(bytes32 passHash1, bytes32 passHash2, address recipient1, address recipient2) public returns (bool) {
        require (passHash1 != bytes32(0));
        require (passHash2 != bytes32(0));
        require (passHash1 != passHash2);
        require (recipient1 != address(0x0)); 
        require (recipient2 != address(0x0));
        require (recipient1 != recipient2); 
        LogToken(recipient1, passHash1, passHash2);
        return true;
    }
    
    function withdraw(uint deadline, uint date, bool token) public { 
        if (token == true) {        
        require (amount >= 0);
        uint amount = remittanceBoxes[owner];
        LogWithdrawal(msg.sender, amount);
        msg.sender.transfer(amount);
        }
        require(now < deadline); 
        LogWithdrawalDate(date); 
    }

    function transferEther(address  recipient1, uint amount) public payable {
        require (msg.value > 0);
        remittanceBoxes[recipient1] += msg.value;
        LogTransferEther(msg.sender, recipient1, msg.value);
    } 
    
    function receipt(address recipient2, uint amount) public returns (bool) {
        if (msg.value == amount) {
        return true;    
        }
        LogReceipt(recipient2, msg.value);
    }

    function changeOwner(address owner, address newOwner) public {
        require (msg.sender = owner);
        owner = newOwner;
        LogOwnerChanged(owner, newOwner);
    }

    function killMe(address owner) public returns (bool) {
        require (msg.sender = owner);
        selfdestruct(owner);
        return true;
    }
}

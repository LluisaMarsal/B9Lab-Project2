pragma solidity ^0.4.19;

contract Remittance {

    address public owner;
    
    struct NewRemittance {
       address recipient1; 
       address recipient2;
       uint amount;
       uint deadline; 
       bytes32 passHash1;
       bytes32 passHash2;
    }
    //for every bytes32 there is a NewRemittance and that namespace will be called remittanceBoxes
    mapping (bytes32 => NewRemittance) public remittanceBoxes; 

    event LogWithdrawal(address owner, uint amount);
    event LogWithdrawalDate(uint date); 
    event LogTransferEther(address sender, address recipient1, uint value); 
    event LogReceipt(address recipient2, uint amount); 
    event LogOwnerChanged(address owner, address newOwner);  
    
    function Remittance(address recipient1, address recipient2, uint amount, uint deadline, bytes32 passHash1, bytes32 passHash2) public {
        owner = msg.sender; 
        remittanceBoxes[passHash2] = NewRemittance(recipient1, recipient2, amount, 30, passHash1, passHash2);
    }

    function unlockRecipient1Funds(bytes32 passHash1, bytes32 passHash2, address recipient1, address recipient2) public {
        require(passHash1 != passHash2);
        require(recipient1 != address(0x0)); 
        require(recipient2 != address(0x0));
        require(recipient1 != recipient2); 
        require(recipient2 != 0);
        if(keccak256(passHash1, passHash2) = "0x123...!") {
            recipient1.transfer(address(this).balance);
        }
    }
    
    function withdraw(uint deadline, uint date, uint amount) public { 
        require (amount >= 0);
        amount = NewRemittance;
        LogWithdrawal(msg.sender, amount);
        msg.sender.transfer(amount);
        require(now < deadline); 
        LogWithdrawalDate(date); 
    }

    function transferEther(address recipient1) public payable {
        require (msg.value > 0);
        NewRemittance += msg.value;
        LogTransferEther(msg.sender, recipient1, msg.value);
    } 
    
    function receipt(address recipient2, uint amount) public returns (bool) {
        if (msg.value == amount) {
        return true;    
        }
        LogReceipt(recipient2, msg.value);
    }

    function changeOwner(address owner, address newOwner) public {
        require (msg.sender == owner);
        owner = newOwner;
        LogOwnerChanged(owner, newOwner);
    }

    function killMe(address owner) public returns (bool) {
        require (msg.sender == owner);
        selfdestruct(owner);
        return true;
    }
}
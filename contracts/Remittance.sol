pragma solidity ^0.4.19;

contract Remittance {

    address public owner;
    
    struct NewRemittance {
       address recipient1; 
       address recipient2;
       uint amount;
       uint deadline; 
       bytes32 passHash;
    }
    //for every bytes32 there is a NewRemittance and that namespace will be called remittanceBoxes
    mapping (bytes32 => NewRemittance) public remittanceBoxes; 

    event LogWithdrawal(address owner, uint amount);
    event LogWithdrawalDate(uint date); 
    event LogReceipt(address recipient2, uint amount); 
    event LogOwnerChanged(address owner, address newOwner);  
    
    function Remittance(address recipient1, address recipient2, uint amount, bytes32 passHash) public {
        owner = msg.sender; 
        remittanceBoxes[passHash] = NewRemittance(recipient1, recipient2, amount, 30, passHash);
    }

    function claimRemittance(bytes32 passHash, uint pass1, uint pass2, address recipient1, address recipient2, uint amount) public {
        require(recipient1 != address(0x0)); 
        require(recipient2 != address(0x0));
        require(recipient1 != recipient2); 
        require(recipient2 != 0);
        if(keccak256(pass1, pass2) = passHash) {
            NewRemittance = keccak256(pass1, pass2);
            recipient1.transfer(address(this).amount);
        }
    }
    
    function cancelRemittance(uint deadline, uint date, uint amount) public { 
        require(NewRemittance = (amount > 0));
        LogWithdrawal(msg.sender, amount);
        require(now < deadline); 
        LogWithdrawalDate(date); 
    }
    
    function receipt(address recipient2, uint amount) public returns (bool) {
        if (msg.value == amount) {
        return true;    
        }
        LogReceipt(recipient2, msg.value);
    }

    function changeOwner(address newOwner) public {
        require (msg.sender == owner);
        owner = newOwner;
        LogOwnerChanged(owner, newOwner);
    }

    function killMe() public returns (bool) {
        require (msg.sender == owner);
        selfdestruct(owner);
        return true;
    }
}
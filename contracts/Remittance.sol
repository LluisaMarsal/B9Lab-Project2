pragma solidity ^0.4.19;

contract Remittance {

    address public owner;
    
    struct NewRemittance {
       address recipient1; 
       address recipient2;
       uint amount;
       uint balance;
       uint deadline; 
       bytes32 passHash;
    }
    // for every bytes32 there is a NewRemittance and that namespace will be called remittanceBoxes
    mapping (bytes32 => NewRemittance) public remittanceBoxes; 

    event LogDeposit(address owner, uint amount);
    event LogWithdrawal(address owner, uint amount);
    event LogReceipt(address recipient2, uint amount); 
    event LogOwnerChanged(address owner, address newOwner);  
    
    function Remittance() public {
        owner = msg.sender; 
    }

    function claimRemittance(bytes32 pass1, bytes32 pass2) public returns(bool success) {
        address recipient1;
        address recipient2;
        require(recipient1 != address(0x0)); 
        require(recipient2 != address(0x0));
        require(recipient1 != recipient2); 
        require(recipient2 != 0);
        uint amount = remittanceBoxes[passHash];
        uint balance = remittanceBoxes[passHash];
        remittanceBoxes[passHash] = NewRemittance(recipient1, recipient2, amount, balance, 30, passHash);
        bytes32 passHash = keccak256(pass1, pass2);
        NewRemittance memory r = remittanceBoxes[passHash]; // this is the code the user implicitly sent
        require(r.amount > 0); // if this box is empty, disallow
        balance[msg.sender] += amount;
        LogDeposit(msg.sender, amount);
        return true;
    }
    
    function cancelRemittance(uint deadline, uint amount) public payable returns(bool success) { 
        require(now < deadline); 
        require(amount == NewRemittance);
        uint balance = NewRemittance;
        balance[msg.sender] -= amount;
        LogWithdrawal(msg.sender, amount);
        recipient1.transfer(NewRemittance.amount);
        return true;
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
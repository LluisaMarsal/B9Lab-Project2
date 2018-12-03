pragma solidity ^0.4.19;
 
contract Remittance {
    
    address public owner;
    uint fee = 50;
    
    struct RemittanceBox {
       address sentFrom;
       address moneyChanger; 
       uint amount;
       uint deadline; 
    }
    // for every bytes32 there is a RemittanceBox and those namespaces (struct) will conform a mapping named remittanceStructs
    mapping (bytes32 => RemittanceBox) public remittanceStructs; 

    event LogDeposit(address sentFrom, address moneyChanger, uint amount, uint duration);
    event LogCollect(address moneyChanger, uint amount, uint now);
    event LogCancel(address sentFrom, uint amount, uint now);
    event LogOwnerChanged(address owner, address newOwner, uint now);  
    
    function Remittance() public {
        owner = msg.sender;
    }

    function hashHelper(bytes32 password1, bytes32 password2) public pure returns(bytes32 hashedPassword) {
        return keccak256(password1, password2);
    }
    
    function depositRemittance(bytes32 hashedPassword, address moneyChanger, uint duration) public payable returns(bool success) {
        remittanceStructs[hashedPassword].amount = msg.value;
        remittanceStructs[hashedPassword].moneyChanger = moneyChanger;
        remittanceStructs[hashedPassword].deadline = duration + block.number;
        LogDeposit(msg.sender, moneyChanger, msg.value, duration);
        owner.transfer(fee);
        return true;
    }
    
    function collectRemittance(bytes32 password1, bytes32 password2, uint amount) public returns(bool success) {
        bytes32 hashedPassword = hashHelper(password1, password2);
        require(remittanceStructs[hashedPassword].moneyChanger == msg.sender);
        remittanceStructs[hashedPassword].amount = amount;
        LogCollect(msg.sender, remittanceStructs[hashedPassword].amount, now);
        msg.sender.transfer(amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword, uint amount) public returns(bool success) {
        if(remittanceStructs[hashedPassword].amount == 0) revert();
        require(remittanceStructs[hashedPassword].sentFrom == msg.sender);
        require(remittanceStructs[hashedPassword].amount == amount);
        require(remittanceStructs[hashedPassword].deadline < now); 
        LogCancel(msg.sender, amount, now);
        msg.sender.transfer(amount);
        return true;
    }
    
    function changeOwner(address newOwner) public returns(bool success) {
        require(owner == msg.sender);
        owner = newOwner;
        LogOwnerChanged(owner, newOwner, now);
        return true;
    }

    function killMe() public returns(bool success) {
        require(owner == msg.sender);
        selfdestruct(owner);
        return true;
    }
}
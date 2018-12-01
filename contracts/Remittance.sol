pragma solidity ^0.4.19;
 
contract Remittance {
    
    address public owner;
    
    struct RemittanceBox {
       address sentFrom;
       address moneyChanger; 
       uint amount;
       uint deadline; 
    }
    // for every bytes32 there is a RemittanceBox and those namespaces (struct) will conform a mapping named remittanceStructs
    mapping (bytes32 => RemittanceBox) public remittanceStructs; 

    event LogDeposit(address sentFrom, uint amount);
    event LogCollect(address sentFrom, address moneyChanger, uint amount);
    event LogOwnerChanged(address owner, address newOwner);  
    
    function Remittance() public {
        owner = msg.sender;
    }
    
    function ownerComission() public returns(bool success) {
        require(owner == msg.sender);
        msg.sender.transfer(50);
        return true;
    }

    function hashHelper(bytes32 password1, bytes32 password2) public pure returns(bytes32 hashedPassword) {
        return keccak256(password1, password2);
    }
    
    function depositRemittance(bytes32 hashedPassword, address moneyChanger, uint duration) public payable {
        remittanceStructs[hashedPassword].amount = msg.value + 50;
        remittanceStructs[hashedPassword].moneyChanger = moneyChanger;
        remittanceStructs[hashedPassword].deadline = duration + block.number;
        LogDeposit(msg.sender, msg.value);
    }
    
    function collectRemittance(bytes32 password1, bytes32 password2, uint amount) public {
        bytes32 hashedPassword = hashHelper(password1, password2);
        require(remittanceStructs[hashedPassword].moneyChanger == msg.sender);
        remittanceStructs[hashedPassword].amount = amount - 50;
        msg.sender.transfer(amount);
        LogCollect(msg.sender, remittanceStructs[hashedPassword].moneyChanger, remittanceStructs[hashedPassword].amount);
    }
    
    function cancelRemittance(bytes32 hashedPassword, uint amount) public returns(bool success) {
        require(remittanceStructs[hashedPassword].sentFrom == msg.sender);
        require(remittanceStructs[hashedPassword].amount == amount);
        require(remittanceStructs[hashedPassword].deadline < now); 
        msg.sender.transfer(amount);
        return true;
    }
    
    function changeOwner(address newOwner) public {
        require(owner == msg.sender);
        owner = newOwner;
        LogOwnerChanged(owner, newOwner);
    }

    function killMe() public returns (bool) {
        require(owner == msg.sender);
        selfdestruct(owner);
        return true;
    }
}
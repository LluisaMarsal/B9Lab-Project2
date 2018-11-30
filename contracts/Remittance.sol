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
    // for every bytes32 there is a RemittanceBox and those namespaces (struct) will conform a mapping named remittanceStructs
    mapping (bytes32 => RemittanceBox) public remittanceStructs; 

    event LogAllocation(address sentFrom, uint amount);
    event LogClaim(address sentFrom, address moneyChanger, uint amount);
    event LogOwnerChanged(address owner, address newOwner);  
    
    function Remittance() public {
        owner = msg.sender;
    }
    
    function ownerComission (address moneyChanger) public payable returns(bool success) {
        owner.transfer(500);
        return true;
    }

    function depositRemittance(bytes32 hashedPassword) public payable returns(bool success) {
        RemittanceBox memory r = remittanceStructs[hashedPassword]; // this is the code the user implicitly sent
        r.sendVia.transfer(r.amount);
        LogAllocation(msg.sender, r.amount);
        return true;
    }
    
    function collectRemittance(bytes32 password1, bytes32 password2) public returns(bool success) {
        bytes32 hashedPassword = keccak256(password1, password2);
        remittanceStructs[hashedPassword].amount = msg.value;
        remittanceStructs[hashedPassword].sentFrom = msg.sender;
        remittanceStructs[hashedPassword].moneyChanger.transfer(msg.value);
        LogClaim(msg.sender, remittanceStructs[hashedPassword].moneyChanger, remittanceStructs[hashedPassword].amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword) public payable returns(bool success) {
        require(remittanceStructs[hashedPassword].sentFrom == msg.sender);
        require(remittanceStructs[hashedPassword].amount >= 0);
        require(remittanceStructs[hashedPassword].deadline < now); 
        remittanceStructs[hashedPassword].sentFrom.transfer(msg.value);
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
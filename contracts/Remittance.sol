pragma solidity ^0.4.19;

import "./Pausable.sol";
 
contract Remittance is Pausable {
    
    uint constant fee = 50;
    uint constant maxDurationInBlocks = 4 weeks / 15;
    
    struct RemittanceBox {
       address sentFrom;
       address moneyChanger; 
       address owner;
       uint amount;
       uint deadline; 
    }
    // for every bytes32 there is a RemittanceBox and those namespaces (struct) will conform a mapping named remittanceStructs
    mapping (bytes32 => RemittanceBox) public remittanceStructs; 

    event LogDeposit(address indexed sentFrom, address indexed moneyChanger, uint amount, uint fee, uint numberOfBlocks);
    event LogCollect(address indexed moneyChanger, uint amount);
    event LogCancel(address indexed sentFrom, uint amount);
    
    function Remittance() public {
    }

    function hashHelper(bytes32 password1, bytes32 password2) public pure returns(bytes32 hashedPassword) {
        return keccak256(password1, password2);
    }
    
    function depositRemittance(bytes32 hashedPassword, address moneyChanger, address owner, uint numberOfBlocks) public payable onlyIfRunning returns(bool success) {
        require(remittanceStructs[hashedPassword].amount == 0);
        require(remittanceStructs[hashedPassword].moneyChanger != 0x0);
        require(remittanceStructs[hashedPassword].deadline > 0);
        require(msg.value > fee);
        require(numberOfBlocks > 1 days / 15);
        require(numberOfBlocks < 4 weeks / 15);
        remittanceStructs[hashedPassword].owner = owner;
        remittanceStructs[hashedPassword].moneyChanger = moneyChanger;
        remittanceStructs[hashedPassword].sentFrom = msg.sender;
        remittanceStructs[hashedPassword].amount = msg.value - fee;
        remittanceStructs[hashedPassword].deadline = block.number + numberOfBlocks;
        LogDeposit(msg.sender, moneyChanger, msg.value, fee, numberOfBlocks);
        owner.transfer(fee);
        return true;
    }
        
    function collectRemittance(bytes32 password1, bytes32 password2) public onlyIfRunning returns(bool success) {
        bytes32 hashedPassword = hashHelper(password1, password2);
        uint amount = remittanceStructs[hashedPassword].amount;
        require(amount != 0);
        require(remittanceStructs[hashedPassword].moneyChanger == msg.sender);
        require(remittanceStructs[hashedPassword].deadline >= block.number + maxDurationInBlocks);
        remittanceStructs[hashedPassword].amount = 0;
        LogCollect(msg.sender, remittanceStructs[hashedPassword].amount);
        msg.sender.transfer(amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword) public onlyIfRunning returns(bool success) {
        require(remittanceStructs[hashedPassword].amount != 0);
        require(remittanceStructs[hashedPassword].sentFrom == msg.sender);
        require(remittanceStructs[hashedPassword].deadline < block.number + maxDurationInBlocks); 
        uint amount = remittanceStructs[hashedPassword].amount;
        remittanceStructs[hashedPassword].amount = 0;
        LogCancel(msg.sender, amount);
        msg.sender.transfer(amount);
        return true;
    }
}
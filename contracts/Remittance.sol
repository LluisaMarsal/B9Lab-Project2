pragma solidity ^0.4.19;

import "./Pausable.sol";
 
contract Remittance is Pausable {
    
    uint constant fee = 50;
    uint constant maxDurationInBlocks = 4 weeks / 15;
    uint constant minDurationInBlocks = 1 days / 15;
    
    struct RemittanceBox {
       address sentFrom;
       address moneyChanger; 
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
    
    function depositRemittance(bytes32 hashedPassword, address moneyChanger, uint numberOfBlocks) public payable onlyIfRunning returns(bool success) {
        require(hashedPassword != 0);
        require(remittanceStructs[hashedPassword].amount == 0);
        require(msg.value > fee);
        require(moneyChanger != 0x0);
        require(numberOfBlocks > minDurationInBlocks);
        require(numberOfBlocks < maxDurationInBlocks);
        remittanceStructs[hashedPassword].moneyChanger = moneyChanger;
        remittanceStructs[hashedPassword].sentFrom = msg.sender;
        remittanceStructs[hashedPassword].amount = msg.value - fee;
        remittanceStructs[hashedPassword].deadline = block.number + numberOfBlocks;
        LogDeposit(msg.sender, moneyChanger, msg.value, fee, numberOfBlocks);
        super.getOwner().transfer(fee);
        return true;
    }
        
    function collectRemittance(bytes32 password1, bytes32 password2) public onlyIfRunning returns(bool success) {
        bytes32 hashedPassword = hashHelper(password1, password2);
    //this goes before requirements as an exception, to avoid having to write twice in the box and therefore
    //save some serious gas. You can do that when variables are transient (stored in memory, not in storage)
        uint amount = remittanceStructs[hashedPassword].amount;
        require(amount != 0);
        require(remittanceStructs[hashedPassword].moneyChanger == msg.sender);
        require(remittanceStructs[hashedPassword].deadline >= block.number);
        remittanceStructs[hashedPassword].amount = 0;
        remittanceStructs[hashedPassword].deadline = 0;
        remittanceStructs[hashedPassword].moneyChanger = 0x0;
        remittanceStructs[hashedPassword].sentFrom = 0x0; 
        LogCollect(msg.sender, remittanceStructs[hashedPassword].amount);
        msg.sender.transfer(amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword) public onlyIfRunning returns(bool success) {
        require(remittanceStructs[hashedPassword].amount != 0);
        require(remittanceStructs[hashedPassword].sentFrom == msg.sender);
        require(remittanceStructs[hashedPassword].deadline < block.number); 
        uint amount = remittanceStructs[hashedPassword].amount;
        remittanceStructs[hashedPassword].amount = 0;
        remittanceStructs[hashedPassword].deadline = 0;
        remittanceStructs[hashedPassword].sentFrom = 0x0; 
        remittanceStructs[hashedPassword].moneyChanger = 0x0; 
        LogCancel(msg.sender, amount);
        msg.sender.transfer(amount);
        return true;
    }
}
pragma solidity ^0.4.19;

import "./Owned.sol";
import "./Pausable.sol";
 
contract Remittance is Owned, Pausable {
    
    uint constant fee = 50;
    uint constant durationInBlocks = 2592000;
    
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
    event LogCollect(address indexed moneyChanger, uint amount, uint blockNumber);
    event LogCancel(address indexed sentFrom, uint amount, uint blockNumber);
    
    function Remittance() public {
    }

    function hashHelper(bytes32 password1, bytes32 password2) public pure returns(bytes32 hashedPassword) {
        return keccak256(password1, password2);
    }
    
    function depositRemittance(bytes32 hashedPassword, address moneyChanger, uint numberOfBlocks) public payable onlyIfRunning returns(bool success) {
        remittanceStructs[hashedPassword].deadline = block.number + numberOfBlocks;
        require(remittanceStructs[hashedPassword].amount == 0);
        require(remittanceStructs[hashedPassword].moneyChanger != 0x0);
        require(remittanceStructs[hashedPassword].deadline > 0);
        require(remittanceStructs[hashedPassword].deadline < durationInBlocks);
        require(msg.value > fee);
        address owner = remittanceStructs[hashedPassword].owner;
        remittanceStructs[hashedPassword].moneyChanger = moneyChanger;
        remittanceStructs[hashedPassword].sentFrom = msg.sender;
        remittanceStructs[hashedPassword].amount = msg.value - fee;
        LogDeposit(msg.sender, moneyChanger, msg.value, fee, numberOfBlocks);
        owner.transfer(fee);
        return true;
    }
        
    function collectRemittance(bytes32 password1, bytes32 password2) public onlyIfRunning returns(bool success) {
        bytes32 hashedPassword = hashHelper(password1, password2);
        uint amount = remittanceStructs[hashedPassword].amount;
        require(amount != 0);
        require(remittanceStructs[hashedPassword].moneyChanger == msg.sender);
        require(remittanceStructs[hashedPassword].deadline > block.number); 
        remittanceStructs[hashedPassword].amount = 0;
        LogCollect(msg.sender, remittanceStructs[hashedPassword].amount, block.number);
        msg.sender.transfer(amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword) public onlyIfRunning returns(bool success) {
        require(remittanceStructs[hashedPassword].amount != 0);
        require(remittanceStructs[hashedPassword].sentFrom == msg.sender);
        require(remittanceStructs[hashedPassword].deadline < block.number); 
        uint amount = remittanceStructs[hashedPassword].amount;
        remittanceStructs[hashedPassword].amount = 0;
        LogCancel(msg.sender, amount, block.number);
        msg.sender.transfer(amount);
        return true;
    }
}
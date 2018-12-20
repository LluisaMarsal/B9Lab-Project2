pragma solidity ^0.4.19;
 
contract Remittance {
    
    address public owner;
    uint fee = 50;
    bool isRunning;
    
    struct RemittanceBox {
       address sentFrom;
       address moneyChanger; 
       uint amount;
       uint deadline; 
    }
    // for every bytes32 there is a RemittanceBox and those namespaces (struct) will conform a mapping named remittanceStructs
    mapping (bytes32 => RemittanceBox) public remittanceStructs; 

    event LogDeposit(address sentFrom, address moneyChanger, address owner, uint amount, uint fee, uint numberOfBlocks);
    event LogCollect(address moneyChanger, uint amount, uint blockNumber);
    event LogCancel(address sentFrom, uint amount, uint blockNumber);
    event LogOwnerChanged(address owner, address newOwner, uint blockNumber); 
    event LogPausedContract(address sender, uint blockNumber);
    event LogResumedContract(address sender, uint blockNumber);
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    modifier onlyIfRunning {
        require(isRunning);
        _;
    }
    
    function Remittance() public {
        owner = msg.sender;
        isRunning = true;
    }

    function hashHelper(bytes32 password1, bytes32 password2) public pure returns(bytes32 hashedPassword) {
        return keccak256(password1, password2);
    }
    
    function depositRemittance(bytes32 hashedPassword, address moneyChanger, address sentFrom, uint numberOfBlocks) public payable onlyIfRunning returns(bool success) {
        require(remittanceStructs[hashedPassword].amount == 0);
        require(msg.value > fee);
        remittanceStructs[hashedPassword].moneyChanger = moneyChanger;
        remittanceStructs[hashedPassword].sentFrom = sentFrom;
        remittanceStructs[hashedPassword].deadline = block.number + numberOfBlocks;
        remittanceStructs[hashedPassword].amount = msg.value - fee;
        LogDeposit(msg.sender, moneyChanger, owner, msg.value, fee, numberOfBlocks);
        owner.transfer(fee);
        return true;
    }
        
    function collectRemittance(bytes32 password1, bytes32 password2) public onlyIfRunning returns(bool success) {
        bytes32 hashedPassword = hashHelper(password1, password2);
        require(remittanceStructs[hashedPassword].amount != 0);
        require(remittanceStructs[hashedPassword].moneyChanger == msg.sender);
        require(remittanceStructs[hashedPassword].deadline < block.number); 
        uint amount = remittanceStructs[hashedPassword].amount;
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
    
    function changeOwner(address newOwner) public onlyIfRunning onlyOwner returns(bool success) {
        owner = newOwner;
        LogOwnerChanged(owner, newOwner, now);
        return true;
    }

    function pauseContract() public onlyOwner onlyIfRunning returns(bool success) {
        isRunning = false; 
        LogPausedContract(msg.sender, now);
        return true;
    }

    function resumeContract() public onlyOwner returns(bool success) {
        isRunning = true; 
        LogResumedContract(msg.sender, now);
        return true;
    }
}
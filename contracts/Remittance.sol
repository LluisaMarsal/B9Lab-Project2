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

    event LogDeposit(address sentFrom, address moneyChanger, uint amount, uint duration);
    event LogCollect(address moneyChanger, uint amount, uint now);
    event LogCancel(address sentFrom, uint amount, uint now);
    event LogOwnerChanged(address owner, address newOwner, uint now); 
    event LogPausedContract(address sender, uint now);
    event LogResumedContract(address sender, uint now);
    
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
    
    function depositRemittance(bytes32 hashedPassword, address moneyChanger, uint duration) public payable onlyIfRunning returns(bool success) {
        if(remittanceStructs[hashedPassword].amount != 0) revert();
        require(msg.value > fee);
        remittanceStructs[hashedPassword].moneyChanger = moneyChanger;
        remittanceStructs[hashedPassword].deadline = duration + block.number;
        remittanceStructs[hashedPassword].amount = msg.value - 50;
        LogDeposit(msg.sender, moneyChanger, msg.value, duration);
        owner.transfer(fee);
        return true;
    }
        
    function collectRemittance(bytes32 password1, bytes32 password2, address sentFrom, uint amount) public onlyIfRunning returns(bool success) {
        bytes32 hashedPassword = hashHelper(password1, password2);
        require(remittanceStructs[hashedPassword].moneyChanger == msg.sender);
        require(remittanceStructs[hashedPassword].amount == amount);
        remittanceStructs[hashedPassword].sentFrom = sentFrom;
        LogCollect(msg.sender, remittanceStructs[hashedPassword].amount, now);
        msg.sender.transfer(amount);
        return true;
    }
    
    function cancelRemittance(bytes32 hashedPassword) public onlyIfRunning returns(bool success) {
        if(remittanceStructs[hashedPassword].amount == 0) revert();
        require(remittanceStructs[hashedPassword].sentFrom == msg.sender);
        require(remittanceStructs[hashedPassword].deadline < now); 
        uint amount = remittanceStructs[hashedPassword].amount;
        LogCancel(msg.sender, amount, now);
        msg.sender.transfer(amount);
        return true;
    }
    
    function changeOwner(address newOwner) public onlyIfRunning onlyOwner returns(bool success) {
        require(owner == msg.sender);
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
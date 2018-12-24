pragma solidity ^0.4.19;

contract Owned { 
    
    address owner; 
    bool isRunning;
    
    event LogOwnerChanged(address owner, address newOwner, uint blockNumber); 
    event LogPausedContract(address sender, uint blockNumber);
    event LogResumedContract(address sender, uint blockNumber);
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }   
    
    function Owned() public {
        owner = msg.sender;
    }
    
    function changeOwner(address newOwner) public onlyOwner returns(bool success) {
        owner = newOwner;
        LogOwnerChanged(owner, newOwner, now);
        return true;
    }
    
    function pauseContract() public onlyOwner returns(bool success) {
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
pragma solidity ^0.4.19;

import "./Owned.sol";

contract Pausable is Owned { 
    
//By convention the private boolean field underlying a getter does not include "is". 
    bool private running;
    
    event LogPausedContract(address indexed sender);
    event LogResumedContract(address indexed sender);
    
    modifier onlyIfRunning {
        require(running);
        _;
    }
    
    function Pausable() public {
        running = true;
    }
    
    function pauseContract() public onlyOwner returns(bool success) {
        running = false; 
        LogPausedContract(msg.sender);
        return true;
    }

    function resumeContract() public onlyOwner returns(bool success) {
        running = true; 
        LogResumedContract(msg.sender);
        return true;
    }
//By convention, a getter for a boolean starts with "is" 
    function isRunning() public view returns(bool) {
        return running;
    }
}
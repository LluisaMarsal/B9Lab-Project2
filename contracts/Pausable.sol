pragma solidity ^0.4.19;

import "./Owned.sol";

contract Pausable is Owned { 
    
    bool isRunning;
    
    event LogPausedContract(address sender);
    event LogResumedContract(address sender);
    
    modifier onlyIfRunning {
        require(isRunning);
        _;
    }
    
    function Pausable() public {
        isRunning = true;
    }
    
    function pauseContract() public onlyOwner returns(bool success) {
        isRunning = false; 
	    LogPausedContract(msg.sender);
	    return true;
    }

    function resumeContract() public onlyOwner returns(bool success) {
        isRunning = true; 
	    LogResumedContract(msg.sender);
	    return true;
    }
}
pragma solidity ^0.4.19;

import "./Owned.sol";

contract Pausable is Owned { 
    
    bool private isRunning;
    
    event LogPausedContract(address indexed sender);
    event LogResumedContract(address indexed sender);
    
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
    
    function getIsRunning() public view returns(bool) {
        return isRunning;
    }
}
pragma solidity ^0.4.19;

contract Owned { 
    
    address private owner; 
    
    event LogOwnerChanged(address owner, address newOwner); 
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }   
    
    function Owned() public {
        owner = msg.sender;
    }
    
    function changeOwner(address newOwner) public onlyOwner returns(bool success) {
        owner = newOwner;
        LogOwnerChanged(owner, newOwner);
        return true;
    }
}
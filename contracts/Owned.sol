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
        require(newOwner != 0x0);
        require(newOwner != owner);
        owner = newOwner;
        LogOwnerChanged(owner, newOwner);
        return true;
    }
    
    function getOwner() public view returns(address) {
        return owner;
    }
}
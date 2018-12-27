pragma solidity ^0.4.19;

contract Owned { 
    
    address private owner; 
    address private newOwner;
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }   
    
    function Owned() public {
        owner = msg.sender;
    }
    
    function changeOwner() private onlyOwner returns(bool success) {
        require(newOwner != 0x0);
        owner = newOwner;
        return true;
    }
    
    function getOwnerAddress() public view returns(address) {
        return owner;
    }
    
    function getNewOwnerAddress() public view returns(address) {
        return newOwner;
    }
}
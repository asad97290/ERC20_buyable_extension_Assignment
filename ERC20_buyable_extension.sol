pragma solidity ^0.6.2;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract ERC20_buyable_extension is ERC20
{
    using SafeMath for uint256;
    
    address public owner;
    
    uint256 public basePrice;  
    uint256 timeTillTransactionLock;
    
    address payable public approver;
    
    constructor(uint256 _basePrice) 
    public
    ERC20("Asad Token","AT")
    {
        // e.g = 100 * (10**uint256(decimals()));
        basePrice = _basePrice * (10**uint256(decimals()));
        owner = msg.sender;
        uint initialToken = 1000000 * (10**uint256(decimals()));
        _mint(owner,initialToken);
    }
    
     modifier onlyOwner(){
        require(msg.sender == owner,"Permission Denied: Only owner can access this resource");
        _;
    }
    modifier only_owner_or_approver(){
        require(msg.sender == owner || msg.sender == approver,"Permission Denied: Only owner can access this resource");
        _;
    }
    
    function assignApprover(address payable newApprover) public onlyOwner{
        require(newApprover != address(0), "BCC1: approve to the zero address");
        approver = newApprover;
    }                  
    
    function transferOwnership(address newOwner) public onlyOwner{
        owner = newOwner;
    }
    
    function managePrice(uint256 newPrice) only_owner_or_approver public{
        basePrice = newPrice;
    }
    
    function lockTransferUntil(uint256 time) public {
        require(time>0 && time > now,"Invalid Time: time must be greater current");    
        timeTillTransactionLock = time;
    }
    
    function withdrawTokens() payable public{
        //1 month = 2628000 sec
        lockTransferUntil(now+2628000);
        require(now == timeTillTransactionLock ,"Transaction is Locked. Please try again" );  
        uint256 tokenBalance = balanceOf(msg.sender); 
        payable(msg.sender).transfer(basePrice.mul(tokenBalance));
        _transfer(msg.sender,owner,tokenBalance);
    }    
}

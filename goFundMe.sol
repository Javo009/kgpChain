// SPDX-License-Identifier: MIT
// Aaryan Javalekar 21AE30030 KGP Blockchain Society Selection Task Submission (Technical)
pragma solidity ^0.8.7;

error NotOwner();

// I have removed the library for price conversion

contract FundMe {

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public owner; // This is no longer immutable as we have add Change of Ownership Functionality

    uint256 public constant MINIMUM_ETH = 1e18; //Since we are not using Chainlink, for price conversions, I have taken minimum ETH, not USD
    
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= MINIMUM_ETH, "You need to spend more ETH!");
        // I have removed the price coverter function so it now takes eth values(wei actually) directly now
        addressToAmountFunded[msg.sender] += msg.value;
        if(CheckUser(msg.sender)==2) {
            funders.push(msg.sender);     // We will add user only if CheckUser function says user has not yet funded
        }
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // Functions checks if user is unique by seeing funding till now. If the funding is 0, it means it's a new user.
    function CheckUser(address CheckThisAddress) public view returns (uint flag) {  
        if (addressToAmountFunded[CheckThisAddress] == 0)            
            return 2;
    }

    /* Function only allows access to current owner. The current owner can change the ownership. If any other user tries to call the 
    function, it reverts using onlyOwner modifier
    The current owner simply has to call the function by passing new owner as parameter*/
    function ChangeOwnership(address NewOwner) public onlyOwner {
        owner = NewOwner;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}
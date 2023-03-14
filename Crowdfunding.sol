// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address payable public owner;
    uint public goal;
    uint public raised;
    uint public deadline;
    mapping(address => uint) public contributions;
    bool public closed;
    bool public canceled;
    mapping(address => uint) public refunds;
    
    event Contribution(address contributor, uint amount);
    event Refund(address contributor, uint amount);
    event Withdrawal(address owner, uint amount);
    event Cancellation(address owner);
    
    constructor(uint _goal, uint _durationDays) {
        owner = payable(msg.sender);
        goal = _goal;
        deadline = block.timestamp + _durationDays * 1 days;
    }
    
    function contribute() payable public {
        require(!closed && !canceled, "Crowdfunding is closed or canceled");
        contributions[msg.sender] += msg.value;
        raised += msg.value;
        emit Contribution(msg.sender, msg.value);
    }
    
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(raised >= goal, "Goal not yet reached");
        payable(owner).transfer(raised);
        closed = true;
        emit Withdrawal(owner, raised);
    }
    
    function cancel() public {
        require(msg.sender == owner, "Only the owner can cancel");
        canceled = true;
        closed = true;
        emit Cancellation(owner);
    }
    
    function refund() public {
        require(canceled || block.timestamp >= deadline, "Cannot refund before deadline or if not canceled");
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution to refund");
        contributions[msg.sender] = 0;
        refunds[msg.sender] = amount;
        payable(msg.sender).transfer(amount);
        emit Refund(msg.sender, amount);
    }
    
    function getRefund() public {
        uint amount = refunds[msg.sender];
        require(amount > 0, "No refund available");
        refunds[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Refund(msg.sender, amount);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract FundRaising{

    address payable public owner;
    uint public totalFundReq;
    uint public totalFundRaised;
    uint public totalDonar;
    uint public totalVote;
    uint public votingEndTime;
    uint remainingFund;
    uint public endTime;
    uint totalAsk=1;
    bool fundClamed;
    bool public votingStatus;

    mapping(address=>uint) public donars;
    mapping(address=>bool) public voted;

    constructor(uint _totalFundReq, uint _endTime){
        owner = payable(msg.sender);
        endTime = block.timestamp + _endTime;
        totalFundReq = _totalFundReq;
    }

    function sendFund() external payable {
        require(block.timestamp < endTime, "Deadline has passed !!");
        require(msg.sender != owner, "School cannot participate in fund raising!!");
        require(msg.value > 0, "Minimum contribution is 1");

        // check for new contributor
        if(donars[msg.sender] == 0){
            totalDonar++;
        }
        donars[msg.sender] = donars[msg.sender] + msg.value;
        totalFundRaised = totalFundRaised + msg.value;
    }

    function getContractBalance() external view returns(uint) {
        return address(this).balance;
    }

    function startVoting(uint _votingEndTime) external {
        require(msg.sender == owner, "Only School can start voting");
        require(block.timestamp > endTime, "Deadline has not passed yet!!");
        votingEndTime = block.timestamp + _votingEndTime;
        votingStatus = true;
    }

    function putVote() external {
        require(votingStatus == true, "Voting has not started yet!!");
        require(block.timestamp < votingEndTime,"Voting time has passed!!");
        require(donars[msg.sender] != 0, "You are not allowed to participate as you have not cotributed!!");
        require(voted[msg.sender] == false, "You have already voted!!");
        totalVote++;
        voted[msg.sender] = true;
    }

    function claimFund() public{
        require(fundClamed == false, "Fund is already claim!!");
        require(msg.sender == owner, "Only School can claim the funds!!");
        require(block.timestamp > endTime,"Crowdfunding not over yet!!");

        if(totalAsk == 1){
            uint transferAmt = totalFundRaised / 10;  //sending 10% of total fund raised; 
            remainingFund = totalFundRaised-transferAmt;
            totalAsk++;
            owner.transfer(transferAmt);
        }else{
            require(block.timestamp > votingEndTime,"Voting time has not yet passed!!");
            require(totalVote > totalDonar/2, "Majority does not support" );
            fundClamed = true;
            uint transferAmt = remainingFund;
            remainingFund =0;
            owner.transfer(transferAmt);
        }
        
    }


}

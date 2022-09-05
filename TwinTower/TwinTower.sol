// SPDX-License-Identifier: GPL-3.0
// 10000000000000000000 wei = 10 eth

pragma solidity ^0.8.0;

contract TwinTower{

    address payable public owner;
    uint public totalFlats;
    uint public flatPrice;
    string public projectName;
    uint public endTime;
    uint public totalBuyers;
    uint public soldFlats;
    uint public votingEndTime;
    uint public totalVote;
    bool fundClamed;

    struct BuyerDetails {
        address payable buyerAddress;
        uint totalAmountPaid;
        uint amountRemaining;
        bool fundClamed;
    }

    BuyerDetails[] public buyerDetails;        //Array to store buyer details
    mapping(address=>uint) public buyerMap;
    mapping(address=>bool) public voted;

    event Message(string msg);

    constructor(uint _totalFlats, uint _flatPrice, string memory _projectName, uint _endTime, uint _votingEndTime){
        owner = payable(msg.sender);
        endTime = block.timestamp + _endTime;
        totalFlats = _totalFlats;
        flatPrice = _flatPrice;
        projectName = _projectName;
        votingEndTime = block.timestamp + _votingEndTime;
        buyerDetails.push();
    }

    function buyFlat() external payable {
        require(block.timestamp < endTime, "Deadline has passed !!");
        require(msg.sender != owner, "Onwer cannot buy flat !!");
        require(buyerMap[msg.sender] == 0, "Only new buyers are allowed !!");
        require(msg.value < flatPrice, "Please check the flat price !!");
        require(msg.value > 0, "Minimum price to book is 1eth !!");
        require(soldFlats<totalFlats, "All flats are sold !!");

        BuyerDetails memory buyer = BuyerDetails({
            buyerAddress: payable(msg.sender),
            totalAmountPaid: msg.value,
            amountRemaining: flatPrice - msg.value,
            fundClamed: false
        });

        soldFlats++;
        totalBuyers++;
        buyerDetails.push(buyer);
        buyerMap[msg.sender] = buyerDetails.length-1;
        emit Message("Flat bought !!");
    }

    function getBuyerDetails() external view returns(BuyerDetails memory){
        uint location = buyerMap[msg.sender];
        return buyerDetails[location];
    }

    function depositFund() external payable {
        require(block.timestamp < endTime, "Deadline has passed !!");
        require(msg.sender != owner, "Onwer cannot buy flat !!");
        require(buyerMap[msg.sender] != 0, "You are new buyer !!");

        uint location = buyerMap[msg.sender];
        BuyerDetails memory buyer = buyerDetails[location];

        require(msg.value <= buyer.amountRemaining, "Please check the remaining amount !!");
        require(msg.value > 0, "Minimum price to deposit is 1eth !!");
        buyerDetails[location].totalAmountPaid = buyerDetails[location].totalAmountPaid + msg.value;
        buyerDetails[location].amountRemaining = buyerDetails[location].amountRemaining - msg.value;

        emit Message("Money deposited !!");
    }

    function getContractBalance() external view returns(uint) {
        return address(this).balance;
    }

    function putVote() external {
        require(msg.sender != owner, "Owner can not vote!!");
        require(block.timestamp > endTime, "Project has not ended yet!!");
        require(block.timestamp < votingEndTime,"Voting time has passed!!");
        require(buyerMap[msg.sender] != 0, "You have not buyed flat!!");
        require(voted[msg.sender] == false, "You have already voted!!");
        totalVote++;
        voted[msg.sender] = true;
    }

    function claimFundContractor() public{
        require(fundClamed == false, "Fund is already claim!!");
        require(msg.sender == owner, "Only Contracter can claim the funds!!");
        require(block.timestamp > endTime,"Project not over yet!!");
        require(block.timestamp > votingEndTime,"Voting time has not yet passed!!");
        require(totalVote > totalBuyers/2, "Majority does not support hence you cannot claim" );
        uint amount = address(this).balance;
        fundClamed = true;
        owner.transfer(amount);
    }

    function claimFundUser() public{
        require(buyerMap[msg.sender] != 0, "You have not buyed flat!!");
        require(msg.sender != owner, "Only Contracter can claim the funds!!");
        require(block.timestamp > endTime,"Project not over yet!!");
        require(block.timestamp > votingEndTime,"Voting time has not yet passed!!");
        require(totalVote < totalBuyers/2, "Majority supports contractor hence you cannot claim" );
        uint location = buyerMap[msg.sender];
        require(buyerDetails[location].fundClamed == false,"Funds already claimed !!");

        uint amount = buyerDetails[location].totalAmountPaid;
        buyerDetails[location].totalAmountPaid = 0;
        buyerDetails[location].fundClamed = true;
        address payable buyer = buyerDetails[location].buyerAddress;
        buyer.transfer(amount);
    }


}

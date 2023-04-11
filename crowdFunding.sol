// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract CrowdFunding{
    address public manager;
    mapping(address=>uint) public contributors;
    uint public deadline;
    uint public target;
    uint public minimumContribution;
    uint public raisedAmount;
    uint public noOfContributers; 
    struct Request{
        string description;
        uint value;
        address payable recipient;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    constructor(uint _deadline,uint _target){
        target=_target;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei; 
        manager =msg.sender; 
    }
    function sendEth() public payable{
        require(block.timestamp<deadline,"deadtine passes!!");
        require(msg.value>=minimumContribution,"min contribution should be 100 wei");
        if(contributors[msg.sender]==0)
        {
            noOfContributers++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;

    }
    function getBalace() public view returns(uint){
        return address(this).balance;
    }
    function refund() public {
        require(block.timestamp>deadline && raisedAmount<target);
        require(contributors[msg.sender]>0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"only manager can call");
        _;
    }
    function createRequest(string memory _description , address payable _recipient , uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed = false;
        newRequest.noOfVoters=0;

    }
    function vote(uint _noOfRequest) public {
        require(contributors[msg.sender]>0,"must be a contributer");
        Request storage thisRequest = requests[_noOfRequest];
        require(thisRequest.voters[msg.sender]==false,"already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;

    }
    function makePayment(uint _noOfRequest) public onlyManager{
        require(raisedAmount>=target,"target hasn't filfil");
        Request storage thisRequest = requests[_noOfRequest];
        require(thisRequest.completed==false,"payment has been made");
        require(thisRequest.noOfVoters>noOfContributers/2,"Majority denied!");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;

    }

}

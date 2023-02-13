// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.18;
// @author Blextick (Cristian Richarte Gil)
// @title Blextick Event fabric.


/** THINGS TO ADD:
    - Set % FOR MINTING FEE, WHEN THE EVENT CONTRACT CHECKS THE MINTING FEE WIL RETURN A % THAT WILL BE TRANSFER TO THE FABRIC CONTRACT
**/

import "./Event.sol";

contract EventFabric {

    address public owner;
    uint256 public mintingFee; // It should be a %.
    bool public isStopped; // Stop & reanude creating new events .
    uint256 public eventsCount; // Frist event will be 0.
    bool private locked;

    // Event ID => Event address
    mapping(uint => address) eventsIndex;

    event mintingFeeUpdated(uint256 newMintingFee, uint256 updateTime);
    event FundsWithdrawn(address indexed caller, address indexed to, uint256 amount, uint256 updateTime);
    event EventCreated(address indexed organizer, uint256 eventID, address indexed eventAddress, uint256 creationTime);
    event StatusUpdated(bool status, uint256 updateTime);

    modifier onlyOwner{
        require(owner == msg.sender, "Not Owner");
        _;
    }

    modifier reentrancyGuard {
        require(locked == true);
        locked = true;
        _;
        locked = false;
    }
    
    constructor() {
        owner = msg.sender;

    }

    // Function to create new events
    function createEvent(string memory _name, string memory _symbol, string memory _location, uint256 _date, uint256 _hour, uint256 _price, uint256 _totalSupply, uint256 _maxPerUser, string memory _baseURI) external {
        //require(Organization verified by Schema ZK Polygon ID);
        
        Event newEvent = new Event(_name, _symbol, _location, _date, _hour, _price, _totalSupply, _maxPerUser, _baseURI, msg.sender);

        eventsIndex[eventsCount] = address(newEvent);
        emit EventCreated(msg.sender, eventsCount, address(newEvent), block.timestamp);
        ++eventsCount;
    }

    /** 
     * @dev Withdraw function
     * @param to: Address to send the value from the Smart contract.
     * @param amount: Total amount to transfer.
     */
    function withdraw(address payable to, uint256 amount) external payable onlyOwner reentrancyGuard returns(bool) {
        require(to != address(0), "Not a valid address");
        (to).transfer(amount);
        emit FundsWithdrawn(msg.sender, to, amount, block.timestamp);
        return true;
    }

    // function to stop & reanude new events
    function updateScStatus(bool _status) external onlyOwner{
        isStopped = _status;
        emit StatusUpdated(_status, block.timestamp);
    }

    // Setter for the minting fee.
    function setMintingFee(uint256 _mintingFee) external onlyOwner{
        mintingFee = _mintingFee;
        emit mintingFeeUpdated(_mintingFee, block.timestamp);
    }

    // Function to transfer the ownership of the protocol.
    function transferOwner(address _newOwner) external onlyOwner returns(bool){
        owner = _newOwner;
        return true;
    }
}

// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.18;
// @author Blextick (Cristian Richarte Gil)
// @title Blextick Event tickets.

/** THINGS TO ADD:
    - CHECK MINTING FEE FROM FABRIC CONTRACT.
    - CHECK KYC POLYGON ID (USER) "This is how the user will logged in".
    - ADJUST TRANSFER FUNCTIONS TO ONLY ALLOW maxTicketsUser PER USER.
    - MAKE THE CONTRACT MORE EFFICIENT (MODIFY REQUIRES WITH CUSTOM ERRORS)
**/
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./lib/GenesisUtils.sol";
import "./interfaces/ICircuitValidator.sol";
import "./verifiers/ZKPVerifier.sol";
// import "./EventFabric.sol";

// Contract address: 0xF756B97D670f08E794685f6B825e7E46a5791523

contract Event is ERC721, ZKPVerifier{

    address private eventFabric;
    string private baseURI; // Example: https://cristianricharte6.github.io/metadata/
    uint256 public date;
    uint256 public price;
    uint256 public maxSupply;
    uint256 public nFTsMinted; // First NFT minted will be 0.
    uint256 public maxTicketsUser; // Maximum number of tickets per user
    bool internal locked; // Reentracy guard
    bool public mintingStatus; // True = Paused | False = Unpaused
    // ZKP
    uint64 public constant TRANSFER_REQUEST_ID = 1;

    // ZKP
    mapping(uint256 => address) public idToAddress;
    mapping(address => uint256) public addressToId;

    // User address => total amount of tickets
    mapping (address => uint256) public amountTickets;
    // After validating Schema the wallet can buy
    mapping(address => bool) private kycPassed;

    event NFTMinted(address indexed minter, uint256 nftId, uint256 mintingTime);
    event FundsWithdrawn(address indexed caller, address indexed to, uint256 amount, uint256 updateTime);
    event ticketPriceUpdated(uint256 newPrice, uint256 updateTime);
    event PausedContract(bool contractStatus, uint256 updateTime);
    event UnpauseContract(bool contractStatus, uint256 updateTime);
    event BaseURIUpdated(string newBaseURI, uint256 updateTime);

    modifier reentrancyGuard {
        require(locked == true);
        locked = true;
        _;
        locked = false;
    }

    // /** 
    //  * @param name_: NFT Collection Name. (Plantiverse)
    //  * @param symbol_: NFT Collection Symbol. (PLANT)
    //  * @param baseURI_: Base URI where the NFTs Metadata is Stored.
    //  */
    constructor(string memory _name, string memory _symbol, uint256 _date, uint256 _price, uint256 _maxSupply, uint256 _maxTicketsUser, string memory baseURI_, address _organizer) ERC721(_name, _symbol){
        date = _date;
        price = _price;
        maxSupply = _maxSupply;
        maxTicketsUser = _maxTicketsUser;
        baseURI = baseURI_;
        transferOwnership(_organizer);
        eventFabric = msg.sender;
    }    


    // Pay tickets
    function buyTicket(uint256 _amount) external payable {
        require(!mintingStatus, "Minting is paused");
        require(kycPassed[msg.sender], "Verify your KYC");
        require(nFTsMinted + _amount <= maxSupply, "Sold out");
        require(amountTickets[msg.sender] + _amount < maxTicketsUser, "Can't buy more");
        uint256 totalPrice = price * _amount;
        require(msg.value == totalPrice, "Pay ticket price");
        // Pay ticket fee
        (bool sent,) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        // Mint ticket
        for(uint256 i; i < _amount;){
            _mint(_msgSender(), nFTsMinted);
            emit NFTMinted(msg.sender, nFTsMinted, block.timestamp);
            // Increment total tickets minted
            amountTickets[msg.sender]++;
            ++nFTsMinted;
            ++i;
        }
    }

    //ZKP -> Verifies requirements and submits proof
    function _beforeProofSubmit(
        uint64, /* requestId */
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal view override {
        // check that challenge input of the proof is equal to the msg.sender 
        address addr = GenesisUtils.int256ToAddress(
            inputs[validator.getChallengeInputIndex()]
        );
        require(
            _msgSender() == addr,
            "address in proof is not a sender address"
        );
    }

    //ZKP -> After address is verified mint NFTs
    function _afterProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal override {
        require(
            requestId == TRANSFER_REQUEST_ID && addressToId[_msgSender()] == 0,
            "proof can not be submitted more than once"
        );

        uint256 id = inputs[validator.getChallengeInputIndex()];
        // execute the airdrop
        if (idToAddress[id] == address(0)) {
            addressToId[_msgSender()] = id;
            idToAddress[id] = _msgSender();
            //Allow the user to mint & buy tickets.
            kycPassed[msg.sender] = true;
        }
    }

    //ZKP
    function _beforeTokenTransfer(
        address, /* from */
        address to,
        uint256 batchSize/* token */
    ) internal view  {
        require(
            proofs[to][TRANSFER_REQUEST_ID] == true,
            "only identities who provided proof are allowed to receive tokens"
        );

        require(amountTickets[to] + batchSize <= maxTicketsUser, "Can't receive more");

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

    /** 
     * @dev Setter function to stop or reanude the minting function
     * @param status: Pause or Unpause minting new NFTs.
     */
    function setPauseContract(bool status) external onlyOwner{
        mintingStatus = status;

        if(status == true) {
            emit PausedContract(status, block.timestamp);
        }else {
            emit UnpauseContract(status, block.timestamp);
        }
    } 

    /** 
     * @dev Setter for Minting Fee.
     * @param newPrice: New Minting Fee to set.
     */
    function updatePrice(uint256 newPrice) external onlyOwner{
        price = newPrice;
        emit ticketPriceUpdated(newPrice, block.timestamp);
    }

    /**
     * @dev Setter for Base URI.
     * @param newBaseURI: New Base URI to set.
     */
    function updateBaseURI(string memory newBaseURI) external onlyOwner{
        baseURI = newBaseURI;

        emit BaseURIUpdated(newBaseURI, block.timestamp);
    }

    /**
     * @dev Getter for a concatenated string of base URI + Token URI + file extension.
     * @param _tokenId: NFT Id.
     */
    function tokenURI(uint256 _tokenId) public view override(ERC721) returns (string memory) {
        return string(abi.encodePacked(ERC721.tokenURI(_tokenId),".json"));
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev Receive function to allow the contract receive ETH.
     */
    receive() external payable {}
}
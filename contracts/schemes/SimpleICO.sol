pragma solidity ^0.4.11;
import "../controller/Controller.sol";
import "zeppelin/contracts/ownership/Ownable.sol";
import "zeppelin/contracts/SafeMath.sol";


contract SimpleICO is Ownable, SafeMath {
    Controller            controller;
    uint        public    cap;            // Cap in Eth
    uint        public    price;          // Price represents Tokens per 1 Eth
    uint        public    startBlock;
    uint        public    endBlock;
    uint        public    totalEthRaised;
    bool        public    isOpen;

    event DonationRecieved( address indexed _sender, uint _incomingEther  ,uint indexed _tokensAmount );

    // Constructor:
    function SimpleICO(
        Controller  _controller,
        address     _owner,
        uint        _cap,
        uint       _price,
        uint       _periodInBlocks)
    {
        controller = _controller;
        owner = _owner;
        cap = _cap;
        price = _price;
        startBlock = block.number;
        endBlock = startBlock + _periodInBlocks;
        isOpen = true;
    }

    // When either is sent to contract, buy tokens with it:
    function () payable {
          donate();
    }

    // Owner closes ICO:
    function closePCO() onlyOwner {
          isOpen = false;
    }

    // Owner reopens ICO:
    function reopenPCO() onlyOwner {
          isOpen = true;
    }

    // Donating ethers to get tokens:
    function donate() payable returns(uint) {
        // Check PCO is open:
        require(isOpen);
        // Check cap reached:
        require(totalEthRaised < cap);
        // Check time cap:
        require(block.number <= endBlock);

        uint incomingEther;
        uint change;

        // Compute how much tokens to buy:
        if ( msg.value > safeSub(cap, totalEthRaised) ) {
            incomingEther = safeSub(cap, totalEthRaised);
            change = safeSub(msg.value, incomingEther);
        } else {
            incomingEther = msg.value;
        }
        uint tokens = safeMul(incomingEther, getCurrentPrice());

        // Send ether to controller (to be avatar), mint, and send change to user:
        controller.transfer(incomingEther);
        if(! controller.mintTokens(int(tokens), msg.sender)) revert();
        if (change != 0)
            msg.sender.transfer(change);

        // Update total raised, call event and return amount of tokens bought:
        totalEthRaised += incomingEther;
        DonationRecieved(msg.sender, incomingEther, tokens);
        return tokens;
    }

    // replace this with any other price function
    function getCurrentPrice() returns (uint){
      return price;
    }
}

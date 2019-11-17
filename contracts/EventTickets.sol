pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
     */
    address payable public owner;
    uint   TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */

    struct Event{
        string  description; 
        string  website;  
        uint totalTickets;  
        uint sales; 
        mapping (address => uint) buyers;  
        bool isOpen; 
        }

     Event myEvent;
    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */

    event LogBuyTickets(address purchaser, uint numberOfTickets);
    event LogGetRefund(address requester, uint numberOfTickets);
    event LogEndSale(address owner, uint balanceTransferend);
    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner is authorized");
        _;
    }

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */

    constructor(string memory description, string memory website, uint totalTickets) public{
        owner = msg.sender;
        myEvent.description = description;
        myEvent.website = website;
        myEvent.totalTickets = totalTickets;
        myEvent.isOpen = true;
    }

    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
       function readEvent() view public
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (myEvent.description, myEvent.website, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount(address _buyer) view public 
        returns (uint)
        {
            return myEvent.buyers[_buyer];
        }

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */
    function buyTickets(uint _numberOfTickets) payable public
    {
        uint totalAmount  = _numberOfTickets * TICKET_PRICE;

        require(totalAmount > 0, "Error: Total amount is 0");
        require(myEvent.isOpen, "Error: event is not open yet");
        require(msg.value >= totalAmount,"Error: it does not enough money to buy tickets");
        require(_numberOfTickets <=  (myEvent.totalTickets - myEvent.sales), "Error : It does not enough tickets for sale");

        myEvent.buyers[msg.sender] += _numberOfTickets;
        myEvent.sales += _numberOfTickets;

        if(msg.value > totalAmount) {
            msg.sender.transfer(msg.value - totalAmount);
        }
        emit LogBuyTickets(msg.sender, _numberOfTickets);
    }
    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */

    function getRefund() public {
        uint numberOfTickets = getBuyerTicketCount(msg.sender);
        uint totalPayable = numberOfTickets * TICKET_PRICE;

        require(numberOfTickets > 0, "Error : No tickets to refund");

        myEvent.sales -= numberOfTickets;
        myEvent.buyers[msg.sender] = 0;

        msg.sender.transfer(totalPayable);

        emit LogGetRefund(msg.sender, numberOfTickets);
    }

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */

    function endSale() onlyOwner public {
        uint totalPayable = myEvent.sales * TICKET_PRICE;
        myEvent.isOpen = false;
        owner.transfer(totalPayable);

        emit LogEndSale(msg.sender, totalPayable);
    }
}


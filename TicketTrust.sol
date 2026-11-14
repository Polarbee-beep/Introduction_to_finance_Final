import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";


contract TicketTrust is AccessControl, Pausable {
    bytes32 public constant ORGANIZER_ROLE = keccak256("ORGANIZER_ROLE");
    bytes32 public constant SCANNER_ROLE = keccak256("SCANNER_ROLE");

    enum Status { None, Valid, Used, Cancelled }

    struct Ticket {
        uint256 eventId;
        address holder;
        Status status;
    }

    mapping(uint256 => Ticket) private tickets;
    mapping(uint256 => address) public eventOrganizer;

    event EventRegistered(uint256 indexed eventId, address indexed organizer);
    event TicketIssued(uint256 indexed ticketId, uint256 indexed eventId, address indexed holder);
    event TicketTransferred(uint256 indexed ticketId, address indexed from, address indexed to);
    event TicketCancelled(uint256 indexed ticketId);
    event TicketUsed(uint256 indexed ticketId, address indexed scanner);

    error InvalidAddress();
    error EventAlreadyRegistered();
    error UnknownEvent();
    error TicketAlreadyExists();
    error TicketNotFound();
    error NotTicketHolder();
    error InvalidTicketState();
    error SameHolder();

    constructor(address admin) {
        if (admin == address(0)) revert InvalidAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORGANIZER_ROLE, admin);
    }

    function grantOrganizer(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (account == address(0)) revert InvalidAddress();
        _grantRole(ORGANIZER_ROLE, account);
    }

    function grantScanner(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (account == address(0)) revert InvalidAddress();
        _grantRole(SCANNER_ROLE, account);
    }

    function registerEvent(uint256 eventId) external onlyRole(ORGANIZER_ROLE) whenNotPaused {
        if (eventOrganizer[eventId] != address(0)) revert EventAlreadyRegistered();
        eventOrganizer[eventId] = msg.sender;
        emit EventRegistered(eventId, msg.sender);
    }

    function issueTicket(uint256 ticketId, uint256 eventId, address holder)
        external onlyRole(ORGANIZER_ROLE) whenNotPaused
    {
        if (eventOrganizer[eventId] == address(0)) revert UnknownEvent();
        if (eventOrganizer[eventId] != msg.sender) revert UnknownEvent();
        if (holder == address(0)) revert InvalidAddress();
        if (tickets[ticketId].status != Status.None) revert TicketAlreadyExists();

        tickets[ticketId] = Ticket(eventId, holder, Status.Valid);
        emit TicketIssued(ticketId, eventId, holder);
    }

    function transferTicket(uint256 ticketId, address newHolder) external whenNotPaused {
        Ticket storage ticket = tickets[ticketId];
        if (ticket.status == Status.None) revert TicketNotFound();
        if (ticket.status != Status.Valid) revert InvalidTicketState();
        if (ticket.holder != msg.sender) revert NotTicketHolder();
        if (newHolder == address(0)) revert InvalidAddress();
        if (newHolder == msg.sender) revert SameHolder();

        address oldHolder = ticket.holder;
        ticket.holder = newHolder;
        emit TicketTransferred(ticketId, oldHolder, newHolder);
    }

    function cancelTicket(uint256 ticketId) external whenNotPaused {
        Ticket storage ticket = tickets[ticketId];
        if (ticket.status == Status.None) revert TicketNotFound();
        if (ticket.status != Status.Valid) revert InvalidTicketState();
        if (eventOrganizer[ticket.eventId] != msg.sender) revert NotTicketHolder();
        ticket.status = Status.Cancelled;
        emit TicketCancelled(ticketId);
    }

    function markUsed(uint256 ticketId) external onlyRole(SCANNER_ROLE) whenNotPaused {
        Ticket storage ticket = tickets[ticketId];
        if (ticket.status == Status.None) revert TicketNotFound();
        if (ticket.status != Status.Valid) revert InvalidTicketState();
        ticket.status = Status.Used;
        emit TicketUsed(ticketId, msg.sender);
    }

    function getStatus(uint256 ticketId)
        external view returns (uint256 eventId, address holder, Status status)
    {
        Ticket memory ticket = tickets[ticketId];
        return (ticket.eventId, ticket.holder, ticket.status);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) { _unpause(); }
}

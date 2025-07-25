// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Solidarity Circles
 * @notice Decentralized mutual aid governance and coordination
 * @dev Implements consent-based decision making for community support
 * @author haaz.eth
 */
contract SolidarityCircles is AccessControl, ReentrancyGuard, Pausable {
    
    // =============================================================
    //                        STRUCTS
    // =============================================================
    
    enum AidRequestStatus { Pending, Approved, Rejected, Fulfilled }
    enum ResponseType { Support, NeedsInfo, Concern, Block }
    
    struct AidRequest {
        address requester;
        uint256 amount;
        bytes32 purpose;
        bytes32 urgency; // High, Medium, Low
        uint256 createdAt;
        uint256 deadline;
        AidRequestStatus status;
        uint256 supportCount;
        uint256 concernCount;
        mapping(address => bool) hasResponded;
        mapping(address => ResponseType) responses;
    }
    
    struct CircleMember {
        bool isActive;
        uint256 joinedAt;
        uint256 contributionScore;
        bytes32 specialties; // healing, organizing, resources, etc.
    }
    
    // =============================================================
    //                        STATE VARIABLES
    // =============================================================
    
    mapping(bytes32 => AidRequest) public aidRequests;
    mapping(address => CircleMember) public members;
    mapping(address => bytes32[]) public memberRequests;
    
    bytes32[] public allRequestIds;
    address[] public activemembers;
    
    uint256 public constant RESPONSE_PERIOD = 7 days;
    uint256 public constant MIN_SUPPORT_THRESHOLD = 3;
    uint256 public constant MAX_CONCERN_THRESHOLD = 2;
    
    bytes32 public constant CIRCLE_KEEPER_ROLE = keccak256("CIRCLE_KEEPER_ROLE");
    
    // =============================================================
    //                        EVENTS
    // =============================================================
    
    event AidRequestCreated(
        bytes32 indexed requestId,
        address indexed requester,
        uint256 amount,
        bytes32 indexed purpose
    );
    
    event ResponseSubmitted(
        bytes32 indexed requestId,
        address indexed responder,
        ResponseType indexed responseType
    );
    
    event RequestApproved(bytes32 indexed requestId, uint256 supportCount);
    event RequestRejected(bytes32 indexed requestId, uint256 concernCount);
    event RequestFulfilled(bytes32 indexed requestId, uint256 amount);
    
    event MemberJoined(address indexed member, bytes32 specialties);
    event MemberActivated(address indexed member);
    
    // =============================================================
    //                        CONSTRUCTOR
    // =============================================================
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CIRCLE_KEEPER_ROLE, msg.sender);
    }
    
    // =============================================================
    //                        MEMBERSHIP FUNCTIONS
    // =============================================================
    
    /**
     * @notice Join the solidarity circle
     * @param specialties Areas of expertise/contribution
     */
    function joinCircle(bytes32 specialties) external {
        require(!members[msg.sender].isActive, "Already a member");
        
        members[msg.sender] = CircleMember({
            isActive: true,
            joinedAt: block.timestamp,
            contributionScore: 0,
            specialties: specialties
        });
        
        activemembers.push(msg.sender);
        emit MemberJoined(msg.sender, specialties);
    }
    
    // =============================================================
    //                        AID REQUEST FUNCTIONS
    // =============================================================
    
    /**
     * @notice Create a mutual aid request
     * @param amount Amount of support needed
     * @param purpose Purpose of the aid request
     * @param urgency Urgency level (High, Medium, Low)
     */
    function createAidRequest(
        uint256 amount,
        bytes32 purpose,
        bytes32 urgency
    ) external returns (bytes32 requestId) {
        require(members[msg.sender].isActive, "Must be circle member");
        require(amount > 0, "Amount must be positive");
        require(purpose != bytes32(0), "Purpose required");
        
        requestId = keccak256(abi.encodePacked(
            msg.sender,
            amount,
            purpose,
            block.timestamp
        ));
        
        AidRequest storage request = aidRequests[requestId];
        request.requester = msg.sender;
        request.amount = amount;
        request.purpose = purpose;
        request.urgency = urgency;
        request.createdAt = block.timestamp;
        request.deadline = block.timestamp + RESPONSE_PERIOD;
        request.status = AidRequestStatus.Pending;
        
        allRequestIds.push(requestId);
        memberRequests[msg.sender].push(requestId);
        
        emit AidRequestCreated(requestId, msg.sender, amount, purpose);
        return requestId;
    }
    
    /**
     * @notice Respond to an aid request
     * @param requestId ID of the request
     * @param responseType Type of response
     */
    function respondToRequest(
        bytes32 requestId,
        ResponseType responseType
    ) external {
        require(members[msg.sender].isActive, "Must be circle member");
        
        AidRequest storage request = aidRequests[requestId];
        require(request.requester != address(0), "Request not found");
        require(request.status == AidRequestStatus.Pending, "Request not pending");
        require(block.timestamp <= request.deadline, "Response period ended");
        require(!request.hasResponded[msg.sender], "Already responded");
        require(request.requester != msg.sender, "Cannot respond to own request");
        
        request.hasResponded[msg.sender] = true;
        request.responses[msg.sender] = responseType;
        
        if (responseType == ResponseType.Support) {
            request.supportCount++;
        } else if (responseType == ResponseType.Concern || responseType == ResponseType.Block) {
            request.concernCount++;
        }
        
        emit ResponseSubmitted(requestId, msg.sender, responseType);
        
        // Check if thresholds are met
        _evaluateRequest(requestId);
    }
    
    /**
     * @notice Evaluate request approval based on responses
     * @param requestId ID of the request to evaluate
     */
    function _evaluateRequest(bytes32 requestId) internal {
        AidRequest storage request = aidRequests[requestId];
        
        // Auto-reject if too many concerns
        if (request.concernCount > MAX_CONCERN_THRESHOLD) {
            request.status = AidRequestStatus.Rejected;
            emit RequestRejected(requestId, request.concernCount);
            return;
        }
        
        // Auto-approve if enough support and deadline passed
        if (request.supportCount >= MIN_SUPPORT_THRESHOLD && 
            block.timestamp > request.deadline) {
            request.status = AidRequestStatus.Approved;
            emit RequestApproved(requestId, request.supportCount);
        }
    }
    
    /**
     * @notice Mark aid request as fulfilled
     * @param requestId ID of the fulfilled request
     */
    function markRequestFulfilled(
        bytes32 requestId
    ) external onlyRole(CIRCLE_KEEPER_ROLE) {
        AidRequest storage request = aidRequests[requestId];
        require(request.status == AidRequestStatus.Approved, "Request not approved");
        
        request.status = AidRequestStatus.Fulfilled;
        
        // Increase contribution scores for supporters
        _updateContributionScores(requestId);
        
        emit RequestFulfilled(requestId, request.amount);
    }
    
    /**
     * @notice Update contribution scores for supporters
     * @param requestId ID of the request
     */
    function _updateContributionScores(bytes32 requestId) internal {
        AidRequest storage request = aidRequests[requestId];
        
        for (uint i = 0; i < activemembers.length; i++) {
            address member = activemembers[i];
            if (request.hasResponded[member] && 
                request.responses[member] == ResponseType.Support) {
                members[member].contributionScore += 1;
            }
        }
    }
    
    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================
    
    /**
     * @notice Get aid request details
     * @param requestId ID of the request
     */
    function getAidRequest(bytes32 requestId) external view returns (
        address requester,
        uint256 amount,
        bytes32 purpose,
        bytes32 urgency,
        uint256 createdAt,
        uint256 deadline,
        AidRequestStatus status,
        uint256 supportCount,
        uint256 concernCount
    ) {
        AidRequest storage request = aidRequests[requestId];
        return (
            request.requester,
            request.amount,
            request.purpose,
            request.urgency,
            request.createdAt,
            request.deadline,
            request.status,
            request.supportCount,
            request.concernCount
        );
    }
    
    /**
     * @notice Get member's response to a request
     * @param requestId ID of the request
     * @param member Address of the member
     */
    function getMemberResponse(
        bytes32 requestId, 
        address member
    ) external view returns (bool hasResponded, ResponseType response) {
        AidRequest storage request = aidRequests[requestId];
        return (request.hasResponded[member], request.responses[member]);
    }
    
    /**
     * @notice Get all request IDs
     */
    function getAllRequestIds() external view returns (bytes32[] memory) {
        return allRequestIds;
    }
    
    /**
     * @notice Get active member count
     */
    function getActiveMemberCount() external view returns (uint256) {
        return activemembers.length;
    }
    
    // =============================================================
    //                        ADMIN FUNCTIONS
    // =============================================================
    
    /**
     * @notice Pause contract
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }
    
    /**
     * @notice Unpause contract
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
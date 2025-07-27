// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Streaming Hub
 * @notice Real-time payment streaming for community funding
 * @dev Simplified streaming without Superfluid dependencies
 * @author Community DeFi Protocol
 */
contract StreamingHub is AccessControl, ReentrancyGuard, Pausable {
    
    // =============================================================
    //                        STRUCTS
    // =============================================================
    
    struct Stream {
        address sender;
        address recipient;
        address token;
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        uint256 withdrawn;
        bool active;
    }
    
    // =============================================================
    //                        STATE VARIABLES
    // =============================================================
    
    mapping(bytes32 => Stream) public streams;
    mapping(address => bytes32[]) public userStreams;
    
    bytes32[] public allStreamIds;
    
    bytes32 public constant STREAM_MANAGER_ROLE = keccak256("STREAM_MANAGER_ROLE");
    
    // =============================================================
    //                        EVENTS
    // =============================================================
    
    event StreamCreated(
        bytes32 indexed streamId,
        address indexed sender,
        address indexed recipient,
        address token,
        uint256 amount,
        uint256 duration
    );
    
    event StreamWithdrawn(
        bytes32 indexed streamId,
        address indexed recipient,
        uint256 amount
    );
    
    event StreamCancelled(bytes32 indexed streamId);
    
    // =============================================================
    //                        CONSTRUCTOR
    // =============================================================
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(STREAM_MANAGER_ROLE, msg.sender);
    }
    
    // =============================================================
    //                        STREAMING FUNCTIONS
    // =============================================================
    
    /**
     * @notice Create a new payment stream
     * @param recipient Address to receive the stream
     * @param token Token address to stream
     * @param amount Total amount to stream
     * @param duration Duration of the stream in seconds
     */
    function createStream(
        address recipient,
        address token,
        uint256 amount,
        uint256 duration
    ) external nonReentrant returns (bytes32 streamId) {
        require(recipient != address(0), "Invalid recipient");
        require(token != address(0), "Invalid token");
        require(amount > 0, "Amount must be positive");
        require(duration > 0, "Duration must be positive");
        require(recipient != msg.sender, "Cannot stream to self");
        
        // Transfer tokens to contract
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        streamId = keccak256(abi.encodePacked(
            msg.sender,
            recipient,
            token,
            amount,
            block.timestamp
        ));
        
        streams[streamId] = Stream({
            sender: msg.sender,
            recipient: recipient,
            token: token,
            amount: amount,
            startTime: block.timestamp,
            duration: duration,
            withdrawn: 0,
            active: true
        });
        
        allStreamIds.push(streamId);
        userStreams[msg.sender].push(streamId);
        userStreams[recipient].push(streamId);
        
        emit StreamCreated(streamId, msg.sender, recipient, token, amount, duration);
        return streamId;
    }
    
    /**
     * @notice Withdraw available streamed tokens
     * @param streamId ID of the stream
     */
    function withdrawFromStream(bytes32 streamId) external nonReentrant {
        Stream storage stream = streams[streamId];
        require(stream.recipient == msg.sender, "Not stream recipient");
        require(stream.active, "Stream not active");
        
        uint256 available = getAvailableBalance(streamId);
        require(available > 0, "No tokens available");
        
        stream.withdrawn += available;
        
        // End stream if fully withdrawn
        if (stream.withdrawn >= stream.amount) {
            stream.active = false;
        }
        
        IERC20(stream.token).transfer(msg.sender, available);
        
        emit StreamWithdrawn(streamId, msg.sender, available);
    }
    
    /**
     * @notice Cancel an active stream
     * @param streamId ID of the stream to cancel
     */
    function cancelStream(bytes32 streamId) external nonReentrant {
        Stream storage stream = streams[streamId];
        require(stream.sender == msg.sender, "Not stream sender");
        require(stream.active, "Stream not active");
        
        uint256 available = getAvailableBalance(streamId);
        uint256 remaining = stream.amount - stream.withdrawn - available;
        
        stream.active = false;
        stream.withdrawn = stream.amount - remaining;
        
        // Send available to recipient
        if (available > 0) {
            IERC20(stream.token).transfer(stream.recipient, available);
        }
        
        // Return remaining to sender
        if (remaining > 0) {
            IERC20(stream.token).transfer(stream.sender, remaining);
        }
        
        emit StreamCancelled(streamId);
    }
    
    // =============================================================
    //                        BATCH OPERATIONS
    // =============================================================
    
    /**
     * @notice Create multiple streams for developer grants
     * @param recipients Array of recipient addresses
     * @param token Token address to stream
     * @param monthlyAmount Amount per month for each recipient
     * @param months Duration in months
     */
    function startDeveloperGrantsBatch(
        address[] calldata recipients,
        address token,
        uint256 monthlyAmount,
        uint256 months
    ) external onlyRole(STREAM_MANAGER_ROLE) {
        require(recipients.length > 0, "No recipients");
        require(recipients.length <= 50, "Too many recipients");
        
        uint256 duration = months * 30 days;
        uint256 totalAmount = monthlyAmount * months;
        
        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            
            // Transfer tokens for this stream
            IERC20(token).transferFrom(msg.sender, address(this), totalAmount);
            
            bytes32 streamId = keccak256(abi.encodePacked(
                msg.sender,
                recipients[i],
                token,
                totalAmount,
                block.timestamp,
                i
            ));
            
            streams[streamId] = Stream({
                sender: msg.sender,
                recipient: recipients[i],
                token: token,
                amount: totalAmount,
                startTime: block.timestamp,
                duration: duration,
                withdrawn: 0,
                active: true
            });
            
            allStreamIds.push(streamId);
            userStreams[msg.sender].push(streamId);
            userStreams[recipients[i]].push(streamId);
            
            emit StreamCreated(streamId, msg.sender, recipients[i], token, totalAmount, duration);
        }
    }
    
    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================
    
    /**
     * @notice Get available balance for a stream
     * @param streamId ID of the stream
     */
    function getAvailableBalance(bytes32 streamId) public view returns (uint256) {
        Stream storage stream = streams[streamId];
        if (!stream.active) return 0;
        
        uint256 elapsed = block.timestamp - stream.startTime;
        if (elapsed >= stream.duration) {
            return stream.amount - stream.withdrawn;
        }
        
        uint256 streamed = (stream.amount * elapsed) / stream.duration;
        return streamed - stream.withdrawn;
    }
    
    /**
     * @notice Get stream details
     * @param streamId ID of the stream
     */
    function getStream(bytes32 streamId) external view returns (
        address sender,
        address recipient,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 duration,
        uint256 withdrawn,
        bool active
    ) {
        Stream storage stream = streams[streamId];
        return (
            stream.sender,
            stream.recipient,
            stream.token,
            stream.amount,
            stream.startTime,
            stream.duration,
            stream.withdrawn,
            stream.active
        );
    }
    
    /**
     * @notice Get user's stream IDs
     * @param user Address of the user
     */
    function getUserStreams(address user) external view returns (bytes32[] memory) {
        return userStreams[user];
    }
    
    /**
     * @notice Get total number of streams
     */
    function getTotalStreams() external view returns (uint256) {
        return allStreamIds.length;
    }
    
    // =============================================================
    //                        ADMIN FUNCTIONS
    // =============================================================
    
    /**
     * @notice Emergency withdraw tokens
     * @param token Token address
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(
        address token,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(token).transfer(msg.sender, amount);
    }
    
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
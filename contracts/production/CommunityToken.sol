// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Community Token
 * @notice ERC-20 token for recognizing spiritual labor and coordinating mutual aid
 * @dev Implements community features with security best practices
 * @author Community DeFi Protocol
 * @custom:version 1.0
 */
contract CommunityToken is ERC20, AccessControl, ReentrancyGuard, Pausable {
    
    // =============================================================
    //                        ROLES
    // =============================================================
    
    bytes32 public constant SPIRITUAL_TREASURY_ROLE = keccak256("SPIRITUAL_TREASURY_ROLE");
    bytes32 public constant COMMUNITY_ORGANIZER_ROLE = keccak256("COMMUNITY_ORGANIZER_ROLE");
    
    // =============================================================
    //                        STRUCTS
    // =============================================================
    
    struct CommunityProfile {
        uint256 contributionPoints;
        uint256 prayersOffered;
        uint256 prayersReceived;
    }
    
    // =============================================================
    //                        STATE VARIABLES
    // =============================================================
    
    mapping(address => CommunityProfile) public profiles;
    mapping(address => bytes32) public communityRoles;
    mapping(bytes32 => uint256) public ritualOfferings;
    mapping(bytes32 => address) public gatheringOrganizers;
    
    uint256 public totalAncestralOfferings;
    
    // =============================================================
    //                        EVENTS
    // =============================================================
    
    event PrayerOffered(
        address indexed from, 
        address indexed to, 
        uint256 indexed amount, 
        string intention
    );
    
    event SpiritualLabor(
        address indexed contributor, 
        bytes32 indexed workType, 
        uint256 indexed aseEarned
    );
    
    event AncestralOffering(
        address indexed offerer, 
        uint256 indexed amount, 
        bytes32 indexed purpose
    );
    
    // =============================================================
    //                        CONSTRUCTOR
    // =============================================================
    
    constructor() ERC20(unicode"Community Token", unicode"COMM") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPIRITUAL_TREASURY_ROLE, msg.sender);
        _grantRole(COMMUNITY_ORGANIZER_ROLE, msg.sender);
        
        // Mint initial supply
        _mint(msg.sender, 1_000_000 * 10**decimals());
    }
    
    // =============================================================
    //                        SPIRITUAL FUNCTIONS
    // =============================================================
    
    /**
     * @notice Offer prayer with ASÉ to another community member
     * @param recipient Address receiving the prayer offering
     * @param amount Amount of ASÉ to send with prayer
     * @param intention Prayer intention (required for spiritual authenticity)
     */
    function offerPrayer(
        address recipient, 
        uint256 amount, 
        string calldata intention
    ) external nonReentrant whenNotPaused {
        require(recipient != address(0), "Invalid recipient");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(bytes(intention).length > 0, "Prayer intention required");
        
        profiles[msg.sender].prayersOffered++;
        profiles[recipient].prayersReceived++;
        
        _transfer(msg.sender, recipient, amount);
        emit PrayerOffered(msg.sender, recipient, amount, intention);
    }
    
    /**
     * @notice Recognize spiritual labor and mint new ASÉ
     * @param contributor Address of the spiritual worker
     * @param workType Type of spiritual work
     * @param aseAmount Amount of ASÉ to mint
     */
    function recognizeSpiritualLabor(
        address contributor,
        bytes32 workType,
        uint256 aseAmount
    ) external onlyRole(SPIRITUAL_TREASURY_ROLE) whenNotPaused {
        require(contributor != address(0), "Invalid contributor");
        require(workType != bytes32(0), "Work type required");
        
        profiles[contributor].contributionPoints += aseAmount;
        _mint(contributor, aseAmount);
        
        emit SpiritualLabor(contributor, workType, aseAmount);
    }
    
    /**
     * @notice Burn ASÉ for ancestral offerings
     * @param amount Amount to burn
     * @param purpose Purpose of the offering
     */
    function burnForAncestors(
        uint256 amount, 
        bytes32 purpose
    ) external nonReentrant whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(purpose != bytes32(0), "Purpose required");
        
        totalAncestralOfferings += amount;
        _burn(msg.sender, amount);
        
        emit AncestralOffering(msg.sender, amount, purpose);
    }
    
    // =============================================================
    //                        COMMUNITY FUNCTIONS
    // =============================================================
    
    /**
     * @notice Organize a community gathering
     * @param gatheringId Unique identifier for the gathering
     * @param location Location of gathering
     */
    function organizeGathering(
        bytes32 gatheringId, 
        bytes32 location
    ) external whenNotPaused {
        require(profiles[msg.sender].contributionPoints >= 100, "Insufficient contributions");
        require(gatheringOrganizers[gatheringId] == address(0), "Gathering already exists");
        
        gatheringOrganizers[gatheringId] = msg.sender;
    }
    
    /**
     * @notice Contribute to a ritual
     * @param ritualId Ritual identifier
     * @param amount Amount to contribute
     */
    function contributeToRitual(
        bytes32 ritualId, 
        uint256 amount
    ) external nonReentrant whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        ritualOfferings[ritualId] += amount;
        _transfer(msg.sender, address(this), amount);
    }
    
    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================
    
    /**
     * @notice Get user's complete community profile
     * @param user Address to query
     */
    function getUserProfile(address user) external view returns (
        uint256 balance,
        uint256 contributions,
        string memory level,
        bytes32 role,
        uint256 prayersOffered,
        uint256 prayersReceived
    ) {
        CommunityProfile memory profile = profiles[user];
        return (
            balanceOf(user),
            profile.contributionPoints,
            getContributionLevel(user),
            communityRoles[user],
            profile.prayersOffered,
            profile.prayersReceived
        );
    }
    
    /**
     * @notice Get contribution level based on points
     * @param member Address to check
     */
    function getContributionLevel(address member) public view returns (string memory) {
        uint256 points = profiles[member].contributionPoints;
        
        if (points >= 10000) return "Elder/Ancestral Wisdom Keeper";
        if (points >= 5000) return "Community Healer";
        if (points >= 1000) return "Ritual Facilitator";
        if (points >= 100) return "Circle Holder";
        return "Community Member";
    }
    
    // =============================================================
    //                        ADMIN FUNCTIONS
    // =============================================================
    
    /**
     * @notice Set community role for a member
     * @param member Address of community member
     * @param role Role to assign
     */
    function setCommunityRole(
        address member, 
        bytes32 role
    ) external onlyRole(SPIRITUAL_TREASURY_ROLE) {
        require(member != address(0), "Invalid member");
        communityRoles[member] = role;
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
    
    // =============================================================
    //                        OVERRIDES
    // =============================================================
    
    /**
     * @notice Enhanced transfer override with pause functionality
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override whenNotPaused {
        super._update(from, to, value);
    }
    
    /**
     * @notice Support interface for access control
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
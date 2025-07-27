# Protocol Architecture

## Contract Overview

### Production Contracts

#### CommunityToken.sol
- **Purpose**: Core ERC-20 with spiritual labor recognition
- **Key Features**: Prayer offerings, contribution tracking, deflationary burns
- **Security**: OpenZeppelin AccessControl, ReentrancyGuard, Pausable

#### MutualAidGovernance.sol  
- **Purpose**: Decentralized mutual aid coordination
- **Key Features**: Aid requests, consent-based voting, automatic approval
- **Innovation**: First blockchain mutual aid governance system

#### StreamingHub.sol
- **Purpose**: Real-time payment streaming
- **Key Features**: Individual streams, batch operations, withdrawable balance
- **Use Cases**: Grant distribution, continuous funding

### Foundation Contracts

#### HelloWorld.sol
- **Purpose**: Educational multilingual contract
- **Cultural Value**: Preserves Taíno, Spanish, English languages
- **Learning**: Demonstrates basic Solidity patterns

#### CulturalExpression.sol
- **Purpose**: On-chain cultural preservation
- **Content**: Puerto Rican resistance flag ASCII art
- **Significance**: Immutable cultural and political expression

## Multi-Chain Strategy

### Network Selection
- **Ethereum**: Mainnet credibility, institutional access
- **Optimism**: L2 efficiency, Superfluid compatibility  
- **Base**: Coinbase ecosystem, user onboarding
- **Celo**: Mobile-first, global south focus

### Cross-Chain Considerations
- Consistent contract interfaces across networks
- Network-specific optimizations
- Unified frontend experience
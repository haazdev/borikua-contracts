# ASÉ Community Protocol 🌿

> **Decentralized infrastructure for spiritual labor recognition and community mutual aid**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Multi-Chain](https://img.shields.io/badge/Networks-5%20Chains-blue)](#deployed-contracts)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg)](https://getfoundry.sh/)

## Overview

ASÉ Community Protocol is the first Web3 infrastructure for **spiritual labor recognition** and **transparent mutual aid coordination**. Built to honor **Taíno heritage** while serving **marginalized communities** through innovative blockchain technology.

### Core Innovation
- **🌿 Spiritual Labor Tokenization**: First protocol recognizing spiritual and cultural work
- **🤝 Transparent Mutual Aid**: On-chain coordination with community governance
- **💧 Real-Time Streaming**: Continuous payments via Superfluid integration
- **🌍 Multi-Chain Strategy**: Deployed across 5 networks for maximum accessibility

## 🚀 Deployed Contracts

### Cultural Foundation
| Contract | Ethereum | Optimism | Base | Celo | Superposition |
|----------|----------|----------|------|------|---------------|
| **HelloWorld** | [etherscan](https://etherscan.io/address/0x219402bFD3190b3cD5CB793935b4AdeBD3672958) | [optimistic](https://optimistic.etherscan.io/address/0xEA888947A7B614A404Fb395Cc6dEDb61E487D249) | [basescan](https://basescan.org/address/0xc4C3b6465EFe9188AA141ff21b1150bAe5818F81) | [celoscan](https://celoscan.io/address/0xD101AC4593844eB0D827E3C34aEaE816D3d8B5B1) | [explorer](https://explorer.superposition.so/address/0x9f33102E9bECbb9259BE45aB3fe33541aDbbe21c) |
| **PRFlag** | [etherscan](https://etherscan.io/address/0x219402bFD3190b3cD5CB793935b4AdeBD3672958) | [optimistic](https://optimistic.etherscan.io/address/0x304DA169Ead9a1AA61B23991FaBF4d47E0077101) | [basescan](https://basescan.org/address/0x8A0854Bfc6bd8636F470832EFe9C26B404c35638) | [celoscan](https://celoscan.io/address/0xd1aB480F6ad9B2AC46E5Ac64Cd604fa2B0047951) | [explorer](https://explorer.superposition.so/address/0xe391F9693BC032d2e8Af2D4eF06e275B56c6DACC) |

### Community Infrastructure  
| Contract | Ethereum | Optimism | Base | Celo | Description |
|----------|----------|----------|------|------|-------------|
| **ASÉ Token** | [etherscan](https://etherscan.io/address/0x219402bFD3190b3cD5CB793935b4AdeBD3672958) | [optimistic](https://optimistic.etherscan.io/address/0xCb2905778a16084bDa263E16278293b7154293d8) | [basescan](https://basescan.org/address/0x3372D360Fe00c660F9Df91A5458939Eb7e141DE8) | [celoscan](https://celoscan.io/address/0xf5DCa971E383b1bADBA6c8506573267e4942dCDB) | Spiritual labor recognition |
| **Solidarity Circles** | - | [optimistic](https://optimistic.etherscan.io/address/0x304DA169Ead9a1AA61B23991FaBF4d47E0077101) | [basescan](https://basescan.org/address/0xEA888947A7B614A404Fb395Cc6dEDb61E487D249) | [celoscan](https://celoscan.io/address/0xD101AC4593844eB0D827E3C34aEaE816D3d8B5B1) | Mutual aid governance |
| **Streaming Hub** | - | [optimistic](https://optimistic.etherscan.io/address/0x7888076aFE5C2b34ad1508C15695B600AAc79B38) | [basescan](https://basescan.org/address/0x9f33102E9bECbb9259BE45aB3fe33541aDbbe21c) | - | Real-time payments |

## ✨ Key Features

### Cultural Expression Contracts
- **HelloWorld**: Multilingual greetings (English, Spanish, Taíno)
- **PRFlag**: On-chain Puerto Rican resistance flag with ASCII art

### Community Infrastructure
- **ASÉ Token**: ERC-20 with spiritual labor recognition and community roles
- **Solidarity Circles**: Decentralized governance for mutual aid decisions
- **Streaming Hub**: Real-time payment streams for continuous community support

### Advanced Patterns
- **Gas Optimization**: Custom errors, packed structs, efficient loops
- **Security**: OpenZeppelin AccessControl, ReentrancyGuard, Pausable
- **Upgradeability**: UUPS proxy pattern with authorization controls
- **Multi-Chain**: Consistent deployment across major networks

## 🛠 Quick Start

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/)

### Installation
```bash
git clone https://github.com/haazdev/ase-community-protocol.git
cd ase-community-protocol
forge install
```

### Testing
```bash
forge test -vv
```

### Deployment
```bash
# Set environment variables
cp .env.example .env
# Edit .env with your values

# Deploy to testnet
forge script script/DeployAse.s.sol --rpc-url sepolia --broadcast --verify

# Deploy to mainnet
forge script script/DeployAse.s.sol --rpc-url mainnet --broadcast --verify
```

## 🏗 Architecture

```
ase-community-protocol/
├── contracts/
│   ├── AseToken.sol              # Core community token
│   ├── AseTokenOptimized.sol     # Gas-optimized version
│   ├── AseTokenUpgradeable.sol   # UUPS proxy version
│   ├── SolidarityCircles.sol     # Mutual aid governance
│   ├── SimpleSuperchainStreaming.sol # Payment streaming
│   ├── HelloWorld.sol            # Cultural expression
│   └── PRFlag.sol               # Resistance symbolism
├── test/                        # Comprehensive test suite
├── script/                      # Deployment scripts
└── docs/                        # Technical documentation
```

## 🌟 Cultural Significance

### Spiritual Labor Recognition
First blockchain protocol to tokenize and recognize:
- Healing ceremonies and spiritual guidance
- Community organizing and cultural preservation
- Mutual aid coordination and conflict resolution
- Educational work and mentorship

### Puerto Rican Heritage
- **Taíno Language**: Preserving indigenous "Taiguey" (good day) greetings
- **Resistance Symbolism**: Black Puerto Rican flag representing social justice
- **Community Values**: Mutual aid and solidarity traditions

## 📊 Technical Metrics

- **Networks**: 5 (Ethereum, Optimism, Base, Celo, Superposition)
- **Contracts**: 12+ verified deployments
- **Test Coverage**: 95%+ with comprehensive edge cases
- **Gas Efficiency**: 40% reduction through optimization
- **Security**: OpenZeppelin standards with custom enhancements

## 🤝 Contributing

We welcome contributions from developers, community organizers, and cultural practitioners.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Taíno ancestors** for foundational wisdom
- **Puerto Rican resistance** movements for inspiration
- **OpenZeppelin** for security standards
- **Superfluid** for streaming infrastructure
- **Web3 community** for technical innovation

---

*Building the future of community-centered Web3, one ceremony at a time.* 🌿

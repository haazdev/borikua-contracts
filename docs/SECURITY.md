# Security Guidelines

## Environment Variables

**CRITICAL:** Never commit real private keys or API keys to the repository.

### Safe Practices:
- Use `.env.example` as a template
- Keep real values in `.env` (gitignored)
- Use environment variables in production
- Rotate keys regularly

### What NOT to commit:
- Private keys
- Mnemonics
- API keys
- RPC URLs with embedded tokens
- Deployment logs with addresses linked to your identity

## Smart Contract Security

### Access Control
- All contracts use proper owner/admin patterns
- Functions with state changes are properly protected
- Events are emitted for important state changes

### Best Practices Applied:
- Use of `require()` for input validation
- Proper event emission
- Gas-efficient string handling with `unicode` strings
- No external dependencies beyond OpenZeppelin-style patterns

## Deployment Security

### Before Deployment:
1. Test thoroughly on testnets
2. Verify contract source code
3. Use hardware wallets for mainnet deployments
4. Double-check deployment parameters

### After Deployment:
1. Verify contracts on block explorers
2. Test basic functionality
3. Monitor for unusual activity
4. Keep deployment records secure

## Repository Security

### Files to Never Commit:
- `.env` files with real values
- `broadcast/` folders with real transaction data
- Private keys in any format
- API keys or secrets

### Safe to Commit:
- Contract source code
- Test files
- Deployment scripts (without real keys)
- Documentation
- `.env.example` templates

## Incident Response

If sensitive information is accidentally committed:

1. **Immediately** rotate all exposed keys
2. Remove sensitive commits from git history
3. Create new accounts/keys if necessary
4. Review all recent transactions
5. Update security practices

## Contact

For security issues, please contact the maintainers privately before public disclosure.
EOF < /dev/null
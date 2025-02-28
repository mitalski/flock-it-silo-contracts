.PHONY: debug test clean build

# Default test command with detailed output
debug:
	RPC_ARBITRUM=https://arb1.arbitrum.io/rpc forge test -vvv --match-test testBorrowExecution

# Run all tests
test:
	RPC_ARBITRUM=https://arb1.arbitrum.io/rpc forge test

# Clean build artifacts
clean:
	forge clean

# Build contracts
build:
	forge build

# Run all tests with gas reporting
gas:
	forge test --gas-report

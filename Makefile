build:; forge build
deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url https://eth-sepolia.g.alchemy.com/v2/u6b6m9-EJHsjaiXK5ZsFPPnfk0UpVxP1 --account defaultKey --broadcast --verify --etherscan-api-key 2E9WKFS8X77S5ZQ7G73IR5BJ8IXR7N98S5 -vvvv
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* 
1. Deploy mocks when we are on the Anvil local chain
2. Keep track of contract addresses accross different chains (Sepolia, Mainnet, etc)
*/

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint256 constant ANVIL_CHAINID = 31337;
    uint8 constant MOCKPRICEFEED_DECIMALS = 8;
    int256 constant MOCKPRICEFEED_INITIAL_ANSWER = 2000e8;

    struct NetworkConfig {
        string name;
        address priceFeed;
    }
    mapping(uint256 => NetworkConfig) internal chainIdToNetworkConfig;
    NetworkConfig public currentNetwork;

    constructor() {
        currentNetwork = getNetworkConfig();
    }

    function setChainIdToNetworkConfig() internal {
        chainIdToNetworkConfig[11155111] = NetworkConfig({
            name: "Sepolia",
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        chainIdToNetworkConfig[1] = NetworkConfig({
            name: "Mainnet",
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
    }

    function setAnvilNetworkConfig() internal returns (NetworkConfig memory) {
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            MOCKPRICEFEED_DECIMALS,
            MOCKPRICEFEED_INITIAL_ANSWER
        );
        vm.stopBroadcast();

        return
            NetworkConfig({name: "Anvil", priceFeed: address(mockPriceFeed)});
    }

    function getNetworkConfig() public returns (NetworkConfig memory) {
        if (block.chainid == ANVIL_CHAINID) {
            return setAnvilNetworkConfig();
        } else {
            setChainIdToNetworkConfig();
            return chainIdToNetworkConfig[block.chainid];
        }
    }
}

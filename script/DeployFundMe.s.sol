// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() public returns (FundMe) {
        // Before startBroadcast, contract inits are not considered as transactions
        HelperConfig helperConfig = new HelperConfig();
        (, address ethUsdPriceFeed) = helperConfig.currentNetwork();

        vm.startBroadcast();
        // After startBroadcast, all is transactions!
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        /*console.log("DeployFundMe FundMe contract at %s", address(fundMe));
        console.log("ethUsdPriceFeed %s", ethUsdPriceFeed);*/

        return fundMe;
    }
}

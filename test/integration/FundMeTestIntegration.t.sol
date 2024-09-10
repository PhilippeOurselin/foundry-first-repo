// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    uint256 private constant INITIAL_BALANCE = 1 ether;
    uint256 private constant SEND_AMOUNT = 0.01 ether;
    address private immutable i_user = makeAddr("User");
    FundMe internal fundMe;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(i_user, INITIAL_BALANCE);
    }

    function testUserCanFundInteractions() public {
        uint256 preUserBalance = i_user.balance;
        uint256 preOwnerBalance = fundMe.getOwner().balance;

        vm.prank(i_user);
        fundMe.fund{value: SEND_AMOUNT}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 postUserBalance = i_user.balance;
        uint256 postOwnerBalance = fundMe.getOwner().balance;

        assert(address(fundMe).balance == 0);
        assertEq(postUserBalance + SEND_AMOUNT, preUserBalance);
        assertEq(preOwnerBalance + SEND_AMOUNT, postOwnerBalance);
    }
}

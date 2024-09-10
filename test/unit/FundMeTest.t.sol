// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test, DeployFundMe {
    uint256 constant INITIAL_BALANCE = 1 ether;
    uint256 constant SEND_AMOUNT = 0.1 ether; // = 10e18
    address immutable i_user = makeAddr("User"); // Fake user (cf. "prank" Foundry cheatcode)

    FundMe internal fundMe;

    function setUp() external {
        // This function is called before each test function. It is used to set up the state of the contract before each test
        // We need to create a mock contract for priceFeed, to be able to test locally
        fundMe = run(); // Sepolia ETH/USD address
        vm.deal(i_user, INITIAL_BALANCE); // i_user balance must be other than 0ETH!
    }

    function testMinimumUSDIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    modifier funds() {
        vm.prank(i_user);
        fundMe.fund{value: SEND_AMOUNT}();
        _;
    }

    function testUserFunding() public funds {
        assertEq(fundMe.getAddressToAmountFunded(i_user), SEND_AMOUNT);
    }

    function testFundFailsWithoutEnoughEth() public funds {
        vm.expectRevert(); // = the next line should revert!
        fundMe.fund();
    }

    function testAddsFunderToArrayOfFunders() public funds {
        assertEq(fundMe.getFunder(0), i_user); // Index 0 because run() is called before each test, so everything is reinitialized
    }

    function testFundUpdatesFundedDataStructure() public funds {
        assertEq(fundMe.getAddressToAmountFunded(i_user), SEND_AMOUNT);
    }

    function testWithdrawFailsIfNotOwner() public funds {
        vm.prank(i_user); // Real owner is msg.sender
        vm.expectRevert();
        fundMe.withdraw();
    }

    modifier withdraws() {
        // 1. Arrange
        _;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // 2. Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // 3. Assert
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
        assert(address(fundMe).balance == 0);
        vm.expectRevert();
        fundMe.getFunder(0); // The Funders array should have been reinitialized
    }

    function testWithdrawWithASingleFunder() public funds withdraws {} // All is already done by "withdraws" modifier :)

    function testWithDrawWithMultipleFunders() public funds withdraws {
        // We use "uint160" to be able to cast a number into an address: address(uint160),
        // because addresses have 160 bytes.
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // Not 0 because address(0) can make the call revert
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), INITIAL_BALANCE);
            fundMe.fund{value: SEND_AMOUNT}();
        }
    }
}

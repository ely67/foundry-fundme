
// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.18;

// import {Test, console} from "forge-std/Test.sol";
// import {FundMe} from "../src/FundMe.sol";
// import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// contract FundMeTest is Test {
//     FundMe fundMe;

//     address USER = makeAddr("user");
//     uint256 constant SEND_VALUE = 0.1 ether;
//     uint256 constant STARTING_BALANCE = 10 ether;

//     function setUp() external {
//         //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
//         DeployFundMe deployFundMe = new DeployFundMe();
//         fundMe = deployFundMe.run();
//         vm.deal(USER, STARTING_BALANCE);
//     }

//     function testMinimumDollorIsFive() public {
//         assertEq(fundMe.MINIMUM_USD(), 5e18);
//     }

//     function testOwnerIsMsgSender() public {
//         // when we deploy it with this contract:
//         // assertEq(fundMe.i_owner(),address(this))
//         assertEq(fundMe.i_owner(),msg.sender);
//     }
    
//     function testPriceFeedVersionIsAccurate() public {
//         uint256 version = fundMe.getVersion();
//         console.log(version);
//         assertEq(version,4);
//     }

//     function testFundFailWithoutEnoughEth() public {
//         vm.expectRevert();
//         fundMe.fund();
//     }

//     function testFundUpdatesFundedDataStructured() public {
//         vm.prank(USER);
//         fundMe.fund{value: SEND_VALUE}();

//         uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
//         assertEq(amountFunded,SEND_VALUE);
//         console.log(amountFunded);
//     }

//     function testAddsFundersToArrayOfFunders() public {
//         vm.prank(USER);
//         fundMe.fund{value: SEND_VALUE}();

//         address funder = fundMe.getFunder(0);
//         assertEq(funder, USER);
//     }

//     modifier funded() {
//         vm.prank(USER);
//         fundMe.fund{value: SEND_VALUE};
//         _;
//     }

//     function testOnlyOwnerCanWithdraw() public funded {
//         vm.expectRevert();
//         vm.prank(USER);
//         fundMe.withdraw();
//     }

//     function testWithdrawWithSingleFunder() public funded {
//         // Arrrange
//         uint256 startingOwnerBalance = fundMe.getOwner().balance;
//         uint256 startinFundMeBalance = address(fundMe).balance;

//         // Act
//         vm.prank(fundMe.getOwner());
//         fundMe.withdraw();

//         // Assert
//         uint256 endingOwnerBalance = fundMe.getOwner().balance;
//         uint256 endingFundMeBalance = address(fundMe).balance;
//         assertEq(endingFundMeBalance, 0);
//         assertEq(startingOwnerBalance + startinFundMeBalance,
//                  endingOwnerBalance);
//     }

//     function testWithdrawFromMultpleFunders() public funded {
//         // Arrange
//         uint160 numberOfFunders = 10;
//         uint160 startingFunderIndex = 1;
//         for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
//             hoax(address(i), STARTING_BALANCE);
//             fundMe.fund{value: SEND_VALUE}();
//         }
        
//         uint256 startingOwnerBalance = fundMe.getOwner().balance;
//         uint256 startingFundMeBalance = address(fundMe).balance;
//         // Act
//         vm.startPrank(fundMe.getOwner());
//         fundMe.withdraw();
//         vm.stopPrank();

//         // Assert
//         assert(address(fundMe).balance == 0);
//         assert(startingFundMeBalance + startingOwnerBalance ==
//                fundMe.getOwner().balance);
//     }
// }



pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    //HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    // uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    // uint256 public constant SEND_VALUE = 1e18;
    // uint256 public constant SEND_VALUE = 1_000_000_000_000_000_000;
    // uint256 public constant SEND_VALUE = 1000000000000000000;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    // function testPriceFeedSetCorrectly() public {
    //     address retreivedPriceFeed = address(fundMe.getPriceFeed());
    //     // (address expectedPriceFeed) = helperConfig.activeNetworkConfig();
    //     address expectedPriceFeed = helperConfig.activeNetworkConfig();
    //     assertEq(retreivedPriceFeed, expectedPriceFeed);
    // }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    // https://twitter.com/PaulRBerg/status/1624763320539525121

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft();
        // // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    // Can we do our withdraw function a cheaper way?
    function testWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }

    function testWithDrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }
}
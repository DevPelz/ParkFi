// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import "../src/ParkFi.sol";
// import "../src/MembershipNft.sol";

// import "../src/ParkingSpaceNft.sol";
// import "../src/ParkTokenMain.sol";

// contract ParkFiTest is Test {
//         address me = 0x764693DD666E8dD9275CDE8F05C6B07446B1d941;
//         ParkTokenMain PT;
//         ParkingSpaceNFT PSN;
//         MembershipNft MemNFT;

//     function setUp() public {

//     vm.createSelectFork("https://eth-sepolia.g.alchemy.com/v2/skrUWPC9wHXkpfp71ygZ54huCihagnHl");
//        PT = new ParkTokenMain(me);
//        PSN = new ParkingSpaceNFT("demo");
//        emNFT = new MembershipNft("demo");
//     }

//     function test_Increment() public {
//         counter.increment();
//         assertEq(counter.number(), 1);
//     }

//     function testFuzz_SetNumber(uint256 x) public {
//         counter.setNumber(x);
//         assertEq(counter.number(), x);
//     }
// }

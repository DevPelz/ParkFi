// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ParkFi.sol";
import "../src/MembershipNft.sol";
import "../src/ParkToken.sol";
import "../src/ParkSpaceNft.sol";


contract DeployScript is Script {

//     [18/06/2024, 16:2 WeParkMembershipNFT "0x0d2e002D36d80f0A991431708150D4cB7A0bb3ad"
// [18/06/2024, 16:26:02] jaydhales: ParkSpaceNFT "0x3d2b7532042340285084f92db4626aF28Ae42af3"
// [18/06/2024, 16:26:20] jaydhales: ParkToken "0xE66e3132632df70273501C4254831eb755A88CDb
    function run() public {
        vm.startBroadcast();
        address me = 0x764693DD666E8dD9275CDE8F05C6B07446B1d941;
        // ParkToken PT = new ParkToken(me);
        // ParkSpaceNFT PSN = new ParkSpaceNFT();
        // WeParkMembershipNFT MemNFT = new WeParkMembershipNFT();

        // Main point of entry
        ParkFi pf = new ParkFi(address(0xE66e3132632df70273501C4254831eb755A88CDb), address(0x3d2b7532042340285084f92db4626aF28Ae42af3), address(0x0d2e002D36d80f0A991431708150D4cB7A0bb3ad));
    }
}
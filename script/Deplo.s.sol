// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ParkFi.sol";
import "../src/MembershipNft.sol";

import "../src/ParkingSpaceNft.sol";
import "../src/ParkTokenMain.sol";


contract DeployScript is Script {

    function run() public {
        vm.startBroadcast();
        address me = 0x764693DD666E8dD9275CDE8F05C6B07446B1d941;

        MembershipNft MemNFT =  MembershipNft(0xe37e44964Dad319C6b31D222453b7DDd3b249721);
        ParkingSpaceNFT PSN =  ParkingSpaceNFT(0x6Ec5929e48aD78838155FC8D3C6ed4E3c5BAc111);
        ParkTokenMain PT =  ParkTokenMain(0xD8ed4a9317585BD8Ce8eF7524C313F25373D1739);

        // console2.log("MembershiptNft:", address(MemNFT));
        // console2.log("PakingSpaceNFT:", address(PSN));
        // console2.log("ParkingToken:", address(PT));
       

        // // Main point of entry
        ParkFi pf =   ParkFi(0x1f6EEC72dcA1ccd968aba326492EAAB09bF8C14c);
        // console2.log("ParkFi:", address(pf));

        PT.transfer(0x0489DB67c9B49C1C813da3C538103926f31BE572, 1000 ether);

        // MemNFT.setParkFiAddress(address(pf));
        // PSN.setParkFiAddress(address(pf));

        // pf.verifyAndMintParkingSpace(1 ether, 4 ether);
        // pf.verifyAndMintParkingSpace(1 ether, 5 ether);
        // pf.verifyAndMintParkingSpace(2 ether, 7 ether);
        // pf.verifyAndMintParkingSpace(3 ether, 9 ether);
        // pf.verifyAndMintParkingSpace(4 ether, 12 ether);
            
        // pf.verifyAndMintMembership();

        // PT.approve(address(pf), type(uint256).max);

        // pf.checkIn(1, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(2, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(3, ParkFi.DurationType.DAILY, 3 days);
        // pf.checkIn(4, ParkFi.DurationType.DAILY, 4 days);
        // pf.checkIn(5, ParkFi.DurationType.HOURLY, 2 hours);



        // pf.checkOut(1);
        // pf.checkOut(3);

        vm.stopBroadcast();
    


    }
}
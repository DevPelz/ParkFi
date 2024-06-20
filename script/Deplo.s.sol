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
        // ParkFi pf =   new ParkFi(0xe37e44964Dad319C6b31D222453b7DDd3b249721, 0x6Ec5929e48aD78838155FC8D3C6ed4E3c5BAc111,0xD8ed4a9317585BD8Ce8eF7524C313F25373D1739, 1e3, 1e3);
        ParkFi pf = ParkFi(0x5f5e7Ec4B245c571EdFa8fcd81A09b9311B769b1);
        console2.log("ParkFi:", address(pf));

        // PT.transfer(0x0489DB67c9B49C1C813da3C538103926f31BE572, 1000 ether);

        // MemNFT.setParkFiAddress(address(pf));
        // PSN.setParkFiAddress(address(pf));

        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
        // pf.verifyAndMintParkingSpace(1e10, 1e10);
            
        // pf.verifyAndMintMembership();

        // PT.approve(address(pf), type(uint256).max);

        // pf.checkIn(1, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(2, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(3, ParkFi.DurationType.DAILY, 3 days);
        // pf.checkIn(4, ParkFi.DurationType.DAILY, 4 days);
        // pf.checkIn(5, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(6, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(7, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(8, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(9, ParkFi.DurationType.HOURLY, 2 hours);
        // pf.checkIn(10, ParkFi.DurationType.HOURLY, 2 hours);



        // pf.checkOut(1);
        // pf.checkOut(3);


        // check parkspace
        ParkFi.ParkSpaceMetadata[] memory mySpaces = pf.getMyParkingSpaces();
        vm.stopBroadcast();
    


    }
}
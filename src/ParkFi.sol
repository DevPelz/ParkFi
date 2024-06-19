// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./MembershipNft.sol";
import "./ParkingSpaceNft.sol";

contract ParkFi is Ownable {

    MembershipNft MemNft;
    ParkingSpaceNFT ParkNft;
    IERC20 token;
    uint256 ParkIds;

    error NotMember();


    event ParkSpaceMinted(uint256 indexed _tokenid, uint indexed _hPrice, uint indexed _dPrice);
    event NewMemberAdded(address indexed _newMember);

    enum DurationType {
        HOURLY,
        DAILY
    }

 struct ParkSapceMetadata {
        uint256 id;
        uint256 hourlyPrice;
        uint256 dailyPrice;
        bool isBeingUsed;
        address currentUser;
        uint256 paidTill;
        DurationType durationType;
}


mapping(uint256 => ParkSapceMetadata) private tokenIdToParkSpaceMetadata;

modifier isMember() {
    if(MemNft.balanceOf(msg.sender) < 1){
        revert NotMember();
    }
    _;
}
  constructor(address _MemNft, address _ParkNft, address _token) Ownable(msg.sender){
    MemNft = MembershipNft(_MemNft);
    ParkNft = ParkingSpaceNFT(_ParkNft);
    token = IERC20(_token);
  }


  function verifyAndMintParkingSpace(uint256 _hPrice, uint256 _dPrice) external {
        ParkIds++;
       ParkSapceMetadata storage info = tokenIdToParkSpaceMetadata[ParkIds];
        info.id = ParkIds;
        info.hourlyPrice = _hPrice;
        info.dailyPrice = _dPrice;

        ParkNft.MintSpaceNft(msg.sender);

        emit ParkSpaceMinted(ParkIds, _hPrice, _dPrice);
  }
  function verifyAndMintMembership() external {
    MemNft.MintMembership(msg.sender);

    emit NewMemberAdded(msg.sender);
  }

  function checkIn() external isMember{}

  function checkOut() external isMember{}

//   view functions

   function getAvailableParkingSpaces()
        public
        view
        returns (ParkSapceMetadata[] memory)
    {
        uint256 totalNFT = ParkIds;
        uint256 unUsed;
        for (uint256 i = 0; i < totalNFT; i++) {
            if (!tokenIdToParkSpaceMetadata[i + 1].isBeingUsed) {
                unUsed++;
            }
        }
        uint256 currentIndex = 0;
        ParkSapceMetadata[] memory items = new ParkSapceMetadata[](unUsed);
        for (uint256 i = 0; i < totalNFT; i++) {
            if (!tokenIdToParkSpaceMetadata[i + 1].isBeingUsed) {
                uint256 currentId = i + 1;
                ParkSapceMetadata storage currentItem = tokenIdToParkSpaceMetadata[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }



}
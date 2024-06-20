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
    uint256 protocolFees;
    uint256 ovestayFee;
    uint256 ParkIds;

    error NotMember();
    error NotAvailable();
    error UnAuthorized();


    event ParkSpaceMinted(uint256 indexed _tokenid, uint indexed _hPrice, uint indexed _dPrice);
    event NewMemberAdded(address indexed _newMember);
    event CheckIn(uint256 indexed id_, address indexed member_);
    event CheckedOut(uint256 indexed id_);

    enum DurationType {
        HOURLY,
        DAILY
    }

 struct ParkSpaceMetadata {
        uint256 id;
        uint256 hourlyPrice;
        uint256 dailyPrice;
        uint256 validTill;
        bool isBeingUsed;
        address currentUser;
        address spaceOwner;
        DurationType durationType;
}


mapping(uint256 _id => ParkSpaceMetadata) private tokenIdToParkSpaceMetadata;

modifier isMember() {
    if(MemNft.balanceOf(msg.sender) < 1){
        revert NotMember();
    }
    _;
}
  constructor(address _MemNft, address _ParkNft, address _token, uint _protocolFee, uint _overstayFee) Ownable(msg.sender){
    MemNft = MembershipNft(_MemNft);
    ParkNft = ParkingSpaceNFT(_ParkNft);
    token = IERC20(_token);
    protocolFees = _protocolFee;
    ovestayFee = _overstayFee;
  }


  function verifyAndMintParkingSpace(uint256 _hPrice, uint256 _dPrice) external {
        ParkIds++;
       ParkSpaceMetadata storage info = tokenIdToParkSpaceMetadata[ParkIds];
        info.id = ParkIds;
        info.hourlyPrice = _hPrice;
        info.dailyPrice = _dPrice;
        info.spaceOwner = msg.sender;

        ParkNft.MintSpaceNft(msg.sender);

        emit ParkSpaceMinted(ParkIds, _hPrice, _dPrice);
  }
  function verifyAndMintMembership() external {
    // require not verified before.
    MemNft.MintMembership(msg.sender);

    emit NewMemberAdded(msg.sender);
  }

  function checkIn(uint256 _id, DurationType _durationType, uint duration) external isMember{
    ParkSpaceMetadata storage info = tokenIdToParkSpaceMetadata[_id];
    if(info.isBeingUsed){
        revert NotAvailable();
    }

    info.isBeingUsed = true;
    info.currentUser = msg.sender;

    if(_durationType == DurationType.HOURLY){
    info.durationType = DurationType.HOURLY;
    info.validTill = block.timestamp + duration;
    uint256 _amountH = duration  * info.hourlyPrice ;
    require(token.transferFrom(msg.sender, address(this), _amountH));
    require(token.transfer(info.spaceOwner, _amountH - protocolFees));
    emit CheckIn(_id, msg.sender);
    }else{
    info.validTill = block.timestamp + duration;
    uint256 _amountD = duration  * info.dailyPrice;
    require(token.transferFrom(msg.sender, address(this), _amountD ));
    require(token.transfer(info.spaceOwner, _amountD - protocolFees));
    emit CheckIn(_id, msg.sender);
    }
  }

  function checkOut(uint256 _id) external isMember{
     ParkSpaceMetadata storage info = tokenIdToParkSpaceMetadata[_id];
     if(info.currentUser != msg.sender){
        revert UnAuthorized();
     }
     uint256 overStayFees_ = _checkOverstayFeesIncured(info.validTill);
     if(overStayFees_ > 0){
        require(token.transferFrom(msg.sender, info.spaceOwner, overStayFees_));
     }
     info.currentUser = address(0);
     info.isBeingUsed = false;
     info.validTill = 0;

     emit CheckedOut(_id);
  }

   function getAvailableParkingSpaces()
        public
        view
        returns (ParkSpaceMetadata[] memory)
    {
        uint256 totalNFT = ParkIds;
        uint256 unUsed;
        for (uint256 i = 0; i < totalNFT; i++) {
            if (!tokenIdToParkSpaceMetadata[i + 1].isBeingUsed) {
                unUsed++;
            }
        }
        uint256 currentIndex = 0;
        ParkSpaceMetadata[] memory items = new ParkSpaceMetadata[](unUsed);
        for (uint256 i = 0; i < totalNFT; i++) {
            if (!tokenIdToParkSpaceMetadata[i + 1].isBeingUsed) {
                uint256 currentId = i + 1;
                ParkSpaceMetadata storage currentItem = tokenIdToParkSpaceMetadata[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
   function getMyParkingSpaces()
        public
        view
        returns (ParkSpaceMetadata[] memory)
    {
        uint256 totalNFT = ParkIds;
        uint256 used;
        for (uint256 i = 0; i < totalNFT; i++) {
            if (tokenIdToParkSpaceMetadata[i + 1].isBeingUsed && tokenIdToParkSpaceMetadata[i + 1].currentUser == msg.sender) {
                used++;
            }
        }
        uint256 currentIndex = 0;
        ParkSpaceMetadata[] memory items = new ParkSpaceMetadata[](used);
        for (uint256 i = 0; i < totalNFT; i++) {
            if (tokenIdToParkSpaceMetadata[i + 1].isBeingUsed &&  tokenIdToParkSpaceMetadata[i + 1].currentUser == msg.sender) {
                uint256 currentId = i + 1;
                ParkSpaceMetadata storage currentItem = tokenIdToParkSpaceMetadata[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function _checkOverstayFeesIncured(uint _duration) internal view returns(uint _amount){
        if(block.timestamp > _duration){
        uint256 diff = block.timestamp - _duration;
        if(diff > 0){
            _amount = (diff * protocolFees) * 1e18;
        }
        }
        return _amount;
    }

}
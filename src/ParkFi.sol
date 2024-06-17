// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface NFTInterface {
    function ERC721Mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) external;
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

contract ParkFi is Ownable {
    error NotAvailable();
    error InvalidMembership();
    error NotCurrentUser();
    IERC20 private parkToken;
    address private projectWallet;
    uint256 private tokenId;
    uint256 private membershipId;
    uint256 private overStayFee;
    MembershipFee private membershipFee;
    DiscountRateForMember private discountRateForMember;
    uint256 private rewardPointConvertionRatio;

    NFTInterface private parkSapceNFT;
    NFTInterface private ParkMembershipNFT;
    mapping(uint256 => ParkSapceMetadata) private tokenIdToParkSpaceMetadata;
    mapping(uint256 => MembershipMetadata)
        private membershipIdToMembershipMetadata;
    mapping(address => uint256[]) private userCurrentSpaceIds;

    event ParkSpaceMinted(uint256 _id, string _tokenURI);
    event ParkSpaceNftSet(address _address);
    event ParkFiMembershipNftSet(address _address);
    event ParkFiMembershipSelected(
        address _user,
        uint256 _pmnId,
        string _tokenURI
    );
    event ParkSpaceCheckedOut(uint256 indexed _psnId);
      event MembershipMinted(
            uint256 indexed membershipId,
            address indexed member,
            FeeTier feeTier,
            MembershipTier membershipTier
        );

        event MembershipCancelled(uint256[]  _mIds);

        event MembershipUpgraded(uint256 indexed _mIds, FeeTier indexed _feeTier, MembershipTier indexed _upgradeTo);

        event ParkSpaceSelected(uint256 indexed _psnId, address indexed _user, DurationType _type, uint256 _durationCount);


    struct ParkSapceMetadata {
        uint256 id;
        uint256 hourlyPrice;
        uint256 dailyPrice;
        bool isBeingUsed;
        address currentUser;
        uint256 paidTill;
        DurationType durationType;
        string tokenURI;
    }
    struct MembershipMetadata {
        uint256 id;
        address member;
        // uint256 membershipFee;
        uint256 validity;
        uint256 validTill;
        MembershipTier membershipTier;
        FeeTier feeTier;
        uint256 rewardPoints;
        string tokenURI;
    }

    enum DurationType {
        HOURLY,
        DAILY
    }
    enum MembershipTier {
        STANDARD,
        FLEET,
        VIP,
        ELITE
    }

    enum FeeTier {
        MONTHLY,
        ANNUALY
    }

    struct MembershipFee {
        uint256 standardMonthly;
        uint256 standardAnnual;
        uint256 fleetMonthly;
        uint256 fleetAnnual;
        uint256 vipMonthly;
        uint256 vipAnnual;
        uint256 eliteMonthly;
        uint256 eliteAnnualy;
    }

    struct DiscountRateForMember {
        uint256 standard;
        uint256 fleet;
        uint256 vip;
        uint256 elite;
    }
    constructor(
        address _parkToken,
        address _parkSpace,
        address _weParkMembership
    ) Ownable(msg.sender) {
        parkToken = IERC20(_parkToken);
        parkSapceNFT = NFTInterface(_parkSpace);
        ParkMembershipNFT = NFTInterface(_weParkMembership);
    }

    function getParkToken() public view returns (IERC20) {
        return parkToken;
    }

    function getProjectWallet() public view returns (address) {
        return projectWallet;
    }

    function getTokenId() public view returns (uint256) {
        return tokenId;
    }

    function getMembershipId() public view returns (uint256) {
        return membershipId;
    }

    function getOverStayFee() public view returns (uint256) {
        return overStayFee;
    }

    function getMembershipFee() public view returns (MembershipFee memory) {
        return membershipFee;
    }

    function getDiscountRateForMember()
        public
        view
        returns (DiscountRateForMember memory)
    {
        return discountRateForMember;
    }

    function getRewardPointConvertionRatio() public view returns (uint256) {
        return rewardPointConvertionRatio;
    }

    function getParkSpaceNFT() public view returns (NFTInterface) {
        return parkSapceNFT;
    }

    function getWeParkMembershipNFT() public view returns (NFTInterface) {
        return ParkMembershipNFT;
    }

    function getTokenIdToParkSpaceMetadata(
        uint256 _tokenId
    ) public view returns (ParkSapceMetadata memory) {
        return tokenIdToParkSpaceMetadata[_tokenId];
    }

    function getMembershipIdToMembershipMetadata(
        uint256 _membershipId
    ) public view returns (MembershipMetadata memory) {
        return membershipIdToMembershipMetadata[_membershipId];
    }

    function getAvailableParkingSpaces()
        public
        view
        returns (ParkSapceMetadata[] memory)
    {
        uint256 totalNFT = tokenId;
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
                ParkSapceMetadata
                    storage currentItem = tokenIdToParkSpaceMetadata[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getUsersCurrentSpaces(
        address _user
    ) public view returns (ParkSapceMetadata[] memory) {
        uint256[] memory userSpaceIds = userCurrentSpaceIds[_user];
        ParkSapceMetadata[] memory items = new ParkSapceMetadata[](
            userSpaceIds.length
        );
        for (uint256 i = 0; i < userSpaceIds.length; i++) {
            ParkSapceMetadata storage currentItem = tokenIdToParkSpaceMetadata[
                userSpaceIds[i]
            ];
            items[i] = currentItem;
        }
        return items;
    }

    function setRewardPointConvertionRatio(uint256 _ratio) public onlyOwner {
        rewardPointConvertionRatio = _ratio;
    }
    function setparkSapceNFT(address _newAddress) public onlyOwner {
        parkSapceNFT = NFTInterface(_newAddress);
        emit ParkSpaceNftSet(_newAddress);
    }
    function setParkFiMembershipNFT(address _newAddress) public onlyOwner {
        ParkMembershipNFT = NFTInterface(_newAddress);
        emit ParkFiMembershipNftSet(_newAddress);
    }

    function mintParkSpaceNFT(
        uint256 _hPrice,
        uint256 _dPrice,
        string memory _tokenURI
    ) public onlyOwner {
        tokenId++;
        ParkSapceMetadata storage info = tokenIdToParkSpaceMetadata[tokenId];
        info.id = tokenId;
        info.hourlyPrice = _hPrice;
        info.dailyPrice = _dPrice;
        info.tokenURI = _tokenURI;
        parkSapceNFT.ERC721Mint(address(this), tokenId, _tokenURI);
        emit ParkSpaceMinted(tokenId, _tokenURI);
    }

    function selectParkingSpace(
        uint256 _mId,
        uint256 _psnId,
        DurationType _type,
        uint256 _durationCount
    ) public {
        ParkSapceMetadata storage info = tokenIdToParkSpaceMetadata[_psnId];
        if (!info.isBeingUsed) {
            revert NotAvailable();
        }

        uint256 fee = (
            _type == DurationType.HOURLY ? info.hourlyPrice : info.dailyPrice
        ) * _durationCount;
        if (_mId != 0) {
            MembershipMetadata memory Minfo = membershipIdToMembershipMetadata[
                _mId
            ];
            if (block.timestamp > Minfo.validTill) {
                revert InvalidMembership();
            }
            uint256 discountP = Minfo.membershipTier == MembershipTier.STANDARD
                ? discountRateForMember.standard
                : Minfo.membershipTier == MembershipTier.FLEET
                    ? discountRateForMember.fleet
                    : Minfo.membershipTier == MembershipTier.VIP
                        ? discountRateForMember.vip
                        : Minfo.membershipTier == MembershipTier.ELITE
                            ? discountRateForMember.elite
                            : 0;
            uint256 dicount = (fee * discountP) / 1000;
            fee = fee - dicount;
        }
        parkToken.transferFrom(msg.sender, projectWallet, fee);
        userCurrentSpaceIds[msg.sender].push(_psnId);
        info.isBeingUsed = true;
        info.currentUser = msg.sender;
        info.paidTill =
            block.timestamp +
            ((_type == DurationType.HOURLY ? 1 hours : 1 days) *
                _durationCount);
        emit ParkSpaceSelected(_psnId, msg.sender, _type, _durationCount);
    }

    function checkOut(uint256 _psnId) public {
        ParkSapceMetadata storage info = tokenIdToParkSpaceMetadata[_psnId];
        if (msg.sender != info.currentUser) {
            revert NotCurrentUser();
        }
        if (block.timestamp > info.paidTill) {
            uint256 additionalHour = (block.timestamp - info.paidTill) /
                1 hours;
            uint256 additionalMin = (block.timestamp - info.paidTill) % 1 hours;
            uint256 total = additionalHour + additionalMin == 0 ? 0 : 1;
            parkToken.transferFrom(
                msg.sender,
                projectWallet,
                total * (info.hourlyPrice * 2)
            );
        }
        info.currentUser = address(0);
        info.isBeingUsed = false;
        uint256[] storage userSpaceIds = userCurrentSpaceIds[info.currentUser];
        for (uint256 i = 0; i < userSpaceIds.length; i++) {
            if (userSpaceIds[i] == _psnId) {
                userSpaceIds[i] = userSpaceIds[userSpaceIds.length - 1];

                userSpaceIds.pop();
                break;
            }
        }

        emit ParkSpaceCheckedOut(_psnId);
    }

    function mintMembershipNFT(
        FeeTier _feeTier,
        MembershipTier _membershipTier,
        string memory _tokenURI
    ) public {
        membershipId++;
        MembershipMetadata storage info = membershipIdToMembershipMetadata[
            membershipId
        ];
        info.id = membershipId;
        info.member = msg.sender;
        info.feeTier = _feeTier;
        uint256 fee;
        if (_feeTier == FeeTier.MONTHLY) {
            info.validity = 30 days;
            fee = _membershipTier == MembershipTier.STANDARD
                ? membershipFee.standardMonthly
                : _membershipTier == MembershipTier.FLEET
                    ? membershipFee.fleetMonthly
                    : membershipFee.vipMonthly;
        } else {
            info.validity = 365 days;
            fee = _membershipTier == MembershipTier.STANDARD
                ? membershipFee.standardAnnual
                : _membershipTier == MembershipTier.FLEET
                    ? membershipFee.fleetAnnual
                    : membershipFee.vipAnnual;
        }
        info.validTill = block.timestamp + info.validity;
        info.membershipTier = _membershipTier;
        info.tokenURI = _tokenURI;
        parkToken.transferFrom(msg.sender, address(this), fee);
        ParkMembershipNFT.ERC721Mint(msg.sender, membershipId, _tokenURI);

        emit MembershipMinted(membershipId, msg.sender, _feeTier, _membershipTier);
      
    }

    function cancelMembership(uint256[] memory _mIds) public onlyOwner {
        for (uint256 i = 0; i < _mIds.length; i++) {
            MembershipMetadata storage info = membershipIdToMembershipMetadata[
                _mIds[i]
            ];
            if (info.validTill > block.timestamp) {
                info.validTill = 0;
                uint256 refundAmount;
                if (info.feeTier == FeeTier.MONTHLY) {
                    refundAmount = info.membershipTier ==
                        MembershipTier.STANDARD
                        ? membershipFee.standardMonthly
                        : info.membershipTier == MembershipTier.FLEET
                            ? membershipFee.fleetMonthly
                            : membershipFee.vipMonthly;
                } else {
                    refundAmount = info.membershipTier ==
                        MembershipTier.STANDARD
                        ? membershipFee.standardAnnual
                        : info.membershipTier == MembershipTier.FLEET
                            ? membershipFee.fleetAnnual
                            : membershipFee.vipAnnual;
                }
                parkToken.transferFrom(
                    projectWallet,
                    info.member,
                    refundAmount
                );
            }
        }

        emit MembershipCancelled(_mIds);
    }

    function upgradeMembership(
        uint256 _mIds,
        FeeTier _feeTier,
        MembershipTier _upgradeTo
    ) public {
        MembershipMetadata storage info = membershipIdToMembershipMetadata[
            _mIds
        ];
        info.feeTier = _feeTier;
        uint256 fee;
        if (_feeTier == FeeTier.MONTHLY) {
            info.validity = 30 days;
            fee = _upgradeTo == MembershipTier.STANDARD
                ? membershipFee.standardMonthly
                : _upgradeTo == MembershipTier.FLEET
                    ? membershipFee.fleetMonthly
                    : membershipFee.vipMonthly;
        } else {
            info.validity = 365 days;
            fee = _upgradeTo == MembershipTier.STANDARD
                ? membershipFee.standardAnnual
                : _upgradeTo == MembershipTier.FLEET
                    ? membershipFee.fleetAnnual
                    : membershipFee.vipAnnual;
        }
        info.validTill = block.timestamp + info.validity;
        info.membershipTier = _upgradeTo;
        parkToken.transferFrom(msg.sender, address(this), fee);

        emit MembershipUpgraded(_mIds, _feeTier, _upgradeTo);
    }
}
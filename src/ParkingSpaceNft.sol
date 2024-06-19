// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ParkingSpaceNFT is ERC721URIStorage, Ownable{

    address public ParkFiAddress;
    uint private tokenId;
    string public URI;


    error UnAuthorized();

    event SpaceMinted(address indexed _to, uint256 indexed _tId);
    event terminated(uint256 indexed _tId);
    constructor(string memory _URI) ERC721("Parking Space NFT", "PSN") Ownable(msg.sender){
       URI = _URI;
    }

    function setParkFiAddress(address _parkFi) external onlyOwner{
        ParkFiAddress = _parkFi;
    }

    function MintSpaceNft(address _to) external {
        if(msg.sender != ParkFiAddress){
            revert UnAuthorized();
        }
        tokenId++;
        _setTokenURI(tokenId, URI);
        _safeMint(_to, tokenId);

        emit SpaceMinted(_to, tokenId);
    }

    function terminateSpace(uint256 _tokenId) external {
        if(msg.sender != ParkFiAddress){
            revert UnAuthorized();
        }
        _burn(_tokenId);
        emit terminated(_tokenId);
    }
}
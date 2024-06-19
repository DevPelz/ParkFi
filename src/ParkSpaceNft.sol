// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract ParkSpaceNFT is ERC721URIStorage, Ownable {
    error NotTokenOwner();
    error NotParkFi();
    address private ParkFiContract;

    event TokenURIUpdated(
        uint256 indexed tokenId,
        string tokenURI
    );

    event ContractAddressUpdated(address indexed newAddress);
        constructor()
        ERC721("Park Space NFT", "ParkSpaceNFT")
        Ownable(msg.sender)
    {}

    function updateTokenURI(
        uint256 _tokenId,
        string memory _tokenURI
    ) public onlyOwner {
        _setTokenURI(_tokenId, _tokenURI);
        emit TokenURIUpdated(_tokenId, _tokenURI);
    }

    function setParkFiContractAddress(address _newAddress) public onlyOwner {
        ParkFiContract = _newAddress;
        emit ContractAddressUpdated(_newAddress);
    }

    function ERC721Mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) external {
        if (msg.sender != ParkFiContract) {
            revert NotParkFi();
        }
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
    }

    function burn(uint256 tokenId) public virtual {
        if (msg.sender != ownerOf(tokenId)) {
            revert NotTokenOwner();
        }
        _burn(tokenId);
    }
}

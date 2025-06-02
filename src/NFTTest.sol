// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTTest is ERC721 {
    uint256 private _tokenId;

    constructor() ERC721("NFTTest", "NFTT") {}

    // Tothom pot cridar la funció mint ates que es NFT de test
    function mint(address to) external returns (uint256 id) {
        id = ++_tokenId;
        _mint(to, id);
    }
}

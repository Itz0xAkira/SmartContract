

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import 'https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol';
import 'https://github.com/chiru-labs/ERC721A/blob/main/contracts/extensions/ERC721AQueryable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

// Made by:: 0xAkira

contract VERSESHOE is ERC721A,  ERC721AQueryable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    string public baseURI = "ipfs://QmVMNsuCGQKGp2L83mtRC1QwNL2fGC6hLWJqHsjEBxvTYR/vsch/";
    string public baseExtension = ".json";
    string public notRevealedUri = "ipfs://CID/hidden.json";
    uint256 public costWL = 0.08 ether;
    uint256 public maxSupply = 5000;
    uint256 public maxMintAmountWL = 1;
    //uint256 public supp = totalSupply();

    bool public revealed = true;

    mapping(address => uint256) public addressMintedBalanceWL;

    uint256 public currentState = 0;
	
    uint public saleStartTime = 1665484146;

    mapping(address => bool) public whitelistedAddresses;

    bytes32 public merkleRootWhitelist = 0x9d71b347a619fbe062d3bc7936012434b9d8556b4b4eb67b19887dbec335e4fb;
  
    constructor() ERC721A("Verseshoe", "VSHOE") {}

    function mint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable
    {
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");
        if (msg.sender != owner()) {
            require(currentState > 0, "the contract is paused");
            if (currentState == 1) {
                uint256 ownerMintedCount = addressMintedBalanceWL[msg.sender];
                require(
                    isWhitelisted(msg.sender, _merkleProof),
                    "user is not whitelisted"
                );
	            require(
                     currentTime() >= saleStartTime,
                     "Whitelist Sale has not started yet"
                );
                require(
                    _mintAmount <= maxMintAmountWL,
                    "max mint amount per session exceeded"
                );
                require(
                    ownerMintedCount + _mintAmount <= maxMintAmountWL,
                    "max NFT per address exceeded"
                );
                require(
                    msg.value >= costWL * _mintAmount,
                    "insufficient funds"
                );
            } 
        }

        _safeMint(msg.sender, _mintAmount);
        if (currentState == 1) {
            addressMintedBalanceWL[msg.sender] += _mintAmount;
        }
    }

    function Airdrop(uint256 _mintAmount, address _receiver) public onlyOwner {
	    require(_mintAmount > 0, "need to mint at least 1 NFT");
	    require(totalSupply() + _mintAmount <= maxSupply, "max NFT limit exceeded");
        _safeMint(_receiver, _mintAmount);
    }

    function isWhitelisted(address _user, bytes32[] calldata _merkleProof)
        public
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(_user));
        return MerkleProof.verify(_merkleProof, merkleRootWhitelist, leaf);
    }

    function mintableAmountForUser(address _user) public view returns (uint256) {
        if (currentState == 1) {
            return maxMintAmountWL - addressMintedBalanceWL[_user];
        }
        return 0;
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
	
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
	
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) { 
        require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token" );

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

     function burnTokens(uint numOfTokens) public onlyOwner {
               require( maxSupply - numOfTokens >= 2000);
               uint newMaxSupply = maxSupply - numOfTokens;
               maxSupply = newMaxSupply;
 }

    function setmaxMintAmountWL(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmountWL = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function currentTime() internal view returns(uint) {
        return block.timestamp;
    }

    function setSaleStartTime(uint _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
    }

    function pause() public onlyOwner {
        currentState = 0;
    }

    function setOnlyWhitelisted() public onlyOwner {
        currentState = 1;
    }

    function setWLCost(uint256 _price) public onlyOwner {
        costWL = _price;
    }

    function setWhitelistMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRootWhitelist = _merkleRoot;
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool os, ) = payable(owner()).call{value: address(this).balance}('');
        require(os);
    }
}

/* Project Dawnguard */
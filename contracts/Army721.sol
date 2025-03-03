// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC721} from  "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Army is ERC721, ERC721URIStorage, ERC721Pausable, ERC721Burnable, Ownable {

   using Strings for uint256;
    
    address public recipient; 

    string  public baseURI;
    string  public mintPhase;
    
    uint256 private nextTokenId;
    uint256 public totalMinted;
    uint256 public max_supply;
    uint256 public publicMintPrice;
    uint256 public fpAllowListPrice;
    uint256 public fpAllowListEndTime;
    uint256 public spAllowListPrice;
    uint256 public spAllowListEndTime;
    uint256 public maximumSpMint;

    bytes32 public fpAllowListRoot;
    bytes32 public spAllowListRoot;

    bool public publicMintLive;
    bool public fpAllowListMintLive;
    bool public spAllowListMintLive;
    bool private lockBaseURI;

    constructor(address initialOwner, address _recipient, string memory _baseURI)
        ERC721("Onchain Army", "Army")
        Ownable(initialOwner)
    {
        totalMinted = 0;
        max_supply = 5000;
        publicMintPrice = 0.042 ether;
        fpAllowListPrice = 0.03 ether;
        publicMintLive = false;
        fpAllowListMintLive = false;
        fpAllowListEndTime = block.timestamp + 30 minutes;
        spAllowListPrice = 0.035 ether;
        spAllowListMintLive = false;
        spAllowListEndTime = block.timestamp + 30 minutes;
        maximumSpMint = 25;
        baseURI = _baseURI;
        lockBaseURI = false;
        recipient = _recipient;
    }

    

    mapping(address => uint256) public minterTotalNfts;

    

    modifier checkTotalMinted (uint256 nftAmount) {
        require((nftAmount + totalMinted) <= max_supply, "nft mint amount execeeds supply available");
        _;
    }


    // PUBLIC MINTING 
    
    modifier isPublicPrice(uint256 amount, uint256 nftAmount) {
        require(amount >= (publicMintPrice * nftAmount), "Not enough ether");
        _;
    }

   
    
    modifier onlyPublicMintLive() {
        require(publicMintLive, "public mint not live yet");
        _;
    }

    function togglePublicMintLive () public onlyOwner{
        publicMintLive = !publicMintLive;
    }



   function publicMint (address minter, uint256 nftAmount) 
    public 
    payable 
    onlyPublicMintLive
    isPublicPrice(msg.value, nftAmount) 
    {
        minterTotalNfts[minter] += nftAmount;
        mint(minter, nftAmount);
    }

   function setPublicMintPrice (uint256 price) public  onlyOwner {
    publicMintPrice = price;
   }

//    FPWHITELIST MINTING

    modifier isFpAllowListPrice(uint256 amount, uint256 nftAmount ) {
            require(amount >= (fpAllowListPrice * nftAmount), "Not enough ether");
            _;
        }
    
   modifier checkFpAllowListEndTime() {
    require(fpAllowListEndTime >= block.timestamp, "Minting phase ended.");
    _;
   }

   modifier validateFpAllowList (bytes32[] memory proof, address minter) {
    require(verifyFpAllowList(proof, keccak256(abi.encodePacked(minter))), "Not a part of Allowlist");
    _;
   }
   modifier onlyFpAllowMintLive() {
        require(fpAllowListMintLive == true, "public mint not live yet");
        _;
    }

    function toggleFpAllowListMintLive () public onlyOwner {
        fpAllowListMintLive = !fpAllowListMintLive;
    }

   function setFpAllowListRoot(bytes32 _root) public onlyOwner {
     fpAllowListRoot = _root;
   }

   function setFpAllowListEndTime (uint256 duration) public  onlyOwner {
     fpAllowListEndTime = block.timestamp + duration;
   }

   function verifyFpAllowList (bytes32[] memory proof, bytes32 leaf) public view  returns (bool)  {
    return MerkleProof.verify(proof, fpAllowListRoot, leaf);
   }

   function fpAllowMint(address minter, uint256 nftAmount, bytes32[] memory proof)
    public 
    payable 
    isFpAllowListPrice(msg.value, nftAmount)
    checkFpAllowListEndTime
    validateFpAllowList(proof, minter)
    onlyFpAllowMintLive
    {
        minterTotalNfts[minter] += nftAmount;
        mint(minter, nftAmount);
   }

   function setFpAllowListPrice(uint256 price) public onlyOwner {
      fpAllowListPrice = price;
   }

//    SPWHITELIST MINTING

 modifier isSpAllowListPrice(uint256 amount, uint256 nftAmount) {
            require(amount >= (spAllowListPrice * nftAmount), "Not enough ether");
            _;
        }
    
   modifier checkSpAllowListEndTime() {
    require(spAllowListEndTime >= block.timestamp, "Minting phase ended.");
    _;
   }

   modifier validateSpAllowList (bytes32[] memory proof, address minter) {
    require(verifySpAllowList(proof, keccak256(abi.encodePacked(minter))), "Not a part of Allowlist");
    _;
   }
   modifier onlySpAllowMintLive() {
        require(spAllowListMintLive == true, "public mint not live yet");
        _;
    }

    function toggleSpAllowListMintLive () public onlyOwner {
        spAllowListMintLive = !spAllowListMintLive;
    }

   function setSpAllowListRoot(bytes32 _root) public onlyOwner {
     spAllowListRoot = _root;
   }

   function setSpAllowListEndTime (uint256 duration) public  onlyOwner {
     spAllowListEndTime = block.timestamp + duration;
   }

   function verifySpAllowList (bytes32[] memory proof, bytes32 leaf) public view  returns (bool)  {
    return MerkleProof.verify(proof, spAllowListRoot, leaf);
   }

   function spAllowMint(address minter, uint256 nftAmount, bytes32[] memory proof)
    public 
    payable 
    isSpAllowListPrice(msg.value, nftAmount)
    checkSpAllowListEndTime
    validateSpAllowList(proof, minter)
    onlySpAllowMintLive
    {
    require((minterTotalNfts[minter] + nftAmount) <= maximumSpMint, "maximum nft mint reached.");
       minterTotalNfts[minter] += nftAmount;
       mint(minter, nftAmount);
   }

   function setSpAllowListPrice(uint256 price) public onlyOwner {
      spAllowListPrice = price;
   }
  
  function setMaximumSpMint (uint256 amount) public onlyOwner {
    maximumSpMint = amount;
  }
    


    function mint(address to, uint256 nftAmount)
        internal
        checkTotalMinted(nftAmount)
    {
        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "Ether transfer failed");

        for(uint i; i < nftAmount; i++) {
            uint tokenId = nextTokenId++;
            totalMinted++ ;
            _safeMint(to, tokenId);
            string memory tokenIdStr = tokenId.toString();
            string memory uri = string(abi.encodePacked("/", tokenIdStr ,".json"));
            _setTokenURI(tokenId, uri);
            
        }
    }


   function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }
    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        string memory tokenURL = super.tokenURI(tokenId);
        return string.concat(baseURI, tokenURL);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

     function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setBaseUri(string memory uri) public onlyOwner {
        require(!lockBaseURI, "you have locked the baseURI");
        baseURI = uri;
    }
    
    function setLockBaseURI() public onlyOwner {
        lockBaseURI = true;
    }

    function airdrop(address to, uint256 nftAmount) public  onlyOwner {
        minterTotalNfts[to] += nftAmount;
        mint(to, nftAmount); 
    }


    function setPublictMintLive() public onlyOwner{
        publicMintLive = true;
        fpAllowListMintLive = false;
        spAllowListMintLive = false;
        mintPhase = "PUBLIC";
   }

   function setFpMintLive() public onlyOwner {
        fpAllowListMintLive = true;
        fpAllowListEndTime = block.timestamp + 30 minutes;
        spAllowListMintLive = false;
        publicMintLive = false;
        mintPhase = "FIRST PHASE";
   }

   function setSpMintLive() public onlyOwner {
        spAllowListMintLive = true;
        spAllowListEndTime = block.timestamp + 30 minutes;
        fpAllowListMintLive = false;
        publicMintLive = false;
        mintPhase = "SECOND PHASE";
   }

}

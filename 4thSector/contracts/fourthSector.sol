// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface INFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract fourthSector {
    address public admin;

    struct Claim {
        uint256 points;
        string ipfsUri;
        bool verified;
        address tokenAddress;
        uint256 tokenId; // For NFTs
    }

    struct Account {
        uint256 totalAttributionPoints;
        bool isWorker;
        Claim[] claims;
        bool isSponsor;
        bool isSupporter;
    }

    mapping(address => bool) public validNFTContracts; // Track valid NFT contracts
    mapping(address => Account) public accounts;
    address[] public accountList;

    event AccountUpdated(address account, bool isWorker);
    event ClaimSubmitted(address account, uint256 points, string ipfsUri);
    event SponsorshipSubmitted(address sponsor, uint256 points, string ipfsUri);
    event SupportClaimSubmitted(address supporter, uint256 points, string ipfsUri);
    event ClaimVerified(address account, uint256 claimIndex, bool verified);
    event SponsorshipReceived(address sponsor, uint256 amount, address tokenAddress);
    event SupportReceived(address supporter, address nftAddress, uint256 tokenId);
    event PointsModified(address account, uint256 claimIndex, uint256 newPoints);
    event ValidNFTContractAdded(address nftAddress);
    event ValidNFTContractRemoved(address nftAddress);

    constructor(address _admin) {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function addValidNFTContract(address _nftAddress) public onlyAdmin {
        validNFTContracts[_nftAddress] = true;
        emit ValidNFTContractAdded(_nftAddress);
    }

    function removeValidNFTContract(address _nftAddress) public onlyAdmin {
        validNFTContracts[_nftAddress] = false;
        emit ValidNFTContractRemoved(_nftAddress);
    }

    function updateAccount(address _account, bool _isWorker) public onlyAdmin {
        ensureAccountListed(_account);
        Account storage account = accounts[_account];
        account.isWorker = _isWorker;
        emit AccountUpdated(_account, _isWorker);
    }

    // Workers submit claims with IPFS URI
    function submitClaim(uint256 _points, string memory _ipfsUri) public {
        require(accounts[msg.sender].isWorker, "Not a worker");
        accounts[msg.sender].claims.push(Claim(_points, _ipfsUri, false, address(0), 0));
        emit ClaimSubmitted(msg.sender, _points, _ipfsUri);
    }

    // Verify worker claim
    function verifyWorkerClaim(address _account, uint256 _claimIndex, bool _verified) public {
        require(accounts[_account].isWorker, "Not a worker");
        require(_claimIndex < accounts[_account].claims.length, "Invalid claim index");
        Claim storage claim = accounts[_account].claims[_claimIndex];
        claim.verified = _verified;
        if (_verified) {
            // Add points to total attribution points if verified
            accounts[_account].totalAttributionPoints += claim.points;
        }
        emit ClaimVerified(_account, _claimIndex, _verified);
    }

    function sponsor(uint256 _points, string memory _ipfsUri, address _tokenAddress, uint256 _tokenAmount) public payable {
        ensureAccountListed(msg.sender);
        Account storage sponsorAccount = accounts[msg.sender];
        sponsorAccount.isSponsor = true;
        if (_tokenAddress == address(0)) {
            require(msg.value > 0, "Must send ETH with sponsorship");
            emit SponsorshipReceived(msg.sender, msg.value, address(0));
        } else {
            IERC20 token = IERC20(_tokenAddress);
            require(token.transferFrom(msg.sender, address(this), _tokenAmount), "Token transfer failed");
            emit SponsorshipReceived(msg.sender, _tokenAmount, _tokenAddress);
        }
        sponsorAccount.claims.push(Claim(_points, _ipfsUri, false, _tokenAddress, 0));
    }

    function support(uint256 _points, string memory _ipfsUri, address _nftAddress, uint256 _tokenId) public {
        require(validNFTContracts[_nftAddress], "NFT is not from a valid contract");
        INFT nft = INFT(_nftAddress);
        nft.transferFrom(msg.sender, address(this), _tokenId);
        ensureAccountListed(msg.sender);
        Account storage supporterAccount = accounts[msg.sender];
        supporterAccount.isSupporter = true;
        supporterAccount.claims.push(Claim(_points, _ipfsUri, false, _nftAddress, _tokenId));
        emit SupportReceived(msg.sender, _nftAddress, _tokenId);
        emit SupportClaimSubmitted(msg.sender, _points, _ipfsUri);
    }

    function verifyOrModifyClaim(address _account, uint256 _claimIndex, uint256 _newPoints, bool _verified) public onlyAdmin {
        Account storage account = accounts[_account];
        require(_claimIndex < account.claims.length, "Invalid claim index");
        Claim storage claim = account.claims[_claimIndex];

        // Verify or modify only if the account is a sponsor or a supporter
        require(account.isSponsor || account.isSupporter, "Account is neither a sponsor nor a supporter");
        
        claim.points = _newPoints;
        claim.verified = _verified;

        if (_verified) {
            account.totalAttributionPoints += _newPoints; 
        }

        emit PointsModified(_account, _claimIndex, _newPoints);
        emit ClaimVerified(_account, _claimIndex, _verified);
    }

    function ensureAccountListed(address _account) internal {
        if (!isAccountListed(_account)) {
            accountList.push(_account);
        }
    }

    function isAccountListed(address _account) internal view returns (bool) {
        for (uint i = 0; i < accountList.length; i++) {
            if (accountList[i] == _account) {
                return true;
            }
        }
        return false;
    }

    function calculateShare(address _account) public view returns (uint256) {
        uint256 totalPoints = 0;
        for (uint i = 0; i < accountList.length; i++) {
            totalPoints += accounts[accountList[i]].totalAttributionPoints;
        }
        if (totalPoints == 0) {
            return 0;
        }
        return (accounts[_account].totalAttributionPoints * 100) / totalPoints;
    }

    function getAccountsAndShares() public view returns (address[] memory, uint256[] memory) {
        uint256 totalPoints = 0;
        for (uint i = 0; i < accountList.length; i++) {
            totalPoints += accounts[accountList[i]].totalAttributionPoints;
        }

        address[] memory addresses = new address[](accountList.length);
        uint256[] memory shares = new uint256[](accountList.length);

        for (uint i = 0; i < accountList.length; i++) {
            addresses[i] = accountList[i];
            shares[i] = totalPoints > 0 ? (accounts[accountList[i]].totalAttributionPoints * 100000000) / totalPoints : 0;
        }

        return (addresses, shares);
    }

}

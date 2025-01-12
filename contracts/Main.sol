// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


 
contract Petition {
    address public owner; // Contract owner
 
    struct PetitionDetails {
        uint256 petitionId; // Unique ID for the petition
        string title;
        string description;
        string name; // User's name
        string physicalAddress; // Physical address of the user
        address creator;
        uint256 signCount;
        string petitionType; // Type of petition
        bool isOpen; // Petition status (true = open, false = closed)
    }
 
    mapping(uint256 => PetitionDetails) public petitions;
    uint256 public petitionCount;
 
    event PetitionCreated(uint256 petitionId, string title, address creator, string name, string petitionType);
    event PetitionSigned(uint256 petitionId, address signer);
    event PetitionStatusUpdated(uint256 petitionId, bool isOpen);
 
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
 
    constructor() {
        owner = msg.sender; // Set the contract owner
    }
 
    function createPetition(
        string memory title,
        string memory description,
        string memory name,
        string memory physicalAddress,
        string memory petitionType,
        string memory userAddressString
    ) public {
        petitionCount++; // Increment petitionCount for the new petition
        address userAddress = parseAddress(userAddressString);
        petitions[petitionCount] = PetitionDetails({
            petitionId: petitionCount, // Assign the current petitionCount as the petition ID
            title: title,
            description: description,
            name: name,
            physicalAddress: physicalAddress,
            creator: userAddress, // Use the address of the creator
            signCount: 0,
            petitionType: petitionType,
            isOpen: true // Default to open
        });
 
        emit PetitionCreated(petitionCount, title, msg.sender, name, petitionType);
    }
 
    function signPetition(uint256 petitionId, string memory userAddressString) public {
        address userAddress = parseAddress(userAddressString);
        require(petitionId <= petitionCount, "Petition does not exist.");
        require(petitions[petitionId].isOpen, "Petition is closed.");
        require(petitions[petitionId].creator != userAddress, "Creator cannot sign their own petition.");
 
        petitions[petitionId].signCount++;
        emit PetitionSigned(petitionId, userAddress);
    }
 
    function updatePetitionStatus(uint256 petitionId, bool isOpen) public onlyOwner {
        require(petitionId <= petitionCount, "Petition does not exist.");
        petitions[petitionId].isOpen = isOpen;
        emit PetitionStatusUpdated(petitionId, isOpen);
    }
 
    function getAllPetitions() public view returns (PetitionDetails[] memory) {
        PetitionDetails[] memory allPetitions = new PetitionDetails[](petitionCount);
        for (uint256 i = 1; i <= petitionCount; i++) {
            allPetitions[i - 1] = petitions[i];
        }
        return allPetitions;
    }
 
    function getPetitionsByAddress(string memory userAddressString) public view returns (PetitionDetails[] memory) {
        address userAddress = parseAddress(userAddressString);
        uint256 count = 0;
        for (uint256 i = 1; i <= petitionCount; i++) {
            if (petitions[i].creator == userAddress) {
                count++;
            }
        }
 
        PetitionDetails[] memory userPetitions = new PetitionDetails[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= petitionCount; i++) {
            if (petitions[i].creator == userAddress) {
                userPetitions[index] = petitions[i];
                index++;
            }
        }
 
        return userPetitions;
    }
 
    // New function: Get petition by ID
    function getPetitionById(uint256 petitionId) public view returns (PetitionDetails memory) {
        require(petitionId <= petitionCount, "Petition does not exist.");
        return petitions[petitionId];
    }
    function parseAddress(string memory addressString) internal pure returns (address) {
        bytes memory tempBytes = bytes(addressString);
        uint160 addr = 0;
        uint160 b;
        for (uint256 i = 2; i < 42; i++) {
            b = uint160(uint8(tempBytes[i]));
            if ((b >= 97) && (b <= 102)) {
                b -= 87;
            } else if ((b >= 65) && (b <= 70)) {
                b -= 55;
            } else if ((b >= 48) && (b <= 57)) {
                b -= 48;
            }
            addr = addr * 16 + b;
        }
        return address(addr);
    }
}


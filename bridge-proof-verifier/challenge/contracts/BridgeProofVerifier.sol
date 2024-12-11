// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BridgeProofVerifier {
    uint256 constant private FIELD_PRIME = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
    uint256 constant private GENERATOR = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 constant private SOURCE_BRIDGE_KEY = 0x87F83F0A178809ADC0DB8C44D3C982812D6966693FC34F658726406977C0C2D8;
    uint256 constant private REQUIRED_VERIFICATIONS = 3;

    mapping(address => uint256) public verificationTime;
    mapping(address => uint256) public userVerifications;

    event BridgeVerification(address indexed sender, uint256 verificationNumber);
    bool public isSolved;

    struct BridgeProof {
        uint256 commitment;
        uint256 responseValue;
        bytes32 messageHash;
    }

    function verifyBridgeTransaction(BridgeProof calldata proof, uint256 networkIdentifier) external returns (bool) {
        require(proof.commitment > 2 && proof.commitment < FIELD_PRIME - 1, "Invalid");
        require(proof.responseValue > 2 && proof.responseValue < FIELD_PRIME - 1, "Invalid");
        require(networkIdentifier > 2 && networkIdentifier < FIELD_PRIME - 1, "Invalid");
        require(proof.messageHash == keccak256(abi.encodePacked(block.timestamp, msg.sender)), "Invalid");

        if (verificationTime[msg.sender] != 0) {
            require(block.timestamp > verificationTime[msg.sender], "Too soon!");
        }

        uint256 challenge = uint256(keccak256(abi.encodePacked(proof.commitment, proof.messageHash))) % FIELD_PRIME;

        bool isValid = verifyProofComponents(
            proof.commitment,
            proof.responseValue,
            challenge,
            networkIdentifier
        );

        if (isValid) {
            verificationTime[msg.sender] = block.timestamp;
            userVerifications[msg.sender]++;
            emit BridgeVerification(msg.sender, userVerifications[msg.sender]);

            if (userVerifications[msg.sender] >= REQUIRED_VERIFICATIONS) {
                isSolved = true;
            }
        }

        return isValid;
    }

    function verifyProofComponents(uint256 commitment, uint256 response, uint256 challenge, uint256 networkId) internal pure returns (bool) {
        uint256 left = modExp(GENERATOR, response, FIELD_PRIME);
        uint256 right = mulmod(commitment, modExp(SOURCE_BRIDGE_KEY, challenge, FIELD_PRIME), FIELD_PRIME);
        return left == mulmod(right, networkId, FIELD_PRIME);
    }

    function modExp(uint256 base, uint256 exponent, uint256 modulus) internal pure returns (uint256) {
        // calculate pow(base, exponent, modulus)
        if (modulus == 1) return 0;
        uint256 result = 1;
        base = base % modulus;
        while (exponent > 0) {
            if (exponent % 2 == 1) result = mulmod(result, base, modulus);
            base = mulmod(base, base, modulus);
            exponent = exponent >> 1;
        }
        return result;
    }
}

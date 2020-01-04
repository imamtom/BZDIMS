pragma solidity ^0.5.0;
import "verify.sol";
import "ARC.sol";

contract KMC{
    ARC arc;
    CVC cvc;
    RVC rvc;
    mapping(bytes32 => bytes32) public claims;
    mapping(bytes32 => bytes32) public adjunction;
    event LogTokenClaim(address, bytes32, bytes32);
    event LogTokenResponse(bytes32, string);
    
    function setcliam(address c)public{
        cvc = CVC(c);
    }
    function setarc(address a)public{
        arc = ARC(a);
    }
    function setres(address r)public{
        rvc = RVC(r);
    }
    function tokenClaim(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[5] memory input)public returns (bool){
        //bytes32 id = packToBytes32(input[0],input[1]);
         //bytes32 id = 0x2123e10a5c7a9e5bb3de5a568cb3a36f12ee705b47e47d109cdfcaf3b56faf21;
        //bytes32 id_claim = 0x36f12ee705b47e47d109cdfcaf3b56faf212123e10a5c7a9e5bb3de5a568cb3a;
        bytes32 id_claim = packToBytes32(input[2],input[3]);
        bytes32 id = packToBytes32(input[0],input[1]); 
        bool reslut = cvc.claimPKVerify(a,b,c,input);
        require (reslut == true, "verify failed!");
        require (arc.creatorQuery(id) == msg.sender, "you are not the creator of token");
        require (arc.claimedQuery(id) == false, "this token has been claimed");
        require (arc.exisitQuery(id) == true, "this token has been revocationed!");
        claims[id_claim] = id_claim;
        arc.changeStatus(id);
        emit LogTokenClaim(msg.sender, id, id_claim);
        return true;
    }
    function tokenResponse(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[7] memory input, string memory res)public returns (bool){
        //bytes32 id = 0x2123e10a5c7a9e5bb3de5a568cb3a36f12ee705b47e47d109cdfcaf3b56faf21;
        //bytes32 id_claim = 0x36f12ee705b47e47d109cdfcaf3b56faf212123e10a5c7a9e5bb3de5a568cb3a;
        //bytes32 id_ne = 0xcb3a36f12ee705b47e47d109cdfcaf3b56faf212123e10a5c7a9e5bb3de5a568;
        bytes32 id = packToBytes32(input[0],input[1]);
        bytes32 id_claim = packToBytes32(input[2],input[3]);
        bytes32 id_ne = packToBytes32(input[4],input[5]);
        bool reslut = rvc.responseSKVerify(a,b,c,input);
        require (reslut == true, "verify failed!");
        require (arc.exisitQuery(id) == true, "this token has been revocationed!");
        require (claims[id_claim] == id_claim, "this token has not beenclaimed");
        require (adjunction[id_ne] == 0, "proof has been used!");
        adjunction[id_ne] = id_ne;
        emit LogTokenResponse(id, res);
        return true;
    } 
    //function addclaim(bytes32 id_claim)public returns(uint){
    //    claims[id_claim] = id_claim;
    //}   
    function packToBytes32(uint256 high, uint256 low)public pure returns (bytes32){
        return bytes32(low) | (bytes32(high)<<128);
    }
}

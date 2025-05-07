// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
        // Part venedora (Usuari Bob)
        // ha de tenir el NFT amb Id=0 del Token Geometria        
        uint256 constant clauPrivadaVenedor = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
       uint256 constant idToken = 0;
        // Part compradora (Usuari Eve)
        uint256 constant clauPrivadaLicitador = 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a;

contract RestauraNFT is Script {
    function run() external {
        // Tornem a enviar token de Licitador a Venedor
        address contracteNFT =  vm.envAddress("ADRECA_CONTRACTENFT");
    
        address Licitador = vm.addr(clauPrivadaLicitador);
        address Venedor = vm.addr(clauPrivadaVenedor);

        vm.startBroadcast(clauPrivadaLicitador);

        // Pas 1: Licitador autoritza Venedor a moure token
         bytes memory dadesAprovacio = abi.encodeWithSignature(
           "setApprovalForAll(address,bool)",
           Venedor,
           true
         );
         (bool okApprove, ) = contracteNFT.call(dadesAprovacio);
         require(okApprove, "Error a setApprovalForAll");
        vm.stopBroadcast();

        vm.startBroadcast(clauPrivadaVenedor);
        IERC721(contracteNFT).safeTransferFrom(
            Licitador,
            Venedor,
            idToken
        );
        // Pas 2: Venedor mou token
        vm.stopBroadcast();

    }
}

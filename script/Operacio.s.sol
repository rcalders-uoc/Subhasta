// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// Part venedora (Usuari Bob)
// ha de tenir el NFT amb Id=0 del Token Geometria

uint256 constant clauPrivadaVenedor = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
uint256 constant tokenId = 0;
// Part compradora (Usuari Eve)
uint256 constant clauPrivadaLicitador = 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a;

contract CreacioSubhasta is Script {
    function run() external {
        address contracteNFT = vm.envAddress("ADRECA_CONTRACTENFT");
        address subhastaProxy = vm.envAddress("ADRECA_SUBHASTA");
        address Licitador = vm.addr(clauPrivadaLicitador);
        address Venedor = vm.addr(clauPrivadaVenedor);

        console.log("Adreca contracte ", subhastaProxy);
        console.log("Venedor:", Venedor);
        console.log("Licitador:", Licitador);

        vm.startBroadcast(clauPrivadaVenedor);

        // Pas 1: Venedor autoritza subhasta a moure token
        IERC721(contracteNFT).setApprovalForAll(subhastaProxy, true);
        // (bool okApprove, ) = contracteNFT.call(dadesAprovacio);
        console.log("Aprovacio ok");
        // Pas 2: Venedor crea la subhasta
        bytes memory dadesCreacio = abi.encodeWithSignature(
            "novaSubhasta(address,uint48,address,uint256)",
            Venedor,
            uint48(60), // durada 60 segons
            contracteNFT,
            tokenId
        );

        (bool success1, bytes memory result1) = subhastaProxy.call{value: 0}(dadesCreacio);
        require(success1, "Error a novaSubhasta");
        uint256 idSubhasta = abi.decode(result1, (uint256));
        console.log("Subhasta creada amb ID:", idSubhasta);
        vm.stopBroadcast();
    }
}

contract CreacioOferta is Script {
    function run() external {
        address contracteNFT = vm.envAddress("ADRECA_CONTRACTENFT");
        address subhastaProxy = vm.envAddress("ADRECA_SUBHASTA");
        address Licitador = vm.addr(clauPrivadaLicitador);
        address Venedor = vm.addr(clauPrivadaVenedor);
        uint256 idSubhasta = vm.envUint("ID_SUBHASTA");

        console.log("Adreca contracte ", subhastaProxy);
        console.log("Venedor:", Venedor);
        console.log("Licitador:", Licitador);
        vm.startBroadcast(clauPrivadaLicitador);
        // Pas 3: Usuari Licitador fa una oferta

        bytes memory dadesOferta = abi.encodeWithSignature("novaOferta(uint256)", idSubhasta);

        (bool success2,) = subhastaProxy.call{value: 1 ether}(dadesOferta);
        require(success2, "Error a novaOferta");

        vm.stopBroadcast();
    }
}

contract CreacioSubhastaOferta is Script {
    function run() external {
        // Adreça de contracte utilitzat
        address contracteNFT = vm.envAddress("ADRECA_CONTRACTENFT");
        address subhastaProxy = vm.envAddress("ADRECA_SUBHASTA");
        address Licitador = vm.addr(clauPrivadaLicitador);
        address Venedor = vm.addr(clauPrivadaVenedor);

        console.log("Adreca contracte ", subhastaProxy);
        console.log("Venedor:", Venedor);
        console.log("Licitador:", Licitador);

        vm.startBroadcast(clauPrivadaVenedor);

        // Pas 1: Venedor autoritza subhasta a moure token
        bytes memory dadesAprovacio = abi.encodeWithSignature("setApprovalForAll(address,bool)", subhastaProxy, true);
        (bool okApprove,) = contracteNFT.call(dadesAprovacio);
        require(okApprove, "Error a setApprovalForAll");
        console.log("Aprovacio ok");
        // Pas 2: Venedor crea la subhasta
        bytes memory dadesCreacio = abi.encodeWithSignature(
            "novaSubhasta(address,uint48,address,uint256)",
            Venedor,
            uint48(60), // durada 60 segons
            contracteNFT,
            tokenId
        );

        (bool success1, bytes memory result1) = subhastaProxy.call{value: 0}(dadesCreacio);
        require(success1, "Error a novaSubhasta");
        uint256 idSubhasta = abi.decode(result1, (uint256));
        console.log("Subhasta creada amb ID:", idSubhasta);
        vm.stopBroadcast();

        vm.startBroadcast(clauPrivadaLicitador);
        // Pas 3: Usuari Licitador fa una oferta

        bytes memory dadesOferta = abi.encodeWithSignature("novaOferta(uint256)", idSubhasta);

        (bool success2,) = subhastaProxy.call{value: 1 ether}(dadesOferta);
        require(success2, "Error a novaOferta");

        vm.stopBroadcast();
    }
}

contract Mostra is Script {
    function run() external {
        address Venedor = vm.addr(clauPrivadaVenedor);
        console.log("Adreca venedor: ", Venedor);
        uint256 saldoPrevi = Venedor.balance;
        console.log("Saldo ", saldoPrevi);
    }
}

contract ResolucioSubhasta is Script {
    function run() external {
        address contracteNFT = vm.envAddress("ADRECA_CONTRACTENFT");
        address subhastaProxy = vm.envAddress("ADRECA_SUBHASTA");
        uint256 idSubhasta = vm.envUint("ID_SUBHASTA");
        address Licitador = vm.addr(clauPrivadaLicitador);
        address Venedor = vm.addr(clauPrivadaVenedor);
        console.log("Adreca contracte ", subhastaProxy);
        console.log("Venedor:", Venedor);
        console.log("Licitador:", Licitador);
        // Aconseguim el saldo previ del licitador
        uint256 saldoPrevi = Venedor.balance;

        vm.startBroadcast(clauPrivadaLicitador);
        // Es crida finalitzacio, ho pot cridar qualsevol
        bytes memory dadesFinalitzacio = abi.encodeWithSignature("finalitzacio(uint256)", idSubhasta);
        (bool success2,) = subhastaProxy.call(dadesFinalitzacio);
        vm.stopBroadcast();
        // Comprovem ara qui és l'owner del NFT
        // Comprovem el nou saldo.
        //   require(Venedor.balance == saldoPrevi + (1 ether),'saldo erroni');
        // NFT pertany al guanyador
        //   require(IERC721(contracteNFT).ownerOf(tokenId) == Licitador,'nft no transferit');
    }
}

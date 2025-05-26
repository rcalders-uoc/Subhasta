// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/SubhastaNoActualitzable.sol";
import "../src/NFTTest.sol";
import "../src/ISubhasta.sol";

abstract contract TestSubhastaBase is Test {
    // Participants (adreces de prova)
    address constant VENEDOR1 = address(1);
    address constant VENEDOR2 = address(2);
    address constant LICITADOR1 = address(3);
    address constant LICITADOR2 = address(4);
    address constant LICITADOR3 = address(5);

    // Contractes
    ISubhasta subhasta;
    NFTTest nft;

    uint256 token1;
    uint256 token2;

    function creaSubhasta() internal virtual returns (ISubhasta);

    function setUp() public {
        subhasta = creaSubhasta();
        nft = new NFTTest();

        // Emissio de tokens
        token1 = nft.mint(VENEDOR1);
        token2 = nft.mint(VENEDOR2);

        vm.prank(VENEDOR1);
        nft.setApprovalForAll(address(subhasta), true);

        vm.prank(VENEDOR2);
        nft.setApprovalForAll(address(subhasta), true);

        // balances per a participants
        vm.deal(LICITADOR1, 10 ether);
        vm.deal(LICITADOR2, 10 ether);
        vm.deal(LICITADOR3, 10 ether);
    }

    // Test de creació d'una subhasta
    function testCreacio() public {
        vm.prank(VENEDOR1);
        uint256 id = subhasta.novaSubhasta(
            VENEDOR1,
            1 hours,
            address(nft),
            token1
        );

        assertEq(id, 1);
        assertEq(nft.ownerOf(token1), address(subhasta));
    }

    // Test desenvolupament d'una subhasta
    function testOfertesDevolucions() public {
        vm.prank(VENEDOR1);
        uint256 id = subhasta.novaSubhasta(
            VENEDOR1,
            1 hours,
            address(nft),
            token1
        );

        // Oferta inicial 1 ETH
        vm.prank(LICITADOR1);
        subhasta.novaOferta{value: 1 ether}(id);

        // Oferta massa baixa
        vm.prank(LICITADOR2);
        vm.expectRevert("oferta massa baixa");
        subhasta.novaOferta{value: 0.8 ether}(id);

        // Oferta correcta 1.2 ETH
        vm.prank(LICITADOR2);
        subhasta.novaOferta{value: 1.2 ether}(id);

        // LICITADOR1 reclama devolució
        uint256 saldoPrevi = LICITADOR1.balance;
        vm.prank(LICITADOR1);
        subhasta.devolucio(id);
        assertEq(LICITADOR1.balance, saldoPrevi + 1 ether);

        // saldo del contracte, ha de ser el de la segona oferta
        assertEq(address(subhasta).balance, 1.2 ether);
    }

    // Test de finalització
    function testFinalitzacio() public {
        vm.prank(VENEDOR1);
        uint256 id = subhasta.novaSubhasta(VENEDOR1, 60, address(nft), token1);

        vm.prank(LICITADOR3);
        subhasta.novaOferta{value: 1.4 ether}(id);

        // Finalització prematura
        vm.warp(block.timestamp + 59); // temps 59
        vm.prank(LICITADOR3);
        vm.expectRevert("subhasta encara activa");
        subhasta.finalitzacio(id); // ha de revertir

        // Avancem dos segons addicionals
        vm.warp(block.timestamp + 2); // temps 61

        uint256 saldoPrevi = VENEDOR1.balance;
        vm.prank(LICITADOR3);
        subhasta.finalitzacio(id);

        // venedor ha cobrat
        assertEq(VENEDOR1.balance, saldoPrevi + 1.4 ether);
        // NFT pertany al guanyador
        assertEq(nft.ownerOf(token1), LICITADOR3);
    }

    // Dues subhastes en paral.lel.
    // Verificacio d'independencia de funcionament
    function testParallel() public {
        vm.prank(VENEDOR1);
        uint256 id1 = subhasta.novaSubhasta(VENEDOR1, 60, address(nft), token1);
        vm.prank(VENEDOR2);
        uint256 id2 = subhasta.novaSubhasta(
            VENEDOR2,
            120,
            address(nft),
            token2
        );

        // Ofertes independents
        vm.prank(LICITADOR1);
        subhasta.novaOferta{value: 0.7 ether}(id1);

        vm.prank(LICITADOR2);
        subhasta.novaOferta{value: 1.3 ether}(id2);

        // Avanca el temps
        // Comprova 1a subhasta finalitzada i l'altra no
        vm.warp(block.timestamp + 61); // temps 61 s

        uint256 saldoPrevi1 = VENEDOR1.balance;
        vm.prank(LICITADOR1);
        subhasta.finalitzacio(id1);

        vm.prank(LICITADOR2);
        vm.expectRevert("subhasta encara activa");
        subhasta.finalitzacio(id2);

        vm.warp(block.timestamp + 60); // temps 121 s
        uint256 saldoPrevi2 = VENEDOR2.balance;
        vm.prank(LICITADOR2);
        subhasta.finalitzacio(id2);

        // comprovem que han guanyat els respectius tokens
        assertEq(nft.ownerOf(token1), LICITADOR1);
        assertEq(nft.ownerOf(token2), LICITADOR2);
        // comprovem que venedors han cobrat
        assertEq(VENEDOR1.balance, saldoPrevi1 + 0.7 ether);
        assertEq(VENEDOR2.balance, saldoPrevi2 + 1.3 ether);
    }

    // Subhasta deserta
    function testSubhastaDeserta() public {
        // venedor crea la subhasta
        vm.prank(VENEDOR1);
        uint256 id = subhasta.novaSubhasta(VENEDOR1, 60, address(nft), token1);

        // Avancem el temps fins al final de la subhasta
        // sense que hi hagi cap licitador.
        vm.warp(block.timestamp + 61);

        vm.prank(VENEDOR1);
        subhasta.finalitzacio(id);

        // Comprovem qeu el venedor ha recuperat
        // el token
        assertEq(nft.ownerOf(token1), VENEDOR1);
    }
}

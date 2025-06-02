pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/SubhastaNoActualitzable.sol";
import "../src/NFTTest.sol";
import "../src/ISubhastaV2.sol";
import "./TestSubhastaBase.t.sol";

// Tests específics de la V2
// PENDENT Completar

abstract contract TestSubhastaBaseV2 is TestSubhastaBase {
    function testPreuReserva() public {
        ISubhastaV2 subhastaV2 = ISubhastaV2(address(subhasta));

        // VENEDOR1 crea una subhasta amb preu reserva 2 ether
        vm.prank(VENEDOR1);
        uint256 id = subhastaV2.novaSubhastaPreuReserva(VENEDOR1, 1 hours, address(nft), token1, 2 ether);

        // LICITADOR1 intenta fer una oferta inferior que serà rebutjada
        vm.prank(LICITADOR1);
        vm.expectRevert("oferta inferior reserva");
        subhastaV2.novaOferta{value: 1 ether}(id);

        // LICITADOR1 fa una oferta superior que és acceptada
        vm.prank(LICITADOR1);
        subhastaV2.novaOferta{value: 2.1 ether}(id);
    }

    function testIncrementMinim() public {
        ISubhastaV2 subhastaV2 = ISubhastaV2(address(subhasta));

        // Només el propietari pot establir l'increment mínim
        vm.prank(address(this));
        subhastaV2.estableixIncrementMinim(25); // 2.5%

        // VENEDOR1 crea una subhasta
        vm.prank(VENEDOR1);
        uint256 id = subhastaV2.novaSubhastaPreuReserva(VENEDOR1, 1 hours, address(nft), token1, 0);

        // LICITADOR1 fa una oferta inicial de 1 ether
        vm.prank(LICITADOR1);
        subhastaV2.novaOferta{value: 1 ether}(id);

        // Següent licitació mínima és 1·(1+2,5%)=1,025.

        // LICITADOR2 ofereix increment massa petit
        vm.prank(LICITADOR2);
        vm.expectRevert("increment massa petit");
        subhastaV2.novaOferta{value: 1.02 ether}(id);

        // LICITADOR2 ofereix increment suficient
        vm.prank(LICITADOR2);
        subhastaV2.novaOferta{value: 1.03 ether}(id);
    }

    function testCancellacioVenedor() public {
        // El venedor crea una subhasta
        ISubhastaV2 subhastaV2 = ISubhastaV2(address(subhasta));
        vm.prank(VENEDOR1);
        uint256 id = subhastaV2.novaSubhastaPreuReserva(VENEDOR1, 1 hours, address(nft), token1, 0);

        // La subhasta és cancel·lada correctament
        vm.prank(VENEDOR1);
        subhastaV2.cancellacioSubhastaVenedor(id);
        assertEq(nft.ownerOf(token1), VENEDOR1);

        // No pot ser cancel·lada un segon cop
        vm.prank(VENEDOR1);
        vm.expectRevert("ja finalitzada");
        subhastaV2.cancellacioSubhastaVenedor(id);
    }

    function testCancellacioAmbOferta() public {
        ISubhastaV2 subhastaV2 = ISubhastaV2(address(subhasta));

        // El venedor crea una subhasta
        vm.prank(VENEDOR1);
        uint256 id = subhastaV2.novaSubhastaPreuReserva(VENEDOR1, 1 hours, address(nft), token1, 0);

        // Un licitador fa una oferta
        vm.prank(LICITADOR1);
        subhastaV2.novaOferta{value: 1 ether}(id);

        // El venedor no pot cancel·lar
        vm.prank(VENEDOR1);
        vm.expectRevert("ja hi ha una oferta");
        subhastaV2.cancellacioSubhastaVenedor(id);
    }
}

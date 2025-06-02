// TestUpgradeBase comprova que les operacions iniciades en la versió 1
// es poden continuar correctament en una versió posterior

import "forge-std/Test.sol";
import "../src/SubhastaNoActualitzable.sol";
import "../src/NFTTest.sol";
import "../src/ISubhasta.sol";
// Participants (adreces de prova)

abstract contract TestUpgradeBase is Test {
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
    function actualitzaSubhasta() internal virtual returns (ISubhasta);

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

        // saldos per a participants
        vm.deal(LICITADOR1, 10 ether);
        vm.deal(LICITADOR2, 10 ether);
        vm.deal(LICITADOR3, 10 ether);
    }

    //
}

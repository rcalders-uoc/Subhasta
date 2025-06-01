pragma solidity ^0.8.28;

import "./TestSubhastaActualitzableBase.t.sol";
import "../src/SubhastaTransparent.sol";
import "../src/SubhastaTransparentV2.sol";

import "../src/ISubhasta.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";

contract TestSubhastaTransparentV1V2 is TestSubhastaActualitzableBase {
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function setUp2() public  {
        //super.setUp();
        subhasta = ISubhasta(address(0)); // Reset subhasta
        creaSubhasta();
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

    function creaSubhasta() internal override {
        address admin = tx.origin;
        console.log("Admin (tx.origin):", admin);

        SubhastaTransparent impl = new SubhastaTransparent();
        bytes memory initData = abi.encodeCall(SubhastaTransparent.initialize, (admin));

        vm.prank(admin);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            admin,
            initData
        );
        subhasta = ISubhasta(address(proxy));
    }

    function actualitzaSubhasta() internal override {
            SubhastaTransparentV2 newImpl = new SubhastaTransparentV2();
    
    address proxyAdmin = address(uint160(uint256(vm.load(address(subhasta), _ADMIN_SLOT))));
       vm.prank(tx.origin);
     //  vm.prank(tx.origin);
        (bool success, bytes memory returnData) = address(subhasta).call(
            abi.encodeWithSignature("upgradeTo(address)", address(newImpl))
        );
        if (!success) {
            console.log("Revert data:");
            console.logBytes(returnData);
        } else 
        console.log("Upgrade OK");
    }
}
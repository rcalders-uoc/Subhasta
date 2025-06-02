pragma solidity ^0.8.28;

import "./TestSubhastaBaseActualitzacioV2.t.sol";
import "../src/SubhastaTransparent.sol";
import "../src/SubhastaTransparentV2.sol";

import "../src/ISubhasta.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";

contract TestSubhastaTransparentV2V2 is TestSubhastaBaseActualitzacioV2 {
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function creaSubhasta() internal override returns (ISubhasta) {
        address admin = tx.origin;
        console.log("Admin (tx.origin):", admin);

        SubhastaTransparentV2 impl = new SubhastaTransparentV2();
        bytes memory initData = abi.encodeCall(SubhastaTransparentV2.initialize, (admin));

        vm.prank(admin);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(impl), admin, initData);
        return ISubhasta(address(proxy));
    }

    function actualitzaSubhasta() internal override {
        SubhastaTransparentV2 newImpl = new SubhastaTransparentV2();

        address proxyAdmin = address(uint160(uint256(vm.load(address(subhasta), _ADMIN_SLOT))));
        vm.prank(tx.origin);
        //  vm.prank(tx.origin);
        (bool success, bytes memory returnData) =
            address(subhasta).call(abi.encodeWithSignature("upgradeTo(address)", address(newImpl)));
        if (!success) {
            console.log("Revert data:");
            console.logBytes(returnData);
        } else {
            console.log("Upgrade OK");
        }
    }
}

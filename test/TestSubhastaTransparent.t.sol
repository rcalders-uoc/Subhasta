pragma solidity ^0.8.28;
import "./TestSubhastaBase.t.sol";
import "../src/SubhastaTransparent.sol";
import "../src/ISubhasta.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TestSubhastaTransparent is TestSubhastaBase {
    function creaSubhasta() internal override returns (ISubhasta) {
        address admin = tx.origin;
        SubhastaTransparent impltransp = new SubhastaTransparent();

        bytes memory inittransp = abi.encodeCall(
            SubhastaTransparent.initialize,
            (admin)
        );

        TransparentUpgradeableProxy proxytransp = new TransparentUpgradeableProxy(
                address(impltransp),
                admin,
                inittransp
            );
        return ISubhasta(address(proxytransp));
    }

}
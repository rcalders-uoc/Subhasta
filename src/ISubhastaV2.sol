import "../src/ISubhasta.sol";

interface ISubhastaV2 is ISubhasta {
    function novaSubhastaPreuReserva(
        address venedor,
        uint48 duradaSubhasta,
        address contracteNFT,
        uint256 idToken,
        uint256 preuReserva
    ) external returns (uint256);
    function cancellacioSubhastaVenedor(uint256 idSubhasta) external;
    function estableixIncrementMinim(uint256 percentatge) external;
}

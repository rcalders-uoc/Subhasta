interface ISubhasta {
    function initialize(address propietari) external;

    function novaSubhasta(
        address venedor,
        uint48 duradaSubhasta,
        address contracteNFT,
        uint256 idToken) external  returns (uint256 idSubhasta);

    function novaOferta(uint256 id) external payable;
    function devolucio(uint256 id) external;
    function finalitzacio(uint256 id) external;
}
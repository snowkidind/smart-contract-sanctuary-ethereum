// SPDX-License-Identifier: GPL-3.0-only
//
// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
//   ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
// ▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
//
//

pragma solidity 0.8.17;

import "./AltBn128.sol";

/// @title BLS signatures verification
/// @dev Library for verification of 2-pairing-check BLS signatures, including
///      basic, aggregated, or reconstructed threshold BLS signatures, generated
///      using the AltBn128 curve.
library BLS {
    /// @dev Creates a signature over message using the provided secret key.
    function sign(bytes memory message, uint256 secretKey)
        external
        view
        returns (bytes memory)
    {
        AltBn128.G1Point memory p_1 = AltBn128.g1HashToPoint(message);
        AltBn128.G1Point memory p_2 = AltBn128.scalarMultiply(p_1, secretKey);

        return AltBn128.g1Marshal(p_2);
    }

    /// @dev Wraps the functionality of BLS.verify, but hashes a message to
    ///      a point on G1 and marshal to bytes first to allow raw bytes
    ///      verification.
    function verifyBytes(
        bytes memory publicKey,
        bytes memory message,
        bytes memory signature
    ) external view returns (bool) {
        AltBn128.G1Point memory point = AltBn128.g1HashToPoint(message);
        bytes memory messageAsPoint = AltBn128.g1Marshal(point);

        return verify(publicKey, messageAsPoint, signature);
    }

    /// @dev Verify performs the pairing operation to check if the signature
    ///      is correct for the provided message and the corresponding public
    ///      key. Public key must be a valid point on G2 curve in an
    ///      uncompressed format. Message must be a valid point on G1 curve in
    ///      an uncompressed format. Signature must be a valid point on G1
    ///      curve in an uncompressed format.
    function verify(
        bytes memory publicKey,
        bytes memory message,
        bytes memory signature
    ) public view returns (bool) {
        AltBn128.G1Point memory _signature = AltBn128.g1Unmarshal(signature);

        return
            _verify(
                AltBn128.g2Unmarshal(publicKey),
                AltBn128.g1Unmarshal(message),
                _signature
            );
    }

    function _verify(
        AltBn128.G2Point memory publicKey,
        AltBn128.G1Point memory message,
        AltBn128.G1Point memory signature
    ) public view returns (bool) {
        return
            AltBn128.pairing(
                AltBn128.G1Point(signature.x, AltBn128.getP() - signature.y),
                AltBn128.g2(),
                message,
                publicKey
            );
    }
}

// SPDX-License-Identifier: GPL-3.0-only
//
// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
//   ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
// ▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
//
//

pragma solidity 0.8.17;

import "./ModUtils.sol";

/// @title Operations on alt_bn128
/// @dev Implementations of common elliptic curve operations on Ethereum's
///      (poorly named) alt_bn128 curve. Whenever possible, use post-Byzantium
///      pre-compiled contracts to offset gas costs. Note that these
///      pre-compiles might not be available on all (eg private) chains.
library AltBn128 {
    using ModUtils for uint256;

    // G1Point implements a point in G1 group.
    struct G1Point {
        uint256 x;
        uint256 y;
    }

    // gfP2 implements a field of size p² as a quadratic extension of the base
    // field.
    struct gfP2 {
        uint256 x;
        uint256 y;
    }

    // G2Point implements a point in G2 group.
    struct G2Point {
        gfP2 x;
        gfP2 y;
    }

    // p is a prime over which we form a basic field
    // Taken from go-ethereum/crypto/bn256/cloudflare/constants.go
    uint256 internal constant p =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /// @dev Gets generator of G1 group.
    ///      Taken from go-ethereum/crypto/bn256/cloudflare/curve.go
    uint256 internal constant g1x = 1;
    uint256 internal constant g1y = 2;

    /// @dev Gets generator of G2 group.
    ///      Taken from go-ethereum/crypto/bn256/cloudflare/twist.go
    uint256 internal constant g2xx =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 internal constant g2xy =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 internal constant g2yx =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 internal constant g2yy =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;

    /// @dev Gets twist curve B constant.
    ///      Taken from go-ethereum/crypto/bn256/cloudflare/twist.go
    uint256 internal constant twistBx =
        266929791119991161246907387137283842545076965332900288569378510910307636690;
    uint256 internal constant twistBy =
        19485874751759354771024239261021720505790618469301721065564631296452457478373;

    /// @dev Gets root of the point where x and y are equal.
    uint256 internal constant hexRootX =
        21573744529824266246521972077326577680729363968861965890554801909984373949499;
    uint256 internal constant hexRootY =
        16854739155576650954933913186877292401521110422362946064090026408937773542853;

    /// @dev g1YFromX computes a Y value for a G1 point based on an X value.
    ///      This computation is simply evaluating the curve equation for Y on a
    ///      given X, and allows a point on the curve to be represented by just
    ///      an X value + a sign bit.
    function g1YFromX(uint256 x) internal view returns (uint256) {
        return ((x.modExp(3, p) + 3) % p).modSqrt(p);
    }

    /// @dev Hash a byte array message, m, and map it deterministically to a
    ///      point on G1. Note that this approach was chosen for its simplicity
    ///      and lower gas cost on the EVM, rather than good distribution of
    ///      points on G1.
    function g1HashToPoint(bytes memory m)
        internal
        view
        returns (G1Point memory)
    {
        unchecked {
            bytes32 h = sha256(m);
            uint256 x = uint256(h) % p;
            uint256 y;

            while (true) {
                y = g1YFromX(x);
                if (y > 0) {
                    return G1Point(x, y);
                }
                x += 1;
            }
        }
    }

    /// @dev Decompress a point on G1 from a single uint256.
    function g1Decompress(bytes32 m) internal view returns (G1Point memory) {
        unchecked {
            bytes32 mX = bytes32(0);
            bytes1 leadX = m[0] & 0x7f;
            // slither-disable-next-line incorrect-shift
            uint256 mask = 0xff << (31 * 8);
            mX = (m & ~bytes32(mask)) | (leadX >> 0);

            uint256 x = uint256(mX);
            uint256 y = g1YFromX(x);

            if (parity(y) != (m[0] & 0x80) >> 7) {
                y = p - y;
            }

            require(
                isG1PointOnCurve(G1Point(x, y)),
                "Malformed bn256.G1 point."
            );

            return G1Point(x, y);
        }
    }

    /// @dev Wraps the point addition pre-compile introduced in Byzantium.
    ///      Returns the sum of two points on G1. Revert if the provided points
    ///      are not on the curve.
    function g1Add(G1Point memory a, G1Point memory b)
        internal
        view
        returns (G1Point memory c)
    {
        assembly {
            let arg := mload(0x40)
            mstore(arg, mload(a))
            mstore(add(arg, 0x20), mload(add(a, 0x20)))
            mstore(add(arg, 0x40), mload(b))
            mstore(add(arg, 0x60), mload(add(b, 0x20)))
            // 0x60 is the ECADD precompile address
            if iszero(staticcall(not(0), 0x06, arg, 0x80, c, 0x40)) {
                revert(0, 0)
            }
        }
    }

    /// @dev Returns true if G1 point is on the curve.
    function isG1PointOnCurve(G1Point memory point)
        internal
        view
        returns (bool)
    {
        return point.y.modExp(2, p) == (point.x.modExp(3, p) + 3) % p;
    }

    /// @dev Wraps the scalar point multiplication pre-compile introduced in
    ///      Byzantium. The result of a point from G1 multiplied by a scalar
    ///      should match the point added to itself the same number of times.
    ///      Revert if the provided point isn't on the curve.
    function scalarMultiply(G1Point memory p_1, uint256 scalar)
        internal
        view
        returns (G1Point memory p_2)
    {
        assembly {
            let arg := mload(0x40)
            mstore(arg, mload(p_1))
            mstore(add(arg, 0x20), mload(add(p_1, 0x20)))
            mstore(add(arg, 0x40), scalar)
            // 0x07 is the ECMUL precompile address
            if iszero(staticcall(not(0), 0x07, arg, 0x60, p_2, 0x40)) {
                revert(0, 0)
            }
        }
    }

    /// @dev Wraps the pairing check pre-compile introduced in Byzantium.
    ///      Returns the result of a pairing check of 2 pairs
    ///      (G1 p1, G2 p2) (G1 p3, G2 p4)
    function pairing(
        G1Point memory p1,
        G2Point memory p2,
        G1Point memory p3,
        G2Point memory p4
    ) internal view returns (bool result) {
        uint256 _c;
        assembly {
            let c := mload(0x40)
            let arg := add(c, 0x20)

            mstore(arg, mload(p1))
            mstore(add(arg, 0x20), mload(add(p1, 0x20)))

            let p2x := mload(p2)
            mstore(add(arg, 0x40), mload(p2x))
            mstore(add(arg, 0x60), mload(add(p2x, 0x20)))

            let p2y := mload(add(p2, 0x20))
            mstore(add(arg, 0x80), mload(p2y))
            mstore(add(arg, 0xa0), mload(add(p2y, 0x20)))

            mstore(add(arg, 0xc0), mload(p3))
            mstore(add(arg, 0xe0), mload(add(p3, 0x20)))

            let p4x := mload(p4)
            mstore(add(arg, 0x100), mload(p4x))
            mstore(add(arg, 0x120), mload(add(p4x, 0x20)))

            let p4y := mload(add(p4, 0x20))
            mstore(add(arg, 0x140), mload(p4y))
            mstore(add(arg, 0x160), mload(add(p4y, 0x20)))

            // call(gasLimit, to, value, inputOffset, inputSize, outputOffset, outputSize)
            if iszero(staticcall(not(0), 0x08, arg, 0x180, c, 0x20)) {
                revert(0, 0)
            }
            _c := mload(c)
        }
        return _c != 0;
    }

    function getP() internal pure returns (uint256) {
        return p;
    }

    function g1() internal pure returns (G1Point memory) {
        return G1Point(g1x, g1y);
    }

    function g2() internal pure returns (G2Point memory) {
        return G2Point(gfP2(g2xx, g2xy), gfP2(g2yx, g2yy));
    }

    /// @dev g2YFromX computes a Y value for a G2 point based on an X value.
    ///      This computation is simply evaluating the curve equation for Y on a
    ///      given X, and allows a point on the curve to be represented by just
    ///      an X value + a sign bit.
    function g2YFromX(gfP2 memory _x) internal pure returns (gfP2 memory y) {
        (uint256 xx, uint256 xy) = _gfP2CubeAddTwistB(_x.x, _x.y);

        // Using formula y = x ^ (p^2 + 15) / 32 from
        // https://github.com/ethereum/beacon_chain/blob/master/beacon_chain/utils/bls.py
        // (p^2 + 15) / 32 results into a big 512bit value, so breaking it to two uint256 as (a * a + b)
        uint256 a = 3869331240733915743250440106392954448556483137451914450067252501901456824595;
        uint256 b = 146360017852723390495514512480590656176144969185739259173561346299185050597;

        (uint256 xbx, uint256 xby) = _gfP2Pow(xx, xy, b);
        (uint256 yax, uint256 yay) = _gfP2Pow(xx, xy, a);
        (uint256 ya2x, uint256 ya2y) = _gfP2Pow(yax, yay, a);
        (y.x, y.y) = _gfP2Multiply(ya2x, ya2y, xbx, xby);

        // Multiply y by hexRoot constant to find correct y.
        while (!_g2X2y(xx, xy, y.x, y.y)) {
            (y.x, y.y) = _gfP2Multiply(y.x, y.y, hexRootX, hexRootY);
        }
    }

    /// @dev Compress a point on G1 to a single uint256 for serialization.
    function g1Compress(G1Point memory point) internal pure returns (bytes32) {
        bytes32 m = bytes32(point.x);

        bytes1 leadM = m[0] | (parity(point.y) << 7);
        // slither-disable-next-line incorrect-shift
        uint256 mask = 0xff << (31 * 8);
        m = (m & ~bytes32(mask)) | (leadM >> 0);

        return m;
    }

    /// @dev Compress a point on G2 to a pair of uint256 for serialization.
    function g2Compress(G2Point memory point)
        internal
        pure
        returns (bytes memory)
    {
        bytes32 m = bytes32(point.x.x);

        bytes1 leadM = m[0] | (parity(point.y.x) << 7);
        // slither-disable-next-line incorrect-shift
        uint256 mask = 0xff << (31 * 8);
        m = (m & ~bytes32(mask)) | (leadM >> 0);

        return abi.encodePacked(m, bytes32(point.x.y));
    }

    /// @dev Unmarshals a point on G1 from bytes in an uncompressed form.
    function g1Unmarshal(bytes memory m)
        internal
        pure
        returns (G1Point memory)
    {
        require(m.length == 64, "Invalid G1 bytes length");

        bytes32 x;
        bytes32 y;

        assembly {
            x := mload(add(m, 0x20))
            y := mload(add(m, 0x40))
        }

        return G1Point(uint256(x), uint256(y));
    }

    /// @dev Marshals a point on G1 to bytes form.
    function g1Marshal(G1Point memory point)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory m = new bytes(64);
        bytes32 x = bytes32(point.x);
        bytes32 y = bytes32(point.y);

        assembly {
            mstore(add(m, 32), x)
            mstore(add(m, 64), y)
        }

        return m;
    }

    /// @dev Unmarshals a point on G2 from bytes in an uncompressed form.
    function g2Unmarshal(bytes memory m)
        internal
        pure
        returns (G2Point memory)
    {
        require(m.length == 128, "Invalid G2 bytes length");

        uint256 xx;
        uint256 xy;
        uint256 yx;
        uint256 yy;

        assembly {
            xx := mload(add(m, 0x20))
            xy := mload(add(m, 0x40))
            yx := mload(add(m, 0x60))
            yy := mload(add(m, 0x80))
        }

        return G2Point(gfP2(xx, xy), gfP2(yx, yy));
    }

    /// @dev Decompress a point on G2 from a pair of uint256.
    function g2Decompress(bytes memory m)
        internal
        pure
        returns (G2Point memory)
    {
        require(m.length == 64, "Invalid G2 compressed bytes length");

        bytes32 x1;
        bytes32 x2;
        uint256 temp;

        // Extract two bytes32 from bytes array
        assembly {
            temp := add(m, 32)
            x1 := mload(temp)
            temp := add(m, 64)
            x2 := mload(temp)
        }

        bytes32 mX = bytes32(0);
        bytes1 leadX = x1[0] & 0x7f;
        // slither-disable-next-line incorrect-shift
        uint256 mask = 0xff << (31 * 8);
        mX = (x1 & ~bytes32(mask)) | (leadX >> 0);

        gfP2 memory x = gfP2(uint256(mX), uint256(x2));
        gfP2 memory y = g2YFromX(x);

        if (parity(y.x) != (m[0] & 0x80) >> 7) {
            y.x = p - y.x;
            y.y = p - y.y;
        }

        return G2Point(x, y);
    }

    /// @dev Returns the sum of two gfP2 field elements.
    function gfP2Add(gfP2 memory a, gfP2 memory b)
        internal
        pure
        returns (gfP2 memory)
    {
        return gfP2(addmod(a.x, b.x, p), addmod(a.y, b.y, p));
    }

    /// @dev Returns multiplication of two gfP2 field elements.
    function gfP2Multiply(gfP2 memory a, gfP2 memory b)
        internal
        pure
        returns (gfP2 memory)
    {
        return
            gfP2(
                addmod(mulmod(a.x, b.y, p), mulmod(b.x, a.y, p), p),
                addmod(mulmod(a.y, b.y, p), p - mulmod(a.x, b.x, p), p)
            );
    }

    /// @dev Returns gfP2 element to the power of the provided exponent.
    function gfP2Pow(gfP2 memory _a, uint256 _exp)
        internal
        pure
        returns (gfP2 memory result)
    {
        (uint256 x, uint256 y) = _gfP2Pow(_a.x, _a.y, _exp);
        return gfP2(x, y);
    }

    function gfP2Square(gfP2 memory a) internal pure returns (gfP2 memory) {
        return gfP2Multiply(a, a);
    }

    function gfP2Cube(gfP2 memory a) internal pure returns (gfP2 memory) {
        return gfP2Multiply(a, gfP2Square(a));
    }

    function gfP2CubeAddTwistB(gfP2 memory a)
        internal
        pure
        returns (gfP2 memory)
    {
        (uint256 x, uint256 y) = _gfP2CubeAddTwistB(a.x, a.y);
        return gfP2(x, y);
    }

    /// @dev Returns true if G2 point's y^2 equals x.
    function g2X2y(gfP2 memory x, gfP2 memory y) internal pure returns (bool) {
        gfP2 memory y2;
        y2 = gfP2Square(y);

        return (y2.x == x.x && y2.y == x.y);
    }

    /// @dev Returns true if G2 point is on the curve.
    function isG2PointOnCurve(G2Point memory point)
        internal
        pure
        returns (bool)
    {
        (uint256 y2x, uint256 y2y) = _gfP2Square(point.y.x, point.y.y);
        (uint256 x3x, uint256 x3y) = _gfP2CubeAddTwistB(point.x.x, point.x.y);

        return (y2x == x3x && y2y == x3y);
    }

    function twistB() private pure returns (gfP2 memory) {
        return gfP2(twistBx, twistBy);
    }

    function hexRoot() private pure returns (gfP2 memory) {
        return gfP2(hexRootX, hexRootY);
    }

    /// @dev Calculates whether the provided number is even or odd.
    /// @return 0x01 if y is an even number and 0x00 if it's odd.
    function parity(uint256 value) private pure returns (bytes1) {
        return bytes32(value)[31] & 0x01;
    }

    function _gfP2Add(
        uint256 ax,
        uint256 ay,
        uint256 bx,
        uint256 by
    ) private pure returns (uint256 x, uint256 y) {
        x = addmod(ax, bx, p);
        y = addmod(ay, by, p);
    }

    function _gfP2Multiply(
        uint256 ax,
        uint256 ay,
        uint256 bx,
        uint256 by
    ) private pure returns (uint256 x, uint256 y) {
        x = addmod(mulmod(ax, by, p), mulmod(bx, ay, p), p);
        y = addmod(mulmod(ay, by, p), p - mulmod(ax, bx, p), p);
    }

    function _gfP2CubeAddTwistB(uint256 ax, uint256 ay)
        private
        pure
        returns (uint256 x, uint256 y)
    {
        (uint256 a3x, uint256 a3y) = _gfP2Cube(ax, ay);
        return _gfP2Add(a3x, a3y, twistBx, twistBy);
    }

    function _gfP2Pow(
        uint256 _ax,
        uint256 _ay,
        uint256 _exp
    ) private pure returns (uint256 x, uint256 y) {
        uint256 exp = _exp;
        x = 0;
        y = 1;
        uint256 ax = _ax;
        uint256 ay = _ay;

        // Reduce exp dividing by 2 gradually to 0 while computing final
        // result only when exp is an odd number.
        while (exp > 0) {
            if (parity(exp) == 0x01) {
                (x, y) = _gfP2Multiply(x, y, ax, ay);
            }

            unchecked {
                exp = exp / 2;
            }
            (ax, ay) = _gfP2Multiply(ax, ay, ax, ay);
        }
    }

    function _gfP2Square(uint256 _ax, uint256 _ay)
        private
        pure
        returns (uint256 x, uint256 y)
    {
        return _gfP2Multiply(_ax, _ay, _ax, _ay);
    }

    function _gfP2Cube(uint256 _ax, uint256 _ay)
        private
        pure
        returns (uint256 x, uint256 y)
    {
        (uint256 _bx, uint256 _by) = _gfP2Square(_ax, _ay);
        return _gfP2Multiply(_ax, _ay, _bx, _by);
    }

    function _g2X2y(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) private pure returns (bool) {
        (uint256 y2x, uint256 y2y) = _gfP2Square(yx, yy);

        return (y2x == xx && y2y == xy);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
//
// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
//   ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
// ▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
//
//

pragma solidity 0.8.17;

library ModUtils {
    /// @dev Wraps the modular exponent pre-compile introduced in Byzantium.
    ///      Returns base^exponent mod p.
    function modExp(
        uint256 base,
        uint256 exponent,
        uint256 p
    ) internal view returns (uint256 o) {
        assembly {
            // Args for the precompile: [<length_of_BASE> <length_of_EXPONENT>
            // <length_of_MODULUS> <BASE> <EXPONENT> <MODULUS>]
            let output := mload(0x40)
            let args := add(output, 0x20)
            mstore(args, 0x20)
            mstore(add(args, 0x20), 0x20)
            mstore(add(args, 0x40), 0x20)
            mstore(add(args, 0x60), base)
            mstore(add(args, 0x80), exponent)
            mstore(add(args, 0xa0), p)

            // 0x05 is the modular exponent contract address
            if iszero(staticcall(not(0), 0x05, args, 0xc0, output, 0x20)) {
                revert(0, 0)
            }
            o := mload(output)
        }
    }

    /// @dev Calculates and returns the square root of a mod p if such a square
    ///      root exists. The modulus p must be an odd prime. If a square root
    ///      does not exist, function returns 0.
    function modSqrt(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            if (legendre(a, p) != 1) {
                return 0;
            }

            if (a == 0) {
                return 0;
            }

            if (p % 4 == 3) {
                return modExp(a, (p + 1) / 4, p);
            }

            uint256 s = p - 1;
            uint256 e = 0;

            while (s % 2 == 0) {
                s = s / 2;
                e = e + 1;
            }

            // Note the smaller int- finding n with Legendre symbol or -1
            // should be quick
            uint256 n = 2;
            while (legendre(n, p) != -1) {
                n = n + 1;
            }

            uint256 x = modExp(a, (s + 1) / 2, p);
            uint256 b = modExp(a, s, p);
            uint256 g = modExp(n, s, p);
            uint256 r = e;
            uint256 gs = 0;
            uint256 m = 0;
            uint256 t = b;

            while (true) {
                t = b;
                m = 0;

                for (m = 0; m < r; m++) {
                    if (t == 1) {
                        break;
                    }
                    t = modExp(t, 2, p);
                }

                if (m == 0) {
                    return x;
                }

                gs = modExp(g, uint256(2)**(r - m - 1), p);
                g = (gs * gs) % p;
                x = (x * gs) % p;
                b = (b * g) % p;
                r = m;
            }
        }
    }

    /// @dev Calculates the Legendre symbol of the given a mod p.
    /// @return Returns 1 if a is a quadratic residue mod p, -1 if it is
    ///         a non-quadratic residue, and 0 if a is 0.
    function legendre(uint256 a, uint256 p) internal view returns (int256) {
        unchecked {
            uint256 raised = modExp(a, (p - 1) / uint256(2), p);

            if (raised == 0 || raised == 1) {
                return int256(raised);
            } else if (raised == p - 1) {
                return -1;
            }

            require(false, "Failed to calculate legendre.");
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CurveValidatorPlus {
    uint256 constant W0x = 7590971729312603494;
    uint256 constant W0y = 4025301139565492703;
    uint256[] public X = [
        2454386166295847726,
        1394489484373924978,
        61603571658607611,
        9993263628066138196,
        1304331519679318216,
        10202137592169949396,
        348470280807485805
    ];

    bool public isSolved;

    function modExp(uint256 base, uint256 exp, uint256 mod) public pure returns (uint256) {
        uint256 result = 1;
        base = base % mod;
        while (exp > 0) {
            if (exp % 2 == 1) {
                result = (result * base) % mod;
            }
            exp = exp >> 1;
            base = (base * base) % mod;
        }
        return result;
    }

    function isValidParams(uint256 p, uint256 A, uint256 B) public pure returns (bool) {
        if (p <= 2**63 || p >= 2**64) {
            return false;
        }

        if (A < p / 2 || A >= p || B < p / 2 || B >= p) {
            return false;
        }

        if ((4 * A**3 + 27 * B**2) % p == 0) {
            return false;
        }

        return true;
    }

    function isPointOnCurve(uint256 x, uint256 y, uint256 A, uint256 B, uint256 p) public pure returns (bool) {
        return (y**2) % p == (x**3 + A*x + B) % p;
    }

    function pointAdd(
        uint256 x1, uint256 y1,
        uint256 x2, uint256 y2,
        uint256 A, uint256 /*B*/, uint256 p
    ) public pure returns (uint256 x3, uint256 y3) {
        if (x1 == x2 && y1 == y2) {
            uint256 s = (3 * x1**2 + A) * modInverse(2 * y1, p) % p;
            x3 = (s**2 - 2 * x1) % p;
            y3 = (s * (p + x1 - x3) - y1) % p;
        } else {
            uint256 s = (p + y2 - y1) * modInverse(p + x2 - x1, p) % p;
            x3 = (s**2 - x1 - x2) % p;
            y3 = (s * (p + x1 - x3) - y1) % p;
        }
    }

    function modInverse(uint256 a, uint256 p) public pure returns (uint256) {
        return power(a, p - 2, p);
    }

    function power(uint256 a, uint256 b, uint256 p) public pure returns (uint256) {
        uint256 result = 1;
        a = a % p;
        while (b > 0) {
            if (b % 2 == 1) {
                result = (result * a) % p;
            }
            a = (a * a) % p;
            b = b / 2;
        }
        return result;
    }

    function validate(uint256 p, uint256 A, uint256 B, uint256 Gx, uint256 Gy) public {
        require(isValidParams(p, A, B), "Invalid parameters");
        require(isPointOnCurve(Gx, Gy, A, B, p), "Point G is not on the curve");

        uint256 x;
        uint256 y;
        (x, y) = (W0x, W0y);
        for (uint256 n = 1; n <= 7; n++) {
            (x, y) = pointAdd(x, y, Gx, Gy, A, B, p);
            require(x == X[n-1], "Mismatch in x-coordinates for n");
        }

        isSolved = true;
    }
}
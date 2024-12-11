// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CurveValidator {
    uint256 constant p = 10815735905440749559;
    uint256 constant A = 7355136236241731806;
    uint256 constant B = 5612508011909152239;
    uint256 constant W0x = 3382663674857988534;
    uint256 constant W0y = 1617325850231501001;
    uint256[] public X = [1352982446166918000, 4602210764041523003, 9224795417909693174, 3703418564031327735, 6738096436227113885, 7668366238453017480, 8230454484836072580];

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

    function isPointOnCurve(uint256 x, uint256 y) public pure returns (bool) {
        return (y**2) % p == (x**3 + A*x + B) % p;
    }

    function pointAdd(uint256 x1, uint256 y1, uint256 x2, uint256 y2) public pure returns (uint256 x3, uint256 y3) {
        if (x1 == x2 && y1 == y2) {
            uint256 s = (3 * x1**2 + A) * modInverse(2 * y1) % p;
            x3 = (s**2 - 2 * x1) % p;
            y3 = (s * (p + x1 - x3) - y1) % p;
        } else {
            uint256 s = (p + y2 - y1) * modInverse(p + x2 - x1) % p;
            x3 = (s**2 - x1 - x2) % p;
            y3 = (s * (p + x1 - x3) - y1) % p;
        }
    }

    function modInverse(uint256 u) public pure returns (uint256) {
        // pow(u,-1,p)
        uint256 result = 1;
        uint256 v = p - 2;
        u = u % p;
        while (v > 0) {
            if (v % 2 == 1) {
                result = (result * u) % p;
            }
            u = (u * u) % p;
            v = v / 2;
        }
        return result;
    }

    function validate(uint256 Gx, uint256 Gy) public {
        require(isPointOnCurve(Gx, Gy), "Point G is not on the curve");

        uint256 x;
        uint256 y;
        (x, y) = (W0x, W0y);
        for (uint256 n = 1; n <= 7; n++) {
            (x, y) = pointAdd(x, y, Gx, Gy);
            require(x == X[n-1], "Mismatch in x-coordinates for n");
        }

        isSolved = true;
    }
}
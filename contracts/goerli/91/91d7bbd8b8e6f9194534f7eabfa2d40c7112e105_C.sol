/**
 *Submitted for verification at Etherscan.io on 2022-12-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
1) “1” 혹은 “a”를 넣었을 때 “1111“ 혹은 ”aaaa”를 반환하는 함수를 만드세요. Input값은 숫자와 문자형으로 한정

2) 1,2,3,5 이렇게 4개의 숫자가 주어졌을 때 내림차순(큰 숫자부터 작은 숫자로)으로 정렬시키세요.

3) 연도를 기반으로 세기를 알려주는 함수를 만드세요. Input : 연도, output : 세기 
예시 : 1850년 -> 19세기

4) 첫 수와 끝 수 그리고 총 숫자 수를 알려주었을 때 자동으로 중간 숫자들을 채워 등차수열을 완성하세요. 
예시 : 1,7,3 -> 1,4,7 // 1,9,5 -> 1,3,5,7,9

5) 소인수분해를 해주는 함수를 구현하세요. 
예시 : 6 -> 2,3 // 45 -> 3,3,5 // 180 -> 2,2,3,3,5 
450 -> 2,3,3,5,5 // 105 -> 3,5,7 

6) 가장 큰 4개의 숫자만 남겨놓는 array를 구현하세요. 
예시 : [1,3,5,6] -> 2 삽입 -> [2,3,5,6] -> 7 삽입 -> [3,5,6,7] -> 6 삽입 -> [5,6,6,7] -> 3 삽입 -> [5,6,6,7]

7) 100자 이내로만 작성할 수 있는 게시판을 만드세요. 언어는 영어만 지원합니다. 

8) 초를 분,시,일로 변환해주는 함수를 구현하세요. 
예시 : 800초 -> 13분 20초

9)  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol 에서 tryadd, add, sub 함수를 도입해오세요.

10) A contract 에 있는 변수 a를 10 증가시켜주는 함수를 B contract에서 구현하세요.
*/

//1) “1” 혹은 “a”를 넣었을 때 “1111“ 혹은 ”aaaa”를 반환하는 함수를 만드세요. Input값은 숫자와 문자형으로 한정
// contract A {
//     uint a;
//     string b;
//     function returnFour (uint _a) public view returns(uint) {
//         if (_a = uint256){
//             return _a;

//         }
        
//     }
// }

//2) 1,2,3,5 이렇게 4개의 숫자가 주어졌을 때 내림차순(큰 숫자부터 작은 숫자로)으로 정렬시키세요.
// contract B{
    // uint a = 1;
    // uint b = 2;
    // uint c = 3;
    // uint d = 5;
//     uint [] array;
//     function descending(uint[] memory _array) public returns(uint[]memory) {
//     }
// }

//3) 연도를 기반으로 세기를 알려주는 함수를 만드세요. Input : 연도, output : 세기  (예시 : 1850년 -> 19세기)
contract C {
    uint year;
    // uint century;
    function yToC(uint _year) public pure returns(uint) {
        uint century = _year/100+1;
        return century;
    }
}

//4) 첫 수와 끝 수 그리고 총 숫자 수를 알려주었을 때 자동으로 중간 숫자들을 채워 등차수열을 완성하세요. 
//예시 : 1,7,3 -> 1,4,7 // 1,9,5 -> 1,3,5,7,9
// contract D {
//     function AA(uint _a, uint _b, uint _c) public view returns(uint[]memory){
//         return
//     }
// }

//5) 소인수분해를 해주는 함수를 구현하세요. 
//예시 : 6 -> 2,3 // 45 -> 3,3,5 // 180 -> 2,2,3,3,5 
//450 -> 2,3,3,5,5 // 105 -> 3,5,7 


/*
6) 가장 큰 4개의 숫자만 남겨놓는 array를 구현하세요. 
예시 : [1,3,5,6] -> 2 삽입 -> [2,3,5,6] -> 7 삽입 -> [3,5,6,7] -> 6 삽입 -> [5,6,6,7] -> 3 삽입 -> [5,6,6,7]

7) 100자 이내로만 작성할 수 있는 게시판을 만드세요. 언어는 영어만 지원합니다. 

8) 초를 분,시,일로 변환해주는 함수를 구현하세요. 
예시 : 800초 -> 13분 20초

9)  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol 에서 tryadd, add, sub 함수를 도입해오세요.


*/

//10) A contract 에 있는 변수 a를 10 증가시켜주는 함수를 B contract에서 구현하세요.
// contract J_1 {
//     uint a;
//     function thisContract()public {

//     }
// }
// contract J_2 {
//     function aPlusTen()public returns(uint) {
//         return 

//     }
// }
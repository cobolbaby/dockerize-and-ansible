function randomArray(len) { return Array(len).fill(0).map(() => Math.floor(Math.random() * 2e9) - 1e9) }
function empty(ar) { while (ar.length) ar.pop() }
function map1(arr, fn) { const newArr = []; for (let i = 0; i < arr.length; ++i) { newArr.push(fn(arr[i], i)) } return newArr; }
function map2(arr, fn) { const newArr = []; for (let i = 0; i < arr.length; ++i) { newArr[i] = fn(arr[i], i); } return newArr; }
function map3(arr, fn) { const newArr = Array(arr.length); for (let i = 0; i < arr.length; ++i) { newArr[i] = fn(arr[i], i); } return newArr; }
function map4(arr, fn) { const newArr = new Int32Array(arr.length); for (let i = 0; i < arr.length; ++i) { newArr[i] = fn(arr[i], i); } return newArr; }
function map5(arr, fn) { for (let i = 0; i < arr.length; ++i) { arr[i] = fn(arr[i], i); } return arr; }
function map6(arr, fn) { const newArr = Array(arr.length); for (const i in arr) { newArr[i] = fn(arr[i], i); } return arr; }
function map7(arr, fn) { return arr.map(fn) }
var arr = randomArray(5e6); var start = Date.now(); map1(arr, x => x + 1); console.log('took', Date.now() - start); empty(arr)
var arr = randomArray(5e6); var start = Date.now(); map2(arr, x => x + 1); console.log('took', Date.now() - start); empty(arr)
var arr = randomArray(5e6); var start = Date.now(); map3(arr, x => x + 1); console.log('took', Date.now() - start); empty(arr)
var arr = randomArray(5e6); var start = Date.now(); map4(arr, x => x + 1); console.log('took', Date.now() - start); empty(arr)
var arr = randomArray(5e6); var start = Date.now(); map5(arr, x => x + 1); console.log('took', Date.now() - start); empty(arr)
var arr = randomArray(2e6); var start = Date.now(); map6(arr, x => x + 1); console.log('took', Date.now() - start); empty(arr)
var arr = randomArray(5e6); var start = Date.now(); map7(arr, x => x + 1); console.log('took', Date.now() - start); empty(arr)

// 作者：力扣官方题解
// 链接：https://leetcode.cn/problems/apply-transform-over-each-element-in-array/solutions/2496242/zhuan-huan-shu-zu-zhong-de-mei-ge-yuan-s-o2k7/
// 来源：力扣（LeetCode）
// 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

/*
took 143
took 141
took 34
took 22
took 10 -- 原地更新，空间复杂度最低
took 359
took 8
*/

const number = artifacts.require("./federated_learning"); 

// contract('number', accounts => {
//     it("should change the favorite number in the blockchain", async function(){
//         const Contract = await number.deployed();
//         const result = await Contract.setNumber(47, {from: accounts[0]})
//     })

//     it("should get the favorite number in the blockchain", async function(){
//         const Contract = await number.deployed();
//         const result = await Contract.getNumber();
//         console.log(result);
//         assert.equal(result, 47, "Not equal to 47");
//     })
// })

const HelloWorld = artifacts.require("./federated_learning") ;

contract("HelloWorld" , () => {
    it("Hello World Testing" , async () => {
       const helloWorld = await HelloWorld.deployed() ;
       await helloWorld.setName("User Name") ;
       const result = await helloWorld.yourName() ;
       assert(result === "User Name") ;
    });
});
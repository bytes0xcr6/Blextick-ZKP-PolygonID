async function main() {
  const circuitId = "credentialAtomicQuerySig";
  const validatorAddress = "0xb1e86C4c687B85520eF4fd2a0d14e81970a15aFB";
  const schemaHash = "14dd52cc817dd2c568dd31ce2d1bafca"; // extracted from PID Platform

  const schemaEnd = fromLittleEndian(hexToBytes(schemaHash));

  const query = {
    schema: ethers.BigNumber.from(schemaEnd),
    slotIndex: 2,
    operator: 1, // Modified to 1
    value: [1, ...new Array(63).fill(0).map((i) => 0)], //Modified to "true" /1=true
    circuitId,
  };

  // add the address of the contract just deployed (Modified)
  const EventAddress = "0xd467b7797059e968cB837a46F98F869687152BbC";

  // Contract modified
  let eventVerifier = await hre.ethers.getContractAt("Event", EventAddress);
  const requestId = await eventVerifier.TRANSFER_REQUEST_ID();

  try {
    await eventVerifier.setZKPRequest(requestId, validatorAddress, query);
    console.log("Request set");
  } catch (e) {
    console.log("error: ", e);
  }
}

function hexToBytes(hex) {
  for (var bytes = [], c = 0; c < hex.length; c += 2)
    bytes.push(parseInt(hex.substr(c, 2), 16));
  return bytes;
}

function fromLittleEndian(bytes) {
  const n256 = BigInt(256);
  let result = BigInt(0);
  let base = BigInt(1);
  bytes.forEach((byte) => {
    result += base * BigInt(byte);
    base = base * n256;
  });
  return result;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

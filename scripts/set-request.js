async function main() {
  const circuitId = "credentialAtomicQuerySig";
  const validatorAddress = "0xb1e86C4c687B85520eF4fd2a0d14e81970a15aFB";
  // (Modified)
  const schemaHash = "e8fc16c48a291b1bfa4386e71deb5f73"; // extracted from PID Platform

  const schemaEnd = fromLittleEndian(hexToBytes(schemaHash));

  const query = {
    schema: ethers.BigNumber.from(schemaEnd),
    slotIndex: 2,
    operator: 2,
    // 1 = true
    value: [1, ...new Array(63).fill(0).map((i) => 0)], //Modified to "true"
    circuitId,
  };

  // add the address of the contract just deployed (Modified)
  EventAddress = "0x5d8b7E9BB5eFA238559a1Fb773C2Ad24C63D5eFd";

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

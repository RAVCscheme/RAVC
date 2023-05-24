import json
from web3 import Web3
import os
from py_ecc_tester import *
import pickle
import jsonpickle
root_dir = "/home/neel/acad/DTRAC/ravc-main/ROOT"
def getAccuAddress():
	file_path = os.path.join(root_dir, "accumulator_address.pickle")
	f = open(file_path,'rb')
	params_address = pickle.load(f)
	f.close()
	return params_address

w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545", request_kwargs = {'timeout' : 3000}))

# ------------------------------------------------------------------------
# Params.sol
# All the TTP system parameters and Aggregated Validators Key
tf = json.load(open('./build/contracts/Accumulator.json'))
params_address = Web3.toChecksumAddress("0x7b7Ff6b94A94dEBFE6b865657e853F9342d7A105")
acc_contract = w3.eth.contract(address = params_address, abi = tf['abi'])
print("acc_contract")
print(acc_contract)
tx_hash = acc_contract.functions.set_accumulator(3,2,3,2).call()
print(tx_hash)
ans = acc_contract.functions.generate_kr_shares().transact({})
print(ans)
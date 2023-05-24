#!/bin/bash

############### A D M I N ############################################## INITIALIZATION #####################################################
command0='rm -rf ROOT/'
gnome-terminal --title="Deleting root" -x sh -c "$command0;"

sleep 1

command1='python3 AttributeCertifier.py --title "Identity Certificate" --name IdP --req-ip 127.0.0.1 --req-port 3001  --open-ip 127.0.0.1 --open-port 7001'

command2='python3 AttributeCertifier.py --title "Income Certificate" --name Employer --req-ip 127.0.0.1 --req-port 3002  --open-ip 127.0.0.1 --open-port 7002 --dependency "Identity Certificate"'

command3='truffle migrate --reset –compile-all'

gnome-terminal --title="Identity CA" -x sh -c "$command1 < Identity_input.txt;bash"
sleep 1
gnome-terminal --title="Income CA" -x sh -c "$command2 < Income_input.txt;bash"
sleep 1
gnome-terminal --title="SC Deploying" -x sh -c "$command3 > SC_output.txt;"
#bash avoided at tail end to exit the tab after execution
sleep 10 #waiting for SC deployment

Opening=$(sed -n '160p' SC_output.txt)
Issue=$(sed -n '161p' SC_output.txt)
Request=$(sed -n '162p' SC_output.txt)
Params=$(sed -n '163p' SC_output.txt)
Verify=$(sed -n '164p' SC_output.txt)

#echo $Params

command4='python3 ProtocolInitiator_DeployContracts.py --params-address $(grep "total cost:" SC_output.txt -A 7 | tail -6 | sed -e "1,3d;5,6d") --request-address $(grep "total cost:" SC_output.txt -A 7 | tail -6 | sed -e "1,2d;4,6d") --issue-address $(grep "total cost:" SC_output.txt -A 7 | tail -6 | sed -e "1d;3,6d") --opening-address $(grep "total cost:" SC_output.txt -A 7 | tail -6 | sed -e '2,6d') --accumulator-address $(grep "total cost:" SC_output.txt -A 7 | tail -6 | sed -e '1,5d')'

gnome-terminal --title="ProtocolInitiator_DeployContracts" -x sh -c "$command4;"
sleep 5

command5='python3 ProtocolInitiator_AC_Setup.py --title "Loan Credential" --name Loaner --ip 127.0.0.1 --port 4000 --dependency "Identity Certificate" "Income Certificate"'

gnome-terminal --title="ProtocolInitiator_AC_Setup" -x sh -c "$command5 < ProtocolInitiator_input.txt;"
sleep 5

command6='python3 ProtocolInitiator_UpdateCAInformation.py --titles "Identity Certificate" "Income Certificate" --address 0x12EadC92bA04fcC5De1A6980e938504A8295fC7e --rpc-endpoint "http://127.0.0.1:7545"'

gnome-terminal --title="ProtocolInitiator_UpdateCAInformation" -x sh -c "$command6;"
sleep 5

command7='python3 ProtocolInitiator_AnonymousCredentials.py --title "Loan Credential" --address 0x12EadC92bA04fcC5De1A6980e938504A8295fC7e --validator-addresses 0xf23c978F5663fc411a38A51bFea4ed970c5A1D9B 0x75573771DB96d33D8C7C71CECaa5a707B3abd7Cc 0x12216A43004E68bBcb3Ff3DA88F6c8595Ca32940 --opener-addresses 0x62b541E8709d2C9f77fCa97F0c220af61Bc6D66F 0xE24fe6e1B03D7b2b43f029dbA5276b946273C91f 0xCf3007C8732929fa59945A3931A21BA081facBa9 --rpc-endpoint "http://127.0.0.1:7545"'

gnome-terminal --title="ProtocolInitiator_AnonymousCredentials" -x sh -c "$command7;"
sleep 5

############### ############################################## #####################################################

command8='python3 Validator.py --title "Loan Credential" --id 1 --address 0xf23c978F5663fc411a38A51bFea4ed970c5A1D9B --rpc-endpoint "http://127.0.0.1:7545"'
command9='python3 Validator.py --title "Loan Credential" --id 2 --address 0x75573771DB96d33D8C7C71CECaa5a707B3abd7Cc --rpc-endpoint "http://127.0.0.1:7545"'
command10='python3 Validator.py --title "Loan Credential" --id 3 --address 0x12216A43004E68bBcb3Ff3DA88F6c8595Ca32940 --rpc-endpoint "http://127.0.0.1:7545"'

command11='python3 Opener.py --title "Loan Credential" --id 1 --ip 127.0.0.1 --port 8001 --address 0x62b541E8709d2C9f77fCa97F0c220af61Bc6D66F --rpc-endpoint "http://127.0.0.1:7545"'
command12='python3 Opener.py --title "Loan Credential" --id 2 --ip 127.0.0.1 --port 8002 --address 0xE24fe6e1B03D7b2b43f029dbA5276b946273C91f --rpc-endpoint "http://127.0.0.1:7545"'
command13='python3 Opener.py --title "Loan Credential" --id 3 --ip 127.0.0.1 --port 8003 --address 0xCf3007C8732929fa59945A3931A21BA081facBa9 --rpc-endpoint "http://127.0.0.1:7545"'

gnome-terminal --title="Validator 1" -x sh -c "$command8;bash"
gnome-terminal --title="Validator 2" -x sh -c "$command9;bash"
gnome-terminal --title="Validator 3" -x sh -c "$command10;bash"

gnome-terminal --title="Opener 1" -x sh -c "$command11;bash"
gnome-terminal --title="Opener 2" -x sh -c "$command12;bash"
gnome-terminal --title="Opener 3" -x sh -c "$command13;bash"

sleep 15
command14='python3 SP.py --title "Loan Service" --name Bank --address 0x7a4Cd06dD4f8B58B274AB75c01310fDB5c75B56D --verify-address $(grep "total cost:" SC_output.txt -A 7 | tail -6 | sed -e "1,4d;6d") --rpc-endpoint "http://127.0.0.1:7545" --accepts "Loan Credential"'

gnome-terminal --title="Service Provider" -x sh -c "$command14 < SP_input.txt;bash"
#gnome-terminal --title="Service Provider" -x sh -c "$command14;bash"

sleep 15

command15='python3 User.py --unique-name user1 --address 0x1CF92f548B61b4dA87Dd372C19084a2B2bfA060f --rpc-endpoint "http://127.0.0.1:7545"'
gnome-terminal --title="User 1" -x sh -c "$command15 < User_input.txt;bash"
#gnome-terminal --title="User 1" -x sh -c "$command15;bash"

#python3 User.py --title "Loan Service" --name Bank --address 0x7a4Cd06dD4f8B58B274AB75c01310fDB5c75B56D --verify-address $(sed -n '164p' SC_output.txt) --accepts "Loan Credential" --unique-name user1 --address 0x1CF92f548B61b4dA87Dd372C19084a2B2bfA060f --rpc-endpoint "http://127.0.0.1:7545"



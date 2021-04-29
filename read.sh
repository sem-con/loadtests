
export CN=loadtests_semcon_load_1
export CU=http://localhost:3100
export DATE=gdate # use gdate on MacOS

# get credentials
export APP_KEY=`docker logs $CN | grep APP_KEY | awk -F " " '{print $NF}'`; export APP_SECRET=`docker logs $CN | grep APP_SECRET | awk -F " " '{print $NF}'`; 
TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`

curl -s -H "Authorization: Bearer $TOKEN" "${CU}/api/data/1?p=id&f=plain"




# small record size: 40 bytes
for k in {1..20}; do
TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`
for j in {1..50}; do
ts=$($DATE +%s%N)
for i in {1..100}; do curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '[{"field1":"value abc", "field2":4.213}]' -X POST ${CU}/api/data > /dev/null; done
echo "$((($($DATE +%s%N) - $ts)/1000000)) milliseconds"
done
done

# medium record size: 300 bytes
for k in {1..20}; do
TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`
for j in {1..50}; do
ts=$(date +%s%N)
for i in {1..100}; do 
MD=`LC_ALL=C tr -dc 'A-NP-Za-np-z1-9' </dev/urandom | head -c 47 ; echo`;
REC='{"content":{"FirstName":"John","LastName":"Doe","Initials":"JD","DateOfBirth":"1970-01-01","Nationality":"","Residency":"","LEI":"12345678901234567890"},"dri":"';
REC+=$MD;
REC+='","schema_dri":"9VHJEwrYhaHXFj2VmiKs8DRDjjDiGZJx4zjvuSjNjdvd","mime_type":"application/json"}';
curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d $REC -X POST ${CU}/api/data > /dev/null; 
done
echo "$((($(date +%s%N) - $ts)/1000000)) milliseconds"
done
done



# set credentials for https://sc.dip-clinic.data-container.net
export APP_KEY=xyz; export APP_SECRET=abc; 
export CU=https://sc.dip-clinic.data-container.net
export TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`

curl -s -H "Authorization: Bearer $TOKEN" "${CU}/api/data/1?f=full&p=id"
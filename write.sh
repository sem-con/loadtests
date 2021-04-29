# reset container
docker-compose down
docker volume rm loadtests_load
docker-compose up -d

echo "===SMALL==============="

export CN=loadtests_semcon_load_1
export CU=http://localhost:3100
export DATE=date # use gdate on MacOS

# get credentials ============
export APP_KEY=`docker logs $CN | grep APP_KEY | awk -F " " '{print $NF}'`; export APP_SECRET=`docker logs $CN | grep APP_SECRET | awk -F " " '{print $NF}'`; 

# small record size: 40 bytes
for k in {1..20}; do
TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`
for j in {1..50}; do

# calc write speed
ts=$($DATE +%s%N)
for i in {1..100}; do curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '[{"field1":"value abc", "field2":4.213}]' -X POST ${CU}/api/data > /dev/null; done
ws=$((($($DATE +%s%N) - $ts)/1000000))

# calc read speed
ts=$($DATE +%s%N)
for i in {1..10}; do 
r=$(shuf -i 1-$((j*k*100)) -n 1)
curl -s -H "Authorization: Bearer $TOKEN" "${CU}/api/data/$r?p=id&f=plain" > /dev/null; 
done
echo "write: $ws ms; read: $((($($DATE +%s%N) - $ts)/1000000)) ms"

done
done

echo "===MEDIUM==============="

export CN=loadtests_semcon_load_1
export CU=http://localhost:3100
export DATE=date # use gdate on MacOS

# get credentials
export APP_KEY=`docker logs $CN | head -n 1000 | grep APP_KEY | awk -F " " '{print $NF}'`; export APP_SECRET=`docker logs $CN | head -n 1000 | grep APP_SECRET | awk -F " " '{print $NF}'`; 

# medium record size: 300 bytes ============
for k in {1..20}; do
TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`
for j in {1..50}; do

# calc write speed
ts=$(date +%s%N)
for i in {1..100}; do 
MD=`LC_ALL=C tr -dc 'A-NP-Za-np-z1-9' </dev/urandom | head -c 47 ; echo`;
REC='{"content":{"FirstName":"John","LastName":"Doe","Initials":"JD","DateOfBirth":"1970-01-01","Nationality":"","Residency":"","LEI":"12345678901234567890"},"dri":"';
REC+=$MD;
REC+='","schema_dri":"9VHJEwrYhaHXFj2VmiKs8DRDjjDiGZJx4zjvuSjNjdvd","mime_type":"application/json"}';
curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d $REC -X POST ${CU}/api/data > /dev/null; 
done
ws=$((($(date +%s%N) - $ts)/1000000))

# calc read speed
ts=$($DATE +%s%N)
for i in {1..10}; do 
r=$(shuf -i 1-$((j*k*100+100000)) -n 1)
curl -s -H "Authorization: Bearer $TOKEN" "${CU}/api/data/$r?p=id&f=plain" > /dev/null; 
done
echo "write: $ws ms; read: $((($($DATE +%s%N) - $ts)/1000000)) ms"

done
done

echo "===LARGE==============="

export CN=loadtests_semcon_load_1
export CU=http://localhost:3100
export DATE=date # use gdate on MacOS

# get credentials
export APP_KEY=`docker logs $CN | head -n 1000 | grep APP_KEY | awk -F " " '{print $NF}'`; export APP_SECRET=`docker logs $CN | head -n 1000 | grep APP_SECRET | awk -F " " '{print $NF}'`; 

# medium record size: 300 bytes ============
for k in {1..20}; do
TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`
for j in {1..50}; do

# calc write speed
ts=$(date +%s%N)
NOISE=`LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 1200 ; echo`;
for i in {1..100}; do 
MD=`LC_ALL=C tr -dc 'A-NP-Za-np-z1-9' </dev/urandom | head -c 47 ; echo`;
REC='{"content":{"FirstName":"John","LastName":"Doe","Initials":"JD","DateOfBirth":"1970-01-01","Nationality":"","Residency":"","LEI":"12345678901234567890","Noise":"';
REC+=$NOISE;
REC+='"},"dri":"';
REC+=$MD;
REC+='","schema_dri":"9VHJEwrYhaHXFj2VmiKs8DRDjjDiGZJx4zjvuSjNjdvd","mime_type":"application/json"}';
curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d $REC -X POST ${CU}/api/data > /dev/null; 
done
ws=$((($(date +%s%N) - $ts)/1000000))

# calc read speed
ts=$($DATE +%s%N)
for i in {1..10}; do 
r=$(shuf -i 1-$((j*k*100+200000)) -n 1)
curl -s -H "Authorization: Bearer $TOKEN" "${CU}/api/data/$r?p=id&f=plain" > /dev/null; 
done
echo "write: $ws ms; read: $((($($DATE +%s%N) - $ts)/1000000)) ms"

done
done



# set credentials for https://sc.dip-clinic.data-container.net
export APP_KEY=xyz; export APP_SECRET=abc; 
export CU=https://sc.dip-clinic.data-container.net
export TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$APP_KEY -d client_secret=$APP_SECRET -d scope=admin -X POST ${CU}/oauth/token | jq -r '.access_token'`

curl -s -H "Authorization: Bearer $TOKEN" "${CU}/api/data/1?f=full&p=id"
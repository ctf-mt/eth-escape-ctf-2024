sudo docker build -t bridge-proof-verifier .
sudo docker run -d -p 10050:10050 -p 10060:10060 bridge-proof-verifier
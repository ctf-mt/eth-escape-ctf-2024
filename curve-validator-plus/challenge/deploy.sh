sudo docker build -t curve-validator-plus .
sudo docker run -d -p 10051:10051 -p 10052:10052 curve-validator-plus
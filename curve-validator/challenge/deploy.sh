sudo docker build -t curve-validator .
sudo docker run -d -p 10053:10053 -p 10054:10054 curve-validator
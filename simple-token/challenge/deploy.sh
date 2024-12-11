sudo docker build -t simple-token .
sudo docker run -d -p 10006:10006 -p 10007:10007 simple-token
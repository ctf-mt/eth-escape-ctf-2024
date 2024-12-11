sudo docker build -t multi-voter-wallet .
sudo docker run -d -p 10008:10008 -p 10009:10009 multi-voter-wallet
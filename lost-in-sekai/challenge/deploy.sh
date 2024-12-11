docker build -t secret-challenge-server .
# change the host port as you like
docker run -d -p 10002:10002 -p 10003:10003 secret-challenge-server
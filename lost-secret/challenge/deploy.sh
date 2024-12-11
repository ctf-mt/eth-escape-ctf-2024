docker build -t lost-secret-challenge-server .
# change the host port as you like
docker run -d -p 10004:10004 -p 10005:10005 lost-secret-challenge-server
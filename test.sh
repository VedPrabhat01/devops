# build images
docker build -t vedprabhat/assignment-backend:latest ./backend
docker build -t vedprabhat/assignment-frontend:latest ./frontend

# create a network so containers can talk
docker network create assignment-net

# run backend on that network
docker run -d --name backend --network assignment-net -p 5000:5000 vedprabhat/assignment-backend:latest

# run frontend, point BACKEND_URL to backend's container name
docker run -d --name frontend --network assignment-net -p 80:80 \
  -e BACKEND_URL="http://backend:5000" \
  vedprabhat/assignment-frontend:latest
#    ami           = "ami-0dee22c13ea7a9a67" # Ubuntu 22.04 in ap-south-1 (update if needed)

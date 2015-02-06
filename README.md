docker-lodge
===========

Setup a container with [lodge](https://github.com/lodge/lodge/) installed.

## Usage
```sh
docker run -d --name lodge \ 
  -p 3000:3000 \
  -e LODGE_DOMAIN=localhost:3000 \
  -e SMTP_ADDRESS=smtp_host \
  -e SMTP_USERNAME=username \
  -e SMTP_PASSWORD=password \
  -v /data/lodge/db:/db \
  -v /data/lodge/log:/lodge/log \
  kafku/docker-lodge
```

Now, you can see lodge running on http://localhost:3000/



# Media Server

A Haskell Image and Video media server

## API

```
POST media-server.:domain.com/uploads/:token

{
  "actions": {
    "check": {
      "method": "GET",
        "url": "http://media-server.:domain.com/uploads/:id"
    },
    "start": {
      "method": "POST",
      "url": "s3://:domain/uploads/:id"
    }
  },
  "id": ":id",
  "status": {
    "value": "Ready"
  },
  "token": ":token"
}
```

## Deploy

AWS t2 micro Ubuntu 14.04 deploy:

```
ssh ubuntu@ip
sudo su root
git clone https://github.com/svanderbleek/media-server.git
cd media-server
./deploy.sh
```

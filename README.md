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

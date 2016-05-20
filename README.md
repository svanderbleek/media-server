# Media Server

A Haskell Image and Video media server

## API

```
POST /uploads

takes:

{
  token: "token"
}

returns:

{
  upload: {
    method: "POST"
    url: "/uploads/:id" 
  },
  status: {
    method: "GET"
    url: "/uploads/:id"
  }
}
```

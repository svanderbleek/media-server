 {-# LANGUAGE OverloadedStrings #-}
 {-# LANGUAGE DeriveGeneric #-}

module Main where

import GHC.Generics
import Web.Scotty (scotty, ScottyM, ActionM, get, post, json, text)
import Data.Aeson (ToJSON, toJSON, fromJSON, object, (.=))

type Token = String
type Percentage = Int

data Method = Get | Post deriving (Generic, Show)

instance ToJSON Method

data Status =
  Ready
  | InProgress Percentage
  | Complete
  | Error
  deriving (Show)

instance ToJSON Status where
  toJSON (InProgress percentage) =
    object
    [ "value" .= ("InProgress" :: String)
    , "progress" .= percentage ]
  toJSON status =
    object
    [ "value" .= show status ]

data Upload = 
  Upload Token Status
  deriving (Generic, Show)

instance ToJSON Upload where
  toJSON (Upload token status) =
    object 
    [ "status" .= status
    , "upload" .= object
      [ "method" .= Post
      , "url" .= mkUploadUrl token ]
    , "progress" .= object
      [ "method" .= Get
      , "url" .= mkUploadUrl token ] ]

main :: IO ()
main =
  scotty 3333 routes
  
routes :: ScottyM () 
routes = 
  do
    post "/uploads" (json $ Upload "token" Ready)
    get "/uploads" (json $ Upload "token" Ready)

mkUploadUrl :: Token -> String
mkUploadUrl token = "uploads/" ++ token

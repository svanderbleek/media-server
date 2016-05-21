 {-# LANGUAGE OverloadedStrings #-}
 {-# LANGUAGE DeriveGeneric #-}

module Main where

import GHC.Generics
import Control.Monad.Trans (liftIO)
import Network.HTTP.Types (status200)
import Web.Scotty (ScottyM, ActionM, scotty, get, post, json, param, status)
import Data.Aeson (ToJSON, toJSON, fromJSON, object, (.=))
import qualified Store

type UserToken = String
type Percentage = Int
type Domain = String

data Method = Get | Post deriving (Generic, Show)

instance ToJSON Method

data Status =
  Ready
  | InProgress Percentage
  | Complete
  | Error
  deriving (Show, Read)

instance ToJSON Status where
  toJSON (InProgress percentage) =
    object
    [ "value" .= ("InProgress" :: String)
    , "progress" .= percentage ]
  toJSON status =
    object
    [ "value" .= show status ]

data Upload = 
  Upload Store.Id UserToken Status
  deriving (Show, Read)

instance ToJSON Upload where
  toJSON (Upload id token status) = object 
    [ "id" .= show id
    , "token" .= token
    , "status" .= status
    , "actions" .= object
      [ "start" .= object
        [ "method" .= Post
        , "url" .= mkS3UploadUrl id domain ]
      , "check" .= object
        [ "method" .= Get
        , "url" .= mkUploadUrl id domain ] ] ]

main :: IO ()
main =
  scotty 3333 routes
  
routes :: ScottyM () 
routes = 
  do
    get "/" $ status status200
    post "/uploads/:token" createUpload
    get "/uploads/:id" findUpload

createUpload :: ActionM ()
createUpload = 
  do
    token <- param "token"
    id <- liftIO Store.genId
    let upload = Upload id token Ready
    liftIO $ Store.put id upload
    json upload

findUpload :: ActionM ()
findUpload = 
  do
    id <- read <$> param "id"
    upload <- liftIO (Store.get id :: IO Upload)
    json upload

mkS3UploadUrl :: Store.Id -> Domain -> String
mkS3UploadUrl id domain = "s3://" ++ domain ++ "/media-server/uploads/" ++ show id

mkUploadUrl :: Store.Id -> Domain -> String
mkUploadUrl id domain = "http://media-server." ++ domain ++ ".com/uploads/" ++ show id

domain :: Domain
domain = "pornlevy"

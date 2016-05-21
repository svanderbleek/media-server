 {-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad.Trans (liftIO)
import Network.HTTP.Types (status200)
import Web.Scotty (ScottyM, ActionM, scotty, get, post, json, param, status)
import qualified Store
import Network.URI (URI, parseURI)
import Config (ConfigR)
import qualified Config
import Control.Monad.Reader (asks, runReaderT)
import Upload (Upload(..), Status(..))

{- 
, "actions" .= object
  [ "start" .= object
    [ "method" .= Post
    , "url" .= mkStartUrl id ]
  , "check" .= object
    [ "method" .= Get
    , "url" .= mkCheckUrl id ] ] ] 
-}

main :: IO ()
main =
  do
    config <- Config.get
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

mkStartUrl :: Store.Id -> ConfigR String
mkStartUrl id = 
  do
    domain <- asks Config.domain
    return $ "s3://" ++ domain ++ "/media-server/uploads/" ++ show id

mkCheckUrl :: Store.Id -> ConfigR String
mkCheckUrl id = 
  do
    domain <- asks Config.domain
    return $ "http://" ++ domain ++ "/uploads/" ++ show id

{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad.Trans (liftIO)
import Network.HTTP.Types (status200)
import Web.Scotty.Trans (scottyT, ScottyT, ActionT, get, post, json, param, status) 
import qualified Store
import Network.URI (URI, parseURI)
import Config (ConfigReader, runConfigReader)
import qualified Config
import Control.Monad.Reader (asks, runReaderT)
import Upload (Upload(..), Status(..))
import Data.Text.Lazy (Text)

{- 
, "actions" .= object
  [ "start" .= object
    [ "method" .= Post
    , "url" .= mkStartUrl id ]
  , "check" .= object
    [ "method" .= Get
    , "url" .= mkCheckUrl id ] ] ] 
-}

type Error
  = Text

type Action
  = ActionT Error ConfigReader ()

type App
  = ScottyT Error ConfigReader ()

main :: IO ()
main =
  do
    config <- Config.get
    let reader monad = runReaderT (runConfigReader monad) config
    scottyT 3333 reader app
  
app :: App
app = 
  do
    get "/" $ status status200
    post "/uploads/:token" createUpload
    get "/uploads/:id" findUpload

createUpload :: Action
createUpload = 
  do
    token <- param "token"
    id <- liftIO Store.genId
    let upload = Upload id token Ready
    json upload

findUpload :: Action
findUpload = 
  do
    id <- read <$> param "id"
    upload <- liftIO (Store.get id :: IO Upload)
    json upload

mkStartUrl :: Store.Id -> ConfigReader String
mkStartUrl id = 
  do
    domain <- asks Config.domain
    return $ "s3://" ++ domain ++ "/media-server/uploads/" ++ show id

mkCheckUrl :: Store.Id -> ConfigReader String
mkCheckUrl id = 
  do
    domain <- asks Config.domain
    return $ "http://" ++ domain ++ "/uploads/" ++ show id

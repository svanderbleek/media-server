{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty.Trans
  (scottyT, ScottyT, ActionT, get, post, json, param, status, middleware) 
import Network.Wai.Middleware.Cors
  (simpleCors)
import Network.HTTP.Types
  (status200)
import Network.URI
  (URI, parseURI)
import Data.Text.Lazy
  (Text)
import Data.ByteString.Char8
  (pack)

import Control.Monad.Trans
  (liftIO)
import Control.Monad.Reader
  (asks, runReaderT)

import qualified Config
import Config
  (ConfigReader, runConfigReader, port)
import qualified Store
import Upload
  (Upload(..), Status(Ready), Actions(..), Method(Get, Put))

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
    scottyT (port config) reader app
  
app :: App
app = 
  do
    middleware simpleCors
    get "/" $ status status200
    post "/uploads/:token" createUpload
    get "/uploads/:id" findUpload

createUpload :: Action
createUpload = 
  do
    token <- param "token"
    id <- liftIO Store.genId
    let domain = "pornlevy" -- TODO config asks
    put <- liftIO $ Store.genPut domain id
    let get = mkGet domain id
    let upload = Upload id token Ready (mkActions get put)
    liftIO $ Store.put domain id upload
    json upload

findUpload :: Action
findUpload = 
  do
    id <- read <$> param "id"
    let domain = "pornlevy" -- TODO config asks
    upload <- liftIO (Store.get domain id :: IO Upload)
    json upload

mkActions :: Store.Url -> Store.Url -> Actions
mkActions get put =
  Actions [("check", Get, get), ("start", Put, put)]

mkGet :: Config.Domain -> Store.Id -> Store.Url
mkGet domain id =
  pack $ "http://" ++ domain ++ "/uploads/" ++ show id

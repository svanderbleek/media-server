{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty.Trans
  (scottyT, ScottyT, ActionT, get, post, json, param, status, middleware, jsonData) 
import Network.Wai.Middleware.Cors
  (simpleCors)
import Network.HTTP.Types
  (status200)
import Network.URI
  (URI, parseURI)
import Data.Text.Lazy
  (Text)

import Control.Monad.Trans
  (liftIO)
import Control.Monad.Reader
  (asks, runReaderT)

import qualified Config
import Config
  (ConfigReader, runConfigReader, port)
import qualified Store
import Store (FileType)
import qualified Upload
import Upload
  (Status(Ready), Actions(..), Method(Get, Put))

import User
  (token)

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
    post "/uploads/" createUpload
    get "/uploads/:id" findUpload

createUpload :: Action
createUpload = 
  do
    request <- jsonData
    id <- liftIO Store.genId
    let domain = "scrub" -- TODO config asks
    put <- liftIO $ Store.genPut domain request
    let get = mkGet domain id
    let upload = Upload.Upload (token request) Ready (mkActions get put)
    liftIO $ Store.put domain id upload
    json upload

findUpload :: Action
findUpload = 
  do
    id <- read <$> param "id"
    let domain = "scrub" -- TODO config asks
    upload <- liftIO (Store.get domain id :: IO Upload.Upload)
    json upload

mkActions :: Store.Url -> Store.Url -> Actions
mkActions get put =
  Actions [("check", Get, get), ("start", Put, put)]

mkGet :: Config.Domain -> Store.Id -> Store.Url
mkGet domain id =
  "http://" ++ domain ++ "/uploads/" ++ show id

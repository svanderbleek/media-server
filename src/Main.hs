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
import Upload (Upload(..), Status(..), Actions(..), Method(..))
import Data.Text.Lazy (Text)
import Data.ByteString.Char8 (pack)

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
    let domain = "pornlevy"
    put <- liftIO $ Store.genPut domain id
    let get = mkGet domain id
    let upload = Upload id token Ready (Actions [("check", GET, get), ("start", POST, put)])
    liftIO $ Store.put "pornlevy" id upload
    json upload

findUpload :: Action
findUpload = 
  do
    id <- read <$> param "id"
    upload <- liftIO (Store.get "pornlevy" id :: IO Upload)
    json upload
    return ()

mkGet :: Config.Domain -> Store.Id -> Store.Url
mkGet domain id = pack $ "http://" ++ domain ++ "/uploads/" ++ show id

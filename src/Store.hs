{-# LANGUAGE OverloadedStrings #-}

module Store (Id, Url, genId, put, get) where

import Data.UUID (UUID)
import qualified Data.UUID as UUID
import System.Random (randomIO)
import Network.S3 (generateS3URL, S3URL)
import Config (ConfigReader)
import qualified Config
import Control.Monad.Reader (asks)
import Control.Monad.Trans (liftIO)
import Data.Text (pack)

type Id = UUID
type Url = S3URL

genId :: IO Id
genId = randomIO

genUrl :: IO Url
genUrl = undefined

put :: Show a => Id -> a -> ConfigReader String
put id object =
  do
    domain <- asks Config.domain
    return domain

bucket :: String -> String
bucket domain = domain ++ "/media-server/uploads/meta"

get :: Read a => Id -> IO a
get = undefined

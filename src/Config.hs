{-# LANGUAGE NamedFieldPuns #-}

module Config (ConfigR, Config(..), get) where

import Control.Monad.Reader (ReaderT)
import System.Environment as Sys

data Config =
  Config {
    domain :: String,
    awsId :: String,
    awsKey :: String
  }

type ConfigR a = ReaderT Config IO a

get :: IO Config
get =
  Config
    <$> Sys.getEnv "MS_DOMAIN"
    <*> Sys.getEnv "MS_AWS_ID"
    <*> Sys.getEnv "MS_AWS_KEY"

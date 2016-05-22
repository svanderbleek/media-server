{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Config (Config(..), ConfigReader(..), get) where

import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Reader (MonadReader, ReaderT)
import System.Environment as Sys

data Config =
  Config {
    domain :: String,
    awsId :: String,
    awsKey :: String
  }

newtype ConfigReader a = 
  ConfigReader {
    runConfigReader :: ReaderT Config IO a
  } deriving (Applicative, Functor, Monad, MonadIO, MonadReader Config)

get :: IO Config
get =
  Config
    <$> Sys.getEnv "MS_DOMAIN"
    <*> Sys.getEnv "MS_AWS_ID"
    <*> Sys.getEnv "MS_AWS_KEY"

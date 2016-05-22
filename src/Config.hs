{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Config (Config(..), ConfigReader(..), Domain, get) where

import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Reader (MonadReader, ReaderT)
import System.Environment as Sys

type Domain
  = String

data Config
  = Config  
    { domain :: Domain }

newtype ConfigReader a
  = ConfigReader  
  { runConfigReader :: ReaderT Config IO a }
  deriving (Applicative, Functor, Monad, MonadIO, MonadReader Config)

get :: IO Config
get =
  Config
    <$> Sys.getEnv "MS_DOMAIN"

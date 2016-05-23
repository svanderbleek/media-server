{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Config (Config(..), ConfigReader(..), Domain, get) where

import System.Environment as Sys
import Control.Monad.IO.Class
  (MonadIO)
import Control.Monad.Reader
  (MonadReader, ReaderT)

type Domain
  = String

data Config
  = Config  
    { domain :: Domain
    , port :: Int }

newtype ConfigReader a
  = ConfigReader  
  { runConfigReader :: ReaderT Config IO a }
  deriving (Applicative, Functor, Monad, MonadIO, MonadReader Config)

get :: IO Config
get =
  Config
    <$> Sys.getEnv "MS_DOMAIN"
    <*> (read <$> Sys.getEnv "MS_PORT")

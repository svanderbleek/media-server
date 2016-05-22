{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Upload (Upload(..), Status(..), Method(..), Actions(..), UserToken) where

import GHC.Generics
import Data.Aeson (ToJSON, toJSON, fromJSON, object, (.=))
import Data.Aeson.Types (Pair)
import qualified Store
import qualified Config
import Data.Text (pack)

type UserToken
  = String

type Percentage
  = Int

type Name
  = String

data Method 
  = GET
  | POST
  deriving (Generic, Show, Read)

instance ToJSON Method

data Status 
  = Ready
  | InProgress Percentage
  | Complete
  | Error
  deriving (Show, Read)

instance ToJSON Status where
  toJSON (InProgress percentage) =
    object
    [ "value" .= ("InProgress" :: String)
    , "progress" .= percentage ]
  toJSON status =
    object
    [ "value" .= show status ]

type Action
  = (Name, Method, Store.Url)

newtype Actions
  = Actions [Action]
  deriving (Show, Read)

instance ToJSON Actions where
  toJSON (Actions actions) =
    object (concatMap mkPair actions)

mkPair :: Action -> [Pair]
mkPair (name, method, url) =
  [ pack name .=
    object
    [ "method" .= method
    , "url" .= show url ] ]

data Upload 
  = Upload Store.Id UserToken Status Actions
  deriving (Show, Read)

instance ToJSON Upload where
  toJSON (Upload id token status actions) =
    object 
    [ "id" .= show id
    , "token" .= token
    , "status" .= status
    , "actions" .= actions ]

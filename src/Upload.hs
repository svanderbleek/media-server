{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Upload (Upload(..), Status(..), UserToken) where

import GHC.Generics
import Data.Aeson (ToJSON, toJSON, fromJSON, object, (.=))
import qualified Store

type UserToken = String
type Percentage = Int

data Method = Get | Post deriving (Generic, Show)

instance ToJSON Method

data Status =
  Ready
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

data Upload = 
  Upload Store.Id UserToken Status
  deriving (Show, Read)

instance ToJSON Upload where
  toJSON (Upload id token status) = object 
    [ "id" .= show id
    , "token" .= token
    , "status" .= status ]

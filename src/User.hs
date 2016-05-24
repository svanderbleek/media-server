{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeSynonymInstances #-}

module User (Token, FileType, FileName, Upload(..)) where

import Data.Aeson
  (FromJSON, fromJSON)
import GHC.Generics

type Token
  = String

type FileType
  = String

type FileName
  = String

data Upload
  = Upload
  { token :: Token
  , fileType :: FileType
  , fileName :: FileName }
  deriving (Generic, Show)

instance FromJSON Upload

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Store (Id, Url, FileType, genId, genPut, put, get) where

import Control.Monad.Trans.AWS
  (sinkBody, runResourceT, runAWST, send, presignURL, newEnv
  ,Env, Seconds, toBody, RqBody, Region(..), Credentials(..))
import Network.AWS.S3
  (getObject, putObject, gorsBody, PutObjectResponse
  ,BucketName(..), ObjectKey(..))
import Control.Monad.Trans
  (liftIO)
import Control.Lens
  (view)
import Data.Conduit.Binary
  (sinkLbs)
import Data.Time
  (getCurrentTime)
import Data.ByteString 
  (ByteString)
import Data.Text 
  (pack)
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as BSL

import Data.UUID
  (UUID)
import System.Random
  (randomIO)

import Config
  (Domain)
import User
  (Upload(..), FileType, FileName, Token)

import Network.S3
  (S3Keys(..), S3Request(..), S3Method(S3PUT), generateS3URL, signedRequest)
import System.Environment as Sys

type Id
  = UUID

type Url
  = String

genId :: IO Id
genId = randomIO

genPut :: Domain -> Upload -> IO Url
genPut domain Upload{..} =
  do
    credentials <- (S3Keys . BS.pack) <$> Sys.getEnv "MS_AWS_ID" <*> (BS.pack <$> Sys.getEnv "MS_AWS_KEY")
    let request = S3Request S3PUT (BS.pack fileType) (BS.pack $ domain ++ "-uploads") (BS.pack fileName) expiry
    BS.unpack . signedRequest <$> generateS3URL credentials request

put :: Show a => Domain -> Id -> a -> IO PutObjectResponse
put domain id object =
  do
    env <- awsEnv
    let req = send $ putObject (metaBucket domain) (key id) (body object)
    runResourceT . runAWST env $ req

get :: Read a => Domain -> Id -> IO a
get domain id =
  do
    env <- awsEnv
    let req = send $ getObject (metaBucket domain) (key id)
    body <- runResourceT . runAWST env $
      do
        resp <- req
        sinkBody (view gorsBody resp) sinkLbs
    return . read . BSL.unpack $ body

awsEnv :: IO Env
awsEnv = newEnv NorthVirginia Discover

metaBucket :: Domain -> BucketName
metaBucket domain = 
  BucketName $ pack $ domain ++ "/media-server/uploads/meta"

key :: Store.Id -> ObjectKey
key id = 
  ObjectKey $ pack . show $ id

body :: Show a => a -> RqBody
body =
  toBody . show

expiry :: Integer
expiry = 30 * 60

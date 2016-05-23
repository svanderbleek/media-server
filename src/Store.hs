{-# LANGUAGE OverloadedStrings #-}

module Store (Id, Url, genId, genPut, put, get) where

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
import Data.ByteString.Lazy.Char8
  (unpack)
import Data.Text 
  (pack)

import Data.UUID
  (UUID)
import System.Random
  (randomIO)

import Config
  (Domain)

type Id
  = UUID

type Url
  = ByteString

genId :: IO Id
genId = randomIO

genPut :: Domain -> Id -> IO Url
genPut domain id =
  do
    env <- liftIO awsEnv
    time <- getCurrentTime
    let req = presignURL time expiry $ putObject (uploadBucket domain) (key id) ""
    runResourceT . runAWST env $ req

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
    return . read . unpack $ body

awsEnv :: IO Env
awsEnv = newEnv NorthVirginia Discover

metaBucket :: Domain -> BucketName
metaBucket domain = 
  BucketName $ pack $ domain ++ "/media-server/uploads/meta"

uploadBucket :: Domain -> BucketName
uploadBucket domain = 
  BucketName $ pack $ domain ++ "/media-server/uploads"

key :: Store.Id -> ObjectKey
key id = 
  ObjectKey $ pack . show $ id

body :: Show a => a -> RqBody
body =
  toBody . show

expiry :: Seconds
expiry = 30 * 60

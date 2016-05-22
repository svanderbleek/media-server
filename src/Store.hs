{-# LANGUAGE OverloadedStrings #-}

module Store (Id, Url, genId, genPut, put, get) where

import Data.UUID (UUID)
import qualified Data.UUID as UUID
import System.Random (randomIO)
import Config (Domain)
import Control.Monad.Reader (asks)
import Control.Monad.Trans (liftIO)
import Data.Text (pack)
import Data.Time (getCurrentTime)
import Data.ByteString (ByteString)
import Control.Monad.Trans.AWS (sinkBody, runResourceT, runAWST, send, presignURL, newEnv, Env, Seconds, toBody, RqBody, Region(..), Credentials(..))
import Network.AWS.S3 (getObject, putObject, gorsBody, PutObjectResponse, BucketName(..), ObjectKey(..))
import Control.Lens (view)
import Data.Conduit.Binary (sinkLbs)
import Data.ByteString.Lazy.Char8 (unpack)

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
    runResourceT . runAWST env $
      presignURL time expiry (putObject (uploadBucket domain) (key id) "")

put :: Show a => Domain -> Id -> a -> IO PutObjectResponse
put domain id object =
  do
    env <- awsEnv
    runResourceT . runAWST env $
      send $ putObject (metaBucket domain) (key id) (body object)

get :: Read a => Domain -> Id -> IO a
get domain id =
  do
    env <- awsEnv
    body <- runResourceT . runAWST env $
      do
        resp <- send $ getObject (metaBucket domain) (key id)
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

module Store (Id, Url, genId, put, get) where

import Data.UUID (UUID)
import qualified Data.UUID as UUID
import System.Random (randomIO)
import qualified Aws
import qualified Aws.S3 as S3
import Network.S3 (generateS3URL, S3URL)

type Id = UUID
type Url = S3URL

genId :: IO Id
genId = undefined

genUrl :: IO Url
genUrl = undefined

put :: Show a => Id -> a -> IO ()
put = undefined

get :: Read a => Id -> IO a
get = undefined

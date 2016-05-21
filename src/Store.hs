module Store (Id, genId, put, get) where

import Data.UUID (UUID)
import qualified Data.UUID as UUID
import System.Random (randomIO)
import qualified Aws
import qualified Aws.S3 as S3

type Id = UUID

genId :: IO Id
genId = undefined

put :: Show a => Id -> a -> IO ()
put = undefined

get :: Read a => Id -> IO a
get = undefined

{-|
Module      : Fetch
Description : Handles fetching data from a given url
License     : GPL-3
-}

module Fetch (
    download
) where

import qualified Data.ByteString.Lazy.Char8 as BS
import Network.HTTP.Simple

type URL = String

-- | Fetches the data from given URL
download :: URL -> IO BS.ByteString
download url = do
    request <- parseRequest url
    response <- httpLBS request
    return $ getResponseBody response

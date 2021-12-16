module Fetch (
    download
) where

import qualified Data.ByteString.Lazy.Char8 as BS
import Network.HTTP.Simple

type URL = String

-- Fetches the data from given URL and returns it in ByteString
download :: URL -> IO BS.ByteString
download url = do
    request <- parseRequest url
    response <- httpLBS request
    return $ getResponseBody response

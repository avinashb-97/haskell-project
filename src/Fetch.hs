module Fetch (
    download
) where

import qualified Data.ByteString.Lazy.Char8 as BS
import Network.HTTP.Simple

type URL = String

download :: URL -> IO BS.ByteString
download url = do
    request <- parseRequest url
    response <- httpLBS request
    return $ getResponseBody response

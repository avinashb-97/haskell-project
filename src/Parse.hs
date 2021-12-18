{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : Parse
Description : Handles parsing the JSON data to haskell data type and vice-versa
License     : GPL-3
-}


module Parse (
    parseRecords,
    writeToFile
) where

import Types
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as L8
import qualified Data.ByteString.Lazy as BS
import Data.Aeson (encode,ToJSON(..))

renameFields "england_and_wales" = "england-and-wales"
renameFields "northern_ireland" = "northern-ireland"
renameFields other = other

customOptions = defaultOptions {
    fieldLabelModifier = renameFields
}

instance FromJSON Record where
    parseJSON = genericParseJSON customOptions

instance FromJSON Event

instance FromJSON Events

instance ToJSON Record where
    toJSON  = genericToJSON  customOptions

instance ToJSON Event

instance ToJSON Events

-- | Parses the given data to Record data type
parseRecords :: L8.ByteString -> Either String Record
parseRecords json = eitherDecode json :: Either String Record

-- | Encodes the data and writes to file
writeToFile :: ToJSON a => a -> IO ()
writeToFile recs = BS.writeFile "bank_holidays.json" (encode recs)


{-# LANGUAGE DeriveGeneric #-}

{-|
Module      : Parse
Description : Handles parsing the JSON data to haskell data type and vice-versa
License     : GPL-3
-}


module Parse (
    parseRecords,
) where

import Types
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as L8

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

-- | Parses the given data to Record data type
parseRecords :: L8.ByteString -> Either String Record
parseRecords json = eitherDecode json :: Either String Record
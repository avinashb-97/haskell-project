{-# LANGUAGE DeriveGeneric #-}

module Parse (
    parseRecords,
) where

import Types
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as L8

renameFields "datas" = "data"
renameFields other = other

customOptions = defaultOptions {
    fieldLabelModifier = renameFields
}

instance FromJSON Record where
    parseJSON = genericParseJSON customOptions

instance FromJSON University

parseRecords :: L8.ByteString -> Either String Record
parseRecords json = eitherDecode json :: Either String Record
{-# LANGUAGE DeriveGeneric #-}

module Types (
    University (..),
    Record (..)
) where

import GHC.Generics

data University = University {
    name :: String,
    rank :: String,
    location :: String
} deriving (Show, Generic)

data Record = Record {
    datas :: [University]
} deriving (Show, Generic)
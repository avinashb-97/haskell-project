{-# LANGUAGE DeriveGeneric #-}

module Types (
    EventEntry (..),
    DivisionEntry (..),
    Event (..), 
    Events (..),
    Record (..)
) where

import GHC.Generics

data EventEntry = EventEntry {
    title_ :: String,
    date_ :: String,
    notes_ :: String,
    fk_division :: Int
} deriving (Show)

data DivisionEntry = DivisionEntry{
    id_ :: Int,
    division_ :: String
} deriving (Show)

data Event = Event {
    title :: String,
    date :: String,
    notes :: String
} deriving (Show, Generic)

data Events = Events {
    division :: String,
    events :: [Event]
} deriving (Show, Generic)

data Record = Record {
    england_and_wales :: Events,
    scotland :: Events,
    northern_ireland :: Events
} deriving (Show, Generic)

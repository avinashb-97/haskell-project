{-|
Module      : Date
Description : Contains functions to return current year and current date
License     : GPL-3
-}

module Date
    ( 
        getCurrentYear,
        getCurrentDate
    ) where

import Data.Time.Clock
import Data.Time.Calendar

-- | Returns the current Date as (Integer year, Int month, Int day)
currentDate :: IO (Integer,Int,Int) -- :: (year,month,day)
currentDate = getCurrentTime >>= return . toGregorian . utctDay

-- | Returns the current year as Integer
getCurrentYear :: IO Integer
getCurrentYear = do
    (year, month, day) <- currentDate
    return year

-- | Returns the current date as String
getCurrentDate :: IO String 
getCurrentDate = do
    (year, month, day) <- currentDate
    let date = (show year)++"-"++(show month)++"-"++(show day)
    return date
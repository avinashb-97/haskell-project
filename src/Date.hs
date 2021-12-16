module Date
    ( 
        getCurrentYear,
        getCurrentDate
    ) where

import Data.Time.Clock
import Data.Time.Calendar


currentDate :: IO (Integer,Int,Int) -- :: (year,month,day)
currentDate = getCurrentTime >>= return . toGregorian . utctDay

getCurrentYear :: IO Integer
getCurrentYear = do
    (year, month, day) <- currentDate
    return year

getCurrentDate :: IO String 
getCurrentDate = do
    (year, month, day) <- currentDate
    let date = (show year)++"-"++(show month)++"-"++(show day)
    return date
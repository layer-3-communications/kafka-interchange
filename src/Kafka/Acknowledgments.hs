{-# language PatternSynonyms #-}

module Kafka.Acknowledgments
  ( Acknowledgments(..)
  , pattern LeaderOnly
  , pattern None
  , pattern FullIsr
  ) where

import Data.Int (Int16)

newtype Acknowledgments = Acknowledgments Int16

pattern LeaderOnly :: Acknowledgments
pattern LeaderOnly = Acknowledgments 1

pattern None :: Acknowledgments
pattern None = Acknowledgments 0

pattern FullIsr :: Acknowledgments
pattern FullIsr = Acknowledgments (-1)

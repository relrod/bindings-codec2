module Main where

import Data.Binary
import Data.Binary.Get
import Data.Binary.Put
import qualified Data.ByteString.Lazy.Char8 as L
import Data.List.Split (chunksOf)
import Foreign.C.Types
import Foreign.Marshal.Alloc
import Foreign.Marshal.Array
import Foreign.Ptr
import Foreign.Storable
import Bindings.Codec2

main :: IO ()
main = do
  let mode = c'CODEC2_MODE_3200
  codec2 <- c'codec2_create mode
  nsam <- c'codec2_samples_per_frame codec2
  nbit <- c'codec2_bits_per_frame codec2
  buf <- mallocBytes $ sizeOf (0 :: CShort) * fromIntegral nsam :: IO (Ptr CShort)
  let nbyte = floor $ (fromIntegral (nbit + 7) / 8 :: Float) :: Int
  bits <- mallocBytes $ sizeOf (0 :: CUChar) * fromIntegral nbyte :: IO (Ptr CUChar)
  input <- L.readFile "/home/ricky/rpmbuild/BUILD/codec2-0.2.svn1324/raw/hts2a_g729a.raw"
  let samps = runGet getSamples input
  mapM_ (\x -> c2encode codec2 x buf bits nbyte) (chunksOf (fromIntegral nsam) samps)

getSample :: Get CShort
getSample = do
  s <- getWord16le
  return $! CShort (fromIntegral s)

getSamples :: Get [CShort]
getSamples = do
  empty <- isEmpty
  if empty
    then return []
    else do
      samp <- getSample
      remaining' <- getSamples
      return (samp:remaining')

-- | TODO: Is there a better way to do this?
putCUChar :: [CUChar] -> Put
putCUChar input = do
  mapM_ (put . inner) input
  return ()
  where
    inner (CUChar i) = i

c2encode :: Ptr C'CODEC2
         -> [CShort]     -- ^ A list that is @nsam@ elements in length.
         -> Ptr CShort   -- ^ The pointer that the ['Word8'] above gets poked to.
         -> Ptr CUChar   -- ^ The pointer that codec2_encode should store in.
         -> Int          -- ^ How big the result is
         -> IO ()
c2encode codec2 frame poke' store nbyte = do
  pokeArray poke' frame
  c'codec2_encode codec2 store poke'
  -- And, for testing:
  written <- peekArray nbyte store
  let bs = runPut $ putCUChar written
  L.appendFile "/tmp/output.c2" bs

{-# OPTIONS_GHC -fno-warn-unused-imports #-}
#include <bindings.dsl.h>
#include <codec2/codec2.h>
module Bindings.Codec2 where
import Foreign.Ptr
#strict_import

{- struct CODEC2; -}
#opaque_t struct CODEC2
#ccall codec2_create , CInt -> IO (Ptr <struct CODEC2>)
#ccall codec2_destroy , Ptr <struct CODEC2> -> IO ()
#ccall codec2_encode , Ptr <struct CODEC2> -> Ptr CUChar -> Ptr CShort -> IO ()
#ccall codec2_decode , Ptr <struct CODEC2> -> Ptr CShort -> Ptr CUChar -> IO ()
#ccall codec2_samples_per_frame , Ptr <struct CODEC2> -> IO CInt
#ccall codec2_bits_per_frame , Ptr <struct CODEC2> -> IO CInt
#ccall codec2_set_lpc_post_filter , Ptr <struct CODEC2> -> CInt -> CInt -> CFloat -> CFloat -> IO ()
#ccall codec2_get_spare_bit_index , Ptr <struct CODEC2> -> IO CInt
#ccall codec2_rebuild_spare_bit , Ptr <struct CODEC2> -> Ptr CInt -> IO CInt

#num CODEC2_MODE_3200
#num CODEC2_MODE_2400
#num CODEC2_MODE_1600
#num CODEC2_MODE_1400
#num CODEC2_MODE_1300
#num CODEC2_MODE_1200

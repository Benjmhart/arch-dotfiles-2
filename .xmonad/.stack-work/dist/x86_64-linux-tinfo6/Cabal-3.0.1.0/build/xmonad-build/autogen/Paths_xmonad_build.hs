{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_xmonad_build (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/ben/.xmonad/.stack-work/install/x86_64-linux-tinfo6/248dd67bb51ec6107a513c5b32f07edd5828d823fd6ce30c790e3c3d4be1ca93/8.8.3/bin"
libdir     = "/home/ben/.xmonad/.stack-work/install/x86_64-linux-tinfo6/248dd67bb51ec6107a513c5b32f07edd5828d823fd6ce30c790e3c3d4be1ca93/8.8.3/lib/x86_64-linux-ghc-8.8.3/xmonad-build-0.1.0.0-AV4OcST0TDK47V80Sh9GE0-xmonad-build"
dynlibdir  = "/home/ben/.xmonad/.stack-work/install/x86_64-linux-tinfo6/248dd67bb51ec6107a513c5b32f07edd5828d823fd6ce30c790e3c3d4be1ca93/8.8.3/lib/x86_64-linux-ghc-8.8.3"
datadir    = "/home/ben/.xmonad/.stack-work/install/x86_64-linux-tinfo6/248dd67bb51ec6107a513c5b32f07edd5828d823fd6ce30c790e3c3d4be1ca93/8.8.3/share/x86_64-linux-ghc-8.8.3/xmonad-build-0.1.0.0"
libexecdir = "/home/ben/.xmonad/.stack-work/install/x86_64-linux-tinfo6/248dd67bb51ec6107a513c5b32f07edd5828d823fd6ce30c790e3c3d4be1ca93/8.8.3/libexec/x86_64-linux-ghc-8.8.3/xmonad-build-0.1.0.0"
sysconfdir = "/home/ben/.xmonad/.stack-work/install/x86_64-linux-tinfo6/248dd67bb51ec6107a513c5b32f07edd5828d823fd6ce30c790e3c3d4be1ca93/8.8.3/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "xmonad_build_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "xmonad_build_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "xmonad_build_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "xmonad_build_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "xmonad_build_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "xmonad_build_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)

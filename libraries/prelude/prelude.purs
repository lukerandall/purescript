module Prelude where

  foreign import data String :: *
  foreign import data Number :: *
  foreign import data Boolean :: *
  foreign import data Array :: * -> *
  foreign import data Function :: * -> * -> *

  flip :: forall a b c. (a -> b -> c) -> b -> a -> c
  flip f b a = f a b

  konst :: forall a b. a -> b -> a
  konst a _ = a

  infixr 5 >>>
  infixr 5 <<<

  class Category a where
    id :: forall t. a t t
    (<<<) :: forall b c d. a c d -> a b c -> a b d
    (>>>) :: forall b c d. a b c -> a c d -> a b d

  instance Category (->) where
    id x = x
    (<<<) f g x = f (g x)
    (>>>) f g x = g (f x)

  infixr 1000 $
  infixl 1000 #

  ($) :: forall a b. (a -> b) -> a -> b
  ($) f x = f x

  (#) :: forall a b. a -> (a -> b) -> b
  (#) x f = f x

  class Show a where
    show :: a -> String

  instance Show String where
    show s = s

  instance Show Boolean where
    show true = "true"
    show false = "false"

  foreign import showNumber "function showNumber(n) {\
                            \  return n.toString();\
                            \}" :: Number -> String

  instance Prelude.Show Number where
    show = showNumber

  class Read a where
    read :: String -> a

  instance Read String where
    read s = s

  instance Read Boolean where
    read "true" = true
    read _ = false

  class Monad m where
    ret :: forall a. a -> m a
    (>>=) :: forall a b. m a -> (a -> m b) -> m b

  infixl 5 *
  infixl 5 /
  infixl 5 %

  infixl 7 -
  infixl 7 +

  class Num a where
    (+) :: a -> a -> a
    (-) :: a -> a -> a
    (*) :: a -> a -> a
    (/) :: a -> a -> a
    (%) :: a -> a -> a
    negate :: a -> a

  foreign import numAdd "function numAdd(n1) {\
                        \  return function(n2) {\
                        \    return n1 + n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numSub "function numSub(n1) {\
                        \  return function(n2) {\
                        \    return n1 - n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numMul "function numMul(n1) {\
                        \  return function(n2) {\
                        \    return n1 * n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numDiv "function numDiv(n1) {\
                        \  return function(n2) {\
                        \    return n1 / n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numMod "function numMod(n1) {\
                        \  return function(n2) {\
                        \    return n1 % n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numNegate "function numNegate(n) {\
                           \  return -n;\
                           \}" :: Number -> Number

  instance Num Number where
    (+) = numAdd
    (-) = numSub
    (*) = numMul
    (/) = numDiv
    (%) = numMod
    negate = numNegate

  infixl 9 ==
  infixl 9 /=

  class Eq a where
    (==) :: a -> a -> Boolean
    (/=) :: a -> a -> Boolean

  -- Referential equality
  data Ref a = Ref a

  foreign import refEq "function refEq(r1) {\
                       \  return function(r2) {\
                       \    return r1.value === r2.value;\
                       \  };\
                       \}" :: forall a. Ref a -> Ref a -> Boolean

  foreign import refIneq "function refIneq(r1) {\
                         \  return function(r2) {\
                         \    return r1.value !== r2.value;\
                         \  };\
                         \}" :: forall a. Ref a -> Ref a -> Boolean

  foreign import unsafeRefEq "function unsafeRefEq(r1) {\
                             \  return function(r2) {\
                             \    return r1 === r2;\
                             \  };\
                             \}" :: forall a. a -> a -> Boolean

  foreign import unsafeRefIneq "function unsafeRefIneq(r1) {\
                               \  return function(r2) {\
                               \    return r1 !== r2;\
                               \  };\
                               \}" :: forall a. a -> a -> Boolean

  instance Eq (Ref a) where
    (==) = refEq
    (/=) = refIneq

  instance Eq String where
    (==) = unsafeRefEq
    (/=) = unsafeRefIneq

  instance Eq Number where
    (==) = unsafeRefEq
    (/=) = unsafeRefIneq

  instance Eq Boolean where
    (==) = unsafeRefEq
    (/=) = unsafeRefIneq

  instance (Eq a) => Eq [a] where
    (==) [] [] = true
    (==) (x:xs) (y:ys) = x == y && xs == ys
    (==) _ _ = false
    (/=) xs ys = not (xs == ys)

  infixl 3 <
  infixl 3 >
  infixl 3 <=
  infixl 3 >=

  class Ord a where
    (<) :: a -> a -> Boolean
    (>) :: a -> a -> Boolean
    (<=) :: a -> a -> Boolean
    (>=) :: a -> a -> Boolean

  foreign import numLess "function numLess(n1) {\
                         \  return function(n2) {\
                         \    return n1 < n2;\
                         \  };\
                         \}" :: Number -> Number -> Boolean

  foreign import numLessEq "function numLessEq(n1) {\
                           \  return function(n2) {\
                           \    return n1 <= n2;\
                           \  };\
                           \}" :: Number -> Number -> Boolean

  foreign import numGreater "function numGreater(n1) {\
                            \  return function(n2) {\
                            \    return n1 > n2;\
                            \  };\
                            \}" :: Number -> Number -> Boolean

  foreign import numGreaterEq "function numGreaterEq(n1) {\
                              \  return function(n2) {\
                              \    return n1 >= n2;\
                              \  };\
                              \}" :: Number -> Number -> Boolean

  instance Ord Number where
    (<) = numLess
    (>) = numGreater
    (<=) = numLessEq
    (>=) = numGreaterEq

  infixl 10 &
  infixl 10 |
  infixl 10 ^

  class Bits b where
    (&) :: b -> b -> b
    (|) :: b -> b -> b
    (^) :: b -> b -> b
    shl :: b -> Number -> b
    shr :: b -> Number -> b
    zshr :: b -> Number -> b
    complement :: b -> b

  foreign import numShl "function numShl(n1) {\
                        \  return function(n2) {\
                        \    return n1 << n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numShr "function numShr(n1) {\
                        \  return function(n2) {\
                        \    return n1 >> n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numZshr "function numZshr(n1) {\
                          \  return function(n2) {\
                          \    return n1 >>> n2;\
                          \  };\
                          \}" :: Number -> Number -> Number

  foreign import numAnd "function numAnd(n1) {\
                        \  return function(n2) {\
                        \    return n1 & n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numOr "function numOr(n1) {\
                       \  return function(n2) {\
                       \    return n1 | n2;\
                       \  };\
                       \}" :: Number -> Number -> Number

  foreign import numXor "function numXor(n1) {\
                        \  return function(n2) {\
                        \    return n1 ^ n2;\
                        \  };\
                        \}" :: Number -> Number -> Number

  foreign import numComplement "function numComplement(n) {\
                               \  return ~n;\
                               \}" :: Number -> Number

  instance Bits Number where
    (&) = numAnd
    (|) = numOr
    (^) = numXor
    shl = numShl
    shr = numShr
    zshr = numZshr
    complement = numComplement

  infixl 4 !!

  foreign import (!!) "function $bang$bang(xs) {\
                      \  return function(n) {\
                      \    return xs[n];\
                      \  };\
                      \}" :: forall a. [a] -> Number -> a

  infixr 11 ||
  infixr 11 &&

  class BoolLike b where
    (&&) :: b -> b -> b
    (||) :: b -> b -> b
    not :: b -> b

  foreign import boolAnd "function boolAnd(b1) {\
                         \  return function(b2) {\
                         \    return b1 && b2;\
                         \  };\
                         \}"  :: Boolean -> Boolean -> Boolean

  foreign import boolOr "function boolOr(b1) {\
                        \  return function(b2) {\
                        \    return b1 || b2;\
                        \  };\
                        \}" :: Boolean -> Boolean -> Boolean

  foreign import boolNot "function boolNot(b) {\
                         \  return !b;\
                         \}" :: Boolean -> Boolean

  instance BoolLike Boolean where
    (&&) = boolAnd
    (||) = boolOr
    not = boolNot

  infixr 6 ++

  foreign import (++) "function $plus$plus(s1) {\
                      \  return function(s2) {\
                      \    return s1 + s2;\
                      \  };\
                      \}" :: String -> String -> String

module Maybe where

  import Prelude

  data Maybe a = Nothing | Just a

  maybe :: forall a b. b -> (a -> b) -> Maybe a -> b
  maybe b _ Nothing = b
  maybe _ f (Just a) = f a

  fromMaybe :: forall a. a -> Maybe a -> a
  fromMaybe a = maybe a (Prelude.id :: forall a. a -> a)

  instance Prelude.Monad Maybe where
    ret = Just
    (>>=) m f = maybe Nothing f m

module Either where

  data Either a b = Left a | Right b

  either :: forall a b c. (a -> c) -> (b -> c) -> Either a b -> c
  either f _ (Left a) = f a
  either _ g (Right b) = g b

  instance Prelude.Monad (Either e) where
    ret = Right
    (>>=) = either (\e _ -> Left e) (\a f -> f a)

module Arrays where

  import Prelude
  import Maybe

  head :: forall a. [a] -> a
  head (x : _) = x

  headSafe :: forall a. [a] -> Maybe a
  headSafe (x : _) = Just x
  headSafe _ = Nothing

  tail :: forall a. [a] -> [a]
  tail (_ : xs) = xs

  tailSafe :: forall a. [a] -> Maybe [a]
  tailSafe (_ : xs) = Just xs
  tailSafe _ = Nothing

  map :: forall a b. (a -> b) -> [a] -> [b]
  map _ [] = []
  map f (x:xs) = f x : map f xs

  foldr :: forall a b. (a -> b -> a) -> a -> [b] -> a
  foldr f a (b : bs) = f (foldr f a bs) b
  foldr _ a [] = a

  foldl :: forall a b. (a -> b -> b) -> b -> [a] -> b
  foldl _ b [] = b
  foldl f b (a:as) = foldl f (f a b) as

  foreign import length "function length(xs) { \
                        \  return xs.length; \
                        \}" :: forall a. [a] -> Number

  foreign import indexOf "function indexOf(l) {\
                         \  return function (e) {\
                         \    return l.indexOf(e);\
                         \  };\
                         \}" :: forall a. [a] -> a -> Number

  foreign import lastIndexOf "function lastIndexOf(l) {\
                             \  return function (e) {\
                             \    return l.lastIndexOf(e);\
                             \  };\
                             \}" :: forall a. [a] -> a -> Number

  foreign import concat "function concat(l1) {\
                        \  return function (l2) {\
                        \    return l1.concat(l2);\
                        \  };\
                        \}" :: forall a. [a] -> [a] -> [a]

  foreign import join "function join(l) {\
                      \  return l.join();\
                      \}" :: [String] -> String

  foreign import joinWith "function joinWith(l) {\
                          \  return function (s) {\
                          \    return l.join(s);\
                          \  };\
                          \}" :: [String] -> String -> String

  foreign import push "function push(l) {\
                      \  return function (e) {\
                      \    var l1 = l.slice();\
                      \    l1.push(e); \
                      \    return l1;\
                      \  };\
                      \}" :: forall a. [a] -> a -> [a]

  foreign import reverse "function reverse(l) {\
                         \  var l1 = l.slice();\
                         \  l1.reverse(); \
                         \  return l1;\
                         \}" :: forall a. [a] -> [a]

  foreign import shift "function shift(l) {\
                       \  var l1 = l.slice();\
                       \  l1.shift();\
                       \  return l1;\
                       \}" :: forall a. [a] -> [a]

  foreign import slice "function slice(s) {\
                       \  return function(e) {\
                       \    return function (l) {\
                       \      return l.slice(s, e);\
                       \    };\
                       \  };\
                       \}" :: forall a. Number -> Number -> [a] -> [a]

  foreign import sort "function sort(l) {\
                      \  var l1 = l.slice();\
                      \  l.sort();\
                      \  return l1;\
                      \}" :: forall a. [a] -> [a]

  foreign import splice "function splice(s) {\
                        \  return function(e) {\
                        \    return function(l1) { \
                        \      return function(l2) {\
                        \        return l2.splice(s, e, l1);\
                        \      }; \
                        \    }; \
                        \  };\
                        \}":: forall a. Number -> Number -> [a] -> [a] -> [a]

  infixr 6 :

  (:) :: forall a. a -> [a] -> [a]
  (:) a = concat [a]

  concatMap :: forall a b. [a] -> (a -> [b]) -> [b]
  concatMap [] f = []
  concatMap (a:as) f = f a `concat` concatMap as f

  filter :: forall a. (a -> Boolean) -> [a] -> [a]
  filter _ [] = []
  filter p (x:xs) | p x = x : filter p xs
  filter p (_:xs) = filter p xs

  empty :: forall a. [a] -> Boolean
  empty [] = true
  empty _ = false

  range :: Number -> Number -> [Number]
  range lo hi = {
      var ns = [];
      for (n <- lo until hi) {
	ns = push ns n;
      }
      return ns;
    }

  zipWith :: forall a b c. (a -> b -> c) -> [a] -> [b] -> [c]
  zipWith f (a:as) (b:bs) = f a b : zipWith f as bs
  zipWith _ _ _ = []

  any :: forall a. (a -> Boolean) -> [a] -> Boolean
  any _ [] = false
  any p (a:as) = p a || any p as

  all :: forall a. (a -> Boolean) -> [a] -> Boolean
  all _ [] = true
  all p (a:as) = p a && all p as

  instance (Prelude.Show a) => Prelude.Show [a] where
    show [] = "[]"
    show (x:xs) = show x ++ " : " ++ show xs

module Tuple where

  import Prelude
  import Arrays

  type Tuple a b = { fst :: a, snd :: b }

  curry :: forall a b c. (Tuple a b -> c) -> a -> b -> c
  curry f a b = f { fst: a, snd: b }

  uncurry :: forall a b c. (a -> b -> c) -> Tuple a b -> c
  uncurry f t = f t.fst t.snd

  tuple :: forall a b. a -> b -> Tuple a b
  tuple = curry (\t -> t)

  zip :: forall a b. [a] -> [b] -> [Tuple a b]
  zip = zipWith tuple

  unzip :: forall a b. [Tuple a b] -> Tuple [a] [b]
  unzip (t:ts) = case unzip ts of
      { fst = as, snd = bs } -> tuple (t.fst : as) (t.snd : bs)
  unzip [] = tuple [] []

module String where

  foreign import lengthS "function lengthS(s) {\
                         \  return s.length;\
                         \}" :: String -> Number

  foreign import charAt "function charAt(i) {\
                        \  return function(s) {\
                        \    return s.charAt(i); \
                        \  };\
                        \}" :: Number -> String -> String

  foreign import indexOfS "function indexOfS(s1) {\
                          \  return function(s2) {\
                          \    return s2.indexOf(s2);\
                          \  }; \
                          \}" :: String -> String -> Number

  foreign import lastIndexOfS "function lastIndexOfS(s1) {\
                              \  return function(s2) {\
                              \    return s2.lastIndexOf(s2);\
                              \  };\
                              \}" :: String -> String -> Number

  foreign import localeCompare "function localeCompare(s1) {\
                               \  return function(s2) { \
                               \    return s1.localeCompare(s2);\
                               \  };\
                               \}" :: String -> String -> Number

  foreign import replace "function replace(s1) {\
                         \  return function(s2) {\
                         \    return function(s3) {\
                         \      return s3.replace(s1, s2);\
                         \    };\
                         \  };\
                         \}" :: String -> String -> String -> String

  foreign import sliceS "function sliceS(st) {\
                        \  return function(e) {\
                        \    return function(s) {\
                        \      return s.slice(st, e);\
                        \    };\
                        \  };\
                        \}" :: Number -> Number -> String -> String

  foreign import split "function split(sep) {\
                       \  return function(s) {\
                       \    return s.split(s);\
                       \  };\
                       \}" :: String -> String -> [String]

  foreign import substr "function substr(n1) {\
                        \  return function(n2) {\
                        \    return function(s) {\
                        \      return s.substr(n1, n2);\
                        \    };\
                        \  };\
                        \}" :: Number -> Number -> String -> String

  foreign import substring "function substring(n1) {\
                           \  return function(n2) {\
                           \    return function(s) {\
                           \      return s.substring(n1, n2);\
                           \    };\
                           \  };\
                           \}" :: Number -> Number -> String -> String

  foreign import toLower "function toLower(s) {\
                         \  return s.toLower();\
                         \}" :: String -> String

  foreign import toUpper "function toUpper(s) {\
                         \  return s.toUpper();\
                         \}" :: String -> String

  foreign import trim "function trim(s) {\
                      \  return s.trim();\
                      \}" :: String -> String

module Regex where

  foreign import data Regex :: *

  foreign import regex "function regex(s1) {\
                       \  return function(s2) {\
                       \    return new Regex(s1, s2);\
                       \  };\
                       \}" :: String -> String -> Regex

  foreign import test "function test(r) {\
                      \  return function (s) { \
                      \    return r.test(s);\
                      \  };\
                      \}" :: Regex -> String -> Boolean

  foreign import match "function match(r) {\
                       \  return function (s) {\
                       \    return s.match(r); \
                       \  };\
                       \}" :: Regex -> String -> [String]

  foreign import replaceR "function replaceR(r) {\
                          \  return function(s1) {\
                          \    return function(s2) { \
                          \      return s2.replace(r, s1);\
                          \    };\
                          \  };\
                          \}" :: Regex -> String -> String -> String

  foreign import search "function search(r) {\
                        \  return function (s) {\
                        \    return s.search(r);\
                        \  };\
                        \}" :: Regex -> String -> Number

module Global where

  foreign import nan "var nan = NaN;" :: Number

  foreign import infinity "var infinity = Infinity;" :: Number

  foreign import toExponential "function toExponential(n) {\
                               \  return n.toExponential();\
                               \}" :: Number -> String

  foreign import toFixed "function toFixed(d) {\
                         \  return function(n) {\
                         \    return n.toFixed(d);\
                         \  };\
                         \}" :: Number -> Number -> String

  foreign import toPrecision "function toPrecision(d) {\
                             \  return function(n) {\
                             \    return n.toPrecision(d);\
                             \  };\
                             \}" :: Number -> Number -> String

  foreign import isFinite :: Number -> Boolean

  foreign import parseFloat :: String -> Number

  foreign import parseInt :: String -> Number

  foreign import encodeURIComponent :: String -> String

  foreign import decodeURIComponent :: String -> String

  foreign import encodeURI :: String -> String

  foreign import decodeURI :: String -> String

  foreign import isNaN :: Number -> Boolean

module Math where

  foreign import abs "function abs(n){\
                     \  return Math.abs(n);\
                     \}" :: Number -> Number

  foreign import acos "function acos(n){\
                      \  return Math.acos(n);\
                      \}" :: Number -> Number

  foreign import asin "function asin(n){\
                      \  return Math.asin(n);\
                      \}" :: Number -> Number

  foreign import atan "function atan(n){\
                      \  return Math.atan(n);\
                      \}" :: Number -> Number

  foreign import atan2 "function atan2(y){\
                       \  return function (x) {\
                       \    return Math.atan2(y, x);\
                       \  };\
                       \}" :: Number -> Number -> Number

  foreign import aceil "function aceil(n){\
                       \  return Math.aceil(n);\
                       \}" :: Number -> Number

  foreign import cos "function cos(n){\
                     \  return Math.cos(n);\
                     \}" :: Number -> Number

  foreign import exp "function exp(n){\
                     \  return Math.exp(n);\
                     \}" :: Number -> Number

  foreign import floor "function floor(n){\
                       \  return Math.floor(n);\
                       \}" :: Number -> Number

  foreign import log "function log(n){\
                     \  return Math.log(n);\
                     \}" :: Number -> Number

  foreign import max "function max(n){\
                     \  return Math.max(n);\
                     \}" :: Number -> Number

  foreign import min "function min(n){\
                     \  return Math.min(n);\
                     \}" :: Number -> Number

  foreign import pow "function pow(n){\
                     \  return Math.pow(n);\
                     \}" :: Number -> Number

  foreign import round "function round(n){\
                       \  return Math.round(n);\
                       \}" :: Number -> Number

  foreign import sin "function sin(n){\
                     \  return Math.sin(n);\
                     \}" :: Number -> Number

  foreign import sqrt "function sqrt(n){\
                      \  return Math.sqrt(n);\
                      \}" :: Number -> Number

  foreign import tan "function tan(n){\
                     \  return Math.tan(n);\
                     \}" :: Number -> Number

module Eff where

  foreign import data Eff :: # ! -> * -> *

  foreign import retEff "function retEff(a) { \
                        \  return function() { \
                        \    return a; \
                        \  }; \
                        \}" :: forall e a. a -> Eff e a

  foreign import bindEff "function bindEff(a) { \
                         \  return function(f) { \
                         \    return function() { \
                         \      return f(a())(); \
                         \    }; \
                         \  }; \
                         \}" :: forall e a b. Eff e a -> (a -> Eff e b) -> Eff e b

  type Pure a = forall e. Eff e a

  foreign import runPure "function runPure(f) { \
                         \  return f(); \
                         \}" :: forall a. Pure a -> a

  instance Prelude.Monad (Eff e) where
    ret = retEff
    (>>=) = bindEff

module Random where

  import Eff

  foreign import data Random :: !

  foreign import random "function random() {\
                        \  return Math.random();\
                        \}" :: forall e. Eff (random :: Random | e) Number

module Errors where

  import Eff

  foreign import data Error :: * -> !

  foreign import throwError "function throwError(e) { \
                            \  return function() { \
                            \    throw e; \
                            \  }; \
                            \}" :: forall a e r. e -> Eff (err :: Error e | r) a

  foreign import catchError "function catchError(c) { \
                            \  return function(t) { \
                            \    return function() { \
                            \      try { \
                            \        return t(); \
                            \      } catch(e) { \
                            \        return c(e)(); \
                            \      }\
                            \    }; \
                            \  }; \
                            \}" :: forall e r a. (e -> Eff r a) -> Eff (err :: Error e | r) a -> Eff r a

module IORef where

  import Eff

  foreign import data Ref :: !

  foreign import data IORef :: * -> *

  foreign import newIORef "function newIORef(val) {\
                          \  return function () {\
                          \    return { value: val };\
                          \  };\
                          \}" :: forall s r. s -> Eff (ref :: Ref | r) (IORef s)

  foreign import readIORef "function readIORef(ref) {\
                           \  return function() {\
                           \    return ref.value;\
                           \  };\
                           \}" :: forall s r. IORef s -> Eff (ref :: Ref | r) s


  foreign import modifyIORef "function modifyIORef(ref) {\
                             \  return function(f) {\
                             \    return function() {\
                             \      ref.value = f(ref.value);\
                             \    };\
                             \  };\
                             \}" :: forall s r. IORef s -> (s -> s) -> Eff (ref :: Ref | r) {}

  foreign import writeIORef "function writeIORef(ref) {\
                            \  return function(val) {\
                            \    return function() {\
                            \      ref.value = val;\
                            \    };\
                            \  };\
                            \}" :: forall s r. IORef s -> s -> Eff (ref :: Ref | r) {}

module Trace where

  import Prelude
  import Eff

  foreign import data Trace :: !

  foreign import trace "function trace(s) { \
                       \  return function() { \
                       \    console.log(s); \
                       \    return {}; \
                       \  }; \
                       \}" :: forall r. String -> Eff (trace :: Trace | r) {}

  print :: forall a r. (Prelude.Show a) => a -> Eff (trace :: Trace | r) {}
  print o = trace (show o)

module ST where

  import Eff

  foreign import data ST :: * -> !

  foreign import data STRef :: * -> * -> *

  foreign import newSTRef "function newSTRef(val) {\
                          \  return function () {\
                          \    return { value: val };\
                          \  };\
                          \}" :: forall a h r. a -> Eff (st :: ST h | r) (STRef h a)

  foreign import readSTRef "function readSTRef(ref) {\
                           \  return function() {\
                           \    return ref.value;\
                           \  };\
                           \}" :: forall a h r. STRef h a -> Eff (st :: ST h | r) a

  foreign import modifySTRef "function modifySTRef(ref) {\
                             \  return function(f) {\
                             \    return function() {\
                             \      ref.value = f(ref.value);\
                             \    };\
                             \  };\
                             \}" :: forall a h r. STRef h a -> (a -> a) -> Eff (st :: ST h | r) {}

  foreign import writeSTRef "function writeSTRef(ref) {\
                            \  return function(a) {\
                            \    return function() {\
                            \      ref.value = a;\
                            \    };\
                            \  };\
                            \}" :: forall a h r. STRef h a -> a -> Eff (st :: ST h | r) {}

  foreign import runST "function runST(f) {\
                       \  return f;\
                       \}" :: forall a r. (forall h. Eff (st :: ST h | r) a) -> Eff r a


import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import System.FilePath (takeExtension)
import Text.Pandoc.JSON


doInclude :: Block -> IO Block
doInclude cb@(CodeBlock (id, classes, namevals) contents) =
  case lookup (T.pack "include") namevals of
    Just f -> do
      let fileExtension =
            if null classes
              then T.pack (takeExtension (T.unpack f))
              else head classes
      CodeBlock (id, [fileExtension], namevals)
        <$> TIO.readFile (T.unpack f)
    Nothing -> return cb
doInclude x = return x

main :: IO ()
main = toJSONFilter doInclude

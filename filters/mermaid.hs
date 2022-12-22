import Data.ByteString qualified as BS
import Data.ByteString.Base64 qualified as B64
import Data.Text qualified as T
import System.Directory
import System.IO
import System.Process
import Text.Pandoc.JSON

readFileBase64 :: FilePath -> IO T.Text
readFileBase64 filePath = do
  bsFileContent <- BS.readFile filePath
  return (B64.encodeBase64 bsFileContent)

renderMermaid :: Block -> IO Block
renderMermaid cb@(CodeBlock (id, classes, namevals) contents)
  | T.pack ".mermaid" `elem` classes = do
      systemTempDir <- getTemporaryDirectory
      let tempDir = systemTempDir ++ "/mermaid-tmp"
      -- create a temporary file to write the input to
      (tempFileIn, tempHandleIn) <- openTempFile tempDir "mermaid-temp-input.svg"
      -- create a temporary file to save the svg to
      (tempFileOut, tempHandleOut) <- openTempFile tempDir "mermaid-temp-output.svg"

      -- execute mermaid-cli
      readProcess "mmdc" ["-i", tempFileIn, "-o", tempFileOut] ""

      base64Content <- readFileBase64 tempFileOut

      removeDirectory tempDir

      --                           \/ TODO allow to pass classes
      return (Para [Image (id, [], []) [Str (T.pack "Test Caption")] (base64Content, T.pack "fig:title")])
renderMermaid x = return x

main :: IO ()
main = toJSONFilter renderMermaid

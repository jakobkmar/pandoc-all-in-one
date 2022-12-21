import Data.Text qualified as T
import System.Directory
import System.IO
import System.Process
import Text.Pandoc.JSON
import qualified Data.ByteString
import qualified Data.ByteString.Base64

renderMermaid :: Block -> IO Block
renderMermaid cb@(CodeBlock (id, classes, namevals) contents) | T.pack ".mermaid" `elem` classes = do
  systemTempDir <- getTemporaryDirectory
  let tempDir = systemTempDir + "/mermaid-tmp"
  -- create a temporary file to write the input to
  (tempFileIn, tempHandleIn) <- openTempFile tempDir "mermaid-temp-input.svg"
  -- create a temporary file to save the svg to
  (tempFileOut, tempHandleOut) <- openTempFile tempDir "mermaid-temp-output.svg"

  -- execute mermaid-cli
  readProcess "mmdc" ["-i", tempFileIn, "-o", tempFileOut] ""

  outputContent <- Data.ByteString.readFile tempFileOut
  let base64content = Data.ByteString.Base64.encodeBase64 outputContent

  removeDirectory tempDir

  --                          \/ TODO allow to pass classes
  return Para [Image (id, [], []) [Str (T.pack "Test Caption")] (base64content, T.pack "fig:title")]
renderMermaid x = return x

main :: IO ()
main = toJSONFilter renderMermaid

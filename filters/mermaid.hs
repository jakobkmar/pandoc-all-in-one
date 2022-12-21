import Data.Text qualified as T
import System.Directory
import System.IO
import System.Process
import Text.Pandoc.JSON

-- TODO not finished

renderMermaid :: Block -> IO Block
renderMermaid cb@(CodeBlock (id, classes, namevals) contents) | T.pack ".mermaid" `elem` classes = do
  tempDir <- getTemporaryDirectory
  -- create a temporary file to write the input to
  (tempFileIn, tempHandleIn) <- openTempFile tempDir "mermaid-temp-input.svg"
  -- create a temporary file to save the svg to
  (tempFileOut, tempHandleOut) <- openTempFile tempDir "mermaid-temp-output.svg"

  -- execute mermaid-cli
  readProcess "mmdc" ["-i", tempFileIn, "-o", tempFileOut] ""

  removeDirectory tempDir

  cb
renderMermaid x = return x

main :: IO ()
main = toJSONFilter renderMermaid

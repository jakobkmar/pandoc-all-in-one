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
      let mermaidTempDir = systemTempDir ++ "/mermaid-tmp"
      createDirectoryIfMissing False mermaidTempDir
      
      let tempFileIn = mermaidTempDir ++ "/mermaid-temp-input.mmd"
      let tempFileOut = mermaidTempDir ++ "/mermaid-temp-output.svg"

      writeFile tempFileIn (T.unpack contents)

      -- execute mermaid-cli
      readProcess "mmdc" ["-i", tempFileIn, "-o", tempFileOut] ""

      base64Content <- readFileBase64 tempFileOut

      -- cleanup temp files
      removeFile tempFileIn
      removeFile tempFileOut
      removeDirectory mermaidTempDir

      --                           \/ TODO allow to pass classes
      return (Para [Image (id, [], []) [Str (T.pack "Test Caption")] (base64Content, T.pack "fig:title")])
renderMermaid x = return x

main :: IO ()
main = toJSONFilter renderMermaid

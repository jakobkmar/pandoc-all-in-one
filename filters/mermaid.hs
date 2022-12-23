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
  | T.pack "mermaid" `elem` classes = do
      hPutStrLn stderr "[Mermaid Filter] Converting a mermaid code block"

      systemTempDir <- getTemporaryDirectory
      let mermaidTempDir = systemTempDir ++ "/mermaid-tmp"
      createDirectoryIfMissing False mermaidTempDir
      
      let tempFileIn = mermaidTempDir ++ "/mermaid-temp-input.mmd"
      let tempFileOut = mermaidTempDir ++ "mermaid-temp-output.pdf"

      writeFile tempFileIn (T.unpack contents)

      -- execute mermaid-cli
      let mermaidCliArgs = ["-i", tempFileIn, "-o", tempFileOut, "--puppeteerConfigFile", "/resources/.puppeteer.json", "--pdfFit", "-w", "300"]
      
      hPutStrLn stderr ("[Mermaid Filter] Executing mermaid-cli with the following args: " <> unwords mermaidCliArgs)
      readProcess "mmdc" mermaidCliArgs ""
      hPutStrLn stderr "[Mermaid Filter] Finished executing mermaid-cli"

      base64Content <- readFileBase64 tempFileOut
      let base64Path = T.pack "data:image/svg+xml;base64," <> base64Content

      -- cleanup temp files
      removeFile tempFileIn
      removeFile tempFileOut
      removeDirectory mermaidTempDir
      
      --                           \/ TODO allow to pass classes
      return (Para [Image (id, [], []) [Str (T.pack "Placeholder Caption")] (T.pack tempFileOut, T.pack "title")])
renderMermaid x = return x

main :: IO ()
main = toJSONFilter renderMermaid

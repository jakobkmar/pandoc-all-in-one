PANDOC_VERSION:must_be_at_least("3.0")

local function with_tmp_dir(name, action)
  return pandoc.system.with_temporary_directory(
          name,
          function(tmpdir)
            return pandoc.system.with_working_directory(tmpdir, action)
          end
      )
end

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    f:close()
    return true
  else
    return false
  end
end

local function convert(source_code)
  return with_tmp_dir(
          "mermaid",
          function()
            local mermaid_output = "pandoc_mermaid_output.svg"

            local mermaid_args = { "--output", mermaid_output }

            local puppeteer_config = "/resources/.puppeteer.json"
            if file_exists(puppeteer_config) then
              mermaid_args = { "--puppeteerConfigFile", puppeteer_config, table.unpack(mermaid_args) }
            end

            pandoc.pipe("mmdc", mermaid_args, source_code)

            local read_handle = io.open(mermaid_output, 'r')

            local img
            if read_handle then
              img = read_handle:read('a')
              read_handle:close()
            else
              error("Could not read mermaid output file " .. mermaid_output)
            end

            return img
          end
      )
end

local filetype = "svg"
local mimetype = "image/svg+xml"

-- TODO temporary test variables
local caption_or_alt = "Alt (or Caption?) Text"
local caption = "Caption Text"
local title = "Title Text"
local figure_attrs = {}

function CodeBlock(code_block)
  if not code_block.classes[1] == "mermaid" then
    return nil
  end

  local convert_success, img = pcall(convert, code_block.text)
  if not convert_success then
    -- io.stderr:write(tostring(img or "Mermaid conversion returned no data"))
    io.stderr:write(tostring(img) .. "\n")
    error("Mermaid conversion failed")
  end

  local fname = pandoc.utils.sha1(img .. "." .. filetype)

  pandoc.mediabag.insert(fname, mimetype, img)

  local image_attrs = {
      width = code_block.attributes.width,
      height = code_block.attributes.height,
  }

  local image_obj = pandoc.Image(caption_or_alt, fname, title, image_attrs)

  return pandoc.Figure(image_obj, pandoc.Blocks {}, figure_attrs)
end

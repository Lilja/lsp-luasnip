local ls = require("luasnip")

local M = {}

function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local root_dir = client["config"].root_dir
      local file_types = client["config"].filetypes
      local lsp_name = client.name
      M.registerSnippet(root_dir, file_types, lsp_name, opts.snippets)
  end,
})
end

function parserPackageJson(workspace)
	local fp = io.open(workspace .. "/package.json", "r")
  local output = {}

	if fp ~= nil then
		local result = fp:read("*a")
		local wtf = vim.json.decode(result);
		output = wtf
		for k,v in pairs(wtf) do print(k,v) end
		fp:close()
	end
  return output
end

function M.registerSnippet(root_dir, filetypes, lsp_name, global_snippets)
  local output = {}
  if lsp_name == "tsserver" or lsp_name == "volar" then
    local package_json = parserPackageJson(root_dir)
    for _, filetype in pairs(filetypes) do
      for _, v in pairs(global_snippets) do
        local out = M.nodeJsShouldAddSnippet(v, package_json)
        if out ~= nil then
          if output[filetype] ~= nil then
            output[filetype] = {}
          end
          table.insert(output[filetype], out)
        end
      end
    end
    ls.add_snippets(nil, output)
  end
end

function M.nodeJsShouldAddSnippet(decoratedSnip, package_json, lsp_filetype)
  local filetype = decoratedSnip[1]
  local depName = decoratedSnip[2]
  local depOrDevDep = decoratedSnip[3]
  local acceptedValue = decoratedSnip[4]
  local x = package_json[depOrDevDep][depName]
  if x and filetype == lsp_filetype then
    if acceptedValue == "present" then
      return decoratedSnip[5]
    end
  end
  return nil
end

return M

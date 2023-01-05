
local ls = require("luasnip")

local snippet = ls.snippet
local text = ls.text_node
local func = ls.function_node
local insert = ls.insert_node


local M = {}

function M.setup()
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    -- local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
		local root_dir = client["config"].root_dir
		local file_types = client["config"].filetypes
		local lsp_name = client.name
		M.registerSnippet(root_dir, file_types, lsp_name)
		-- print(vim.inspect(filetypes))
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

function M.registerSnippet(root_dir, filetypes, lsp_name)
  if lsp_name == "tsserver" then
    local snippets = {}
    local package_json = parserPackageJson(root_dir)
    for _, v in pairs(M.typescriptSnippets()) do
      local out = M.nodeJsShouldAddSnippet(v, package_json)
      if out ~= nil then
        table.insert(snippets, out)
      end
    end
    ls.add_snippets(nil, {
      typescript = snippets,
    })
  end
  if lsp_name == "volar" then
    local snippets = {}
    local package_json = parserPackageJson(root_dir)
    for _, v in pairs(M.vue()) do
      local out = M.nodeJsShouldAddSnippet(v, package_json)
      if out ~= nil then
        table.insert(snippets, out)
      end
    end
    ls.add_snippets(nil, {
      vue = snippets,
    })
  end
end

function M.nodeJsShouldAddSnippet(decoratedSnip, package_json)
  local depName = decoratedSnip[1]
  local depOrDevDep = decoratedSnip[2]
  local acceptedValue = decoratedSnip[3]
  local x = package_json[depOrDevDep][depName]
  if x then
    if acceptedValue == "present" then
      return decoratedSnip[4]
    end
  end
  return nil
end

function M.typescript()
	local fastifySnippet = {
    "fastify",
    "dependencies",
    "present",
		snippet({
			trig = "fastifyScope",
		}, {
			text({"import fastify, {",
			"  FastifyError,",
			"  FastifyInstance,",
			"  FastifyPluginOptions,",
			"} from \"fastify\";",
			"",
			"const "
			}),
			insert(1, "routes"),
			text({" = (",
			"  fastify: FastifyInstance,",
			"  options: FastifyPluginOptions,",
			"  next: (error?: FastifyError) => void",
			") => {",
			"  // Powered by luasnip + custom func",
			"  next();",
			"};"})
		})
	}
  return {fastifySnippet}
end

function M.vue()
  local vueTemplate = {
    "vue",
    "dependencies",
    "present",
		snippet({
			trig = "vue 3 script+template",
      dscr = "Vue 3 script(setup)+template",
		}, {
			text({"<script setup lang=\"ts\">",
      "import {ref, computed, PropType } from \"vue\"",
			"",
			"const props = defineProps({",
      "  type: {",
      "    required: true,",
      "    type: String as PropType<string>,",
      "  }",
      "})",
			"</script>",
			"<template>",
      "  <div></div>",
			"</template>",
      })
    })
  }

  return {
    vueTemplate
  }
end

return M

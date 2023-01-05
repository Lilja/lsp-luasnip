
local ls = require("luasnip")

local snippet = ls.snippet
local text = ls.text_node
local func = ls.function_node
local insert = ls.insert_node


local M = {}

function parserPackageJson(workspace)
	local fp = io.open(workspace .. "/package.json", "r")
	if fp ~= nil then
		local result = fp:read("*a")
		local wtf = vim.json.decode(result);
		-- print(vim.inspect(wtf))
		-- print(vim.inspect(wtf["dependencies"]))
		print("rofl")
		for k,v in pairs(wtf) do print(k,v) end
	end
end

function M.addSnippets(workspace)
	parserPackageJson(workspace)
	ls.add_snippets(nil, {
		typescript = M.typescriptSnippets(workspace)
	})

end

function M.typescriptSnippets(workspace)
	return {
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
end

return M

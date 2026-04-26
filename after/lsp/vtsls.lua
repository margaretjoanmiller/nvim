-- vtsls: modern wrapper around tsserver with better performance, inlay hints,
-- import code actions, etc.
-- Source: https://github.com/yioneko/vtsls
-- Install via mason (already in mason-tool-installer list): vtsls
return {
	settings = {
		typescript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
		},
		javascript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
		},
		vtsls = {
			experimental = {
				completion = { enableServerSideFuzzyMatch = true },
			},
		},
	},
}
